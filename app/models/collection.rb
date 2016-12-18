class Collection < Item

  # CLASS METHODS ###################################################################

  def self.every
    Item.joins(:object_type).where(object_types: { handler: "collection" })
  end

  def self.containing s, ot=nil
    return [] unless s
    i = s.id.to_s
    r = Regexp.new '\[' + i + ',|,' + i + ',|,' + i + '\]|\[' + i + '\]'
    if ot
      Collection.includes(:object_type).where(object_type_id: ot.id)
                .select { |i| r =~ i.datum[:matrix].to_json  }
    else
      Collection.every.select { |i| r =~ i.datum[:matrix].to_json }
    end
  end

  def position s
    rows,cols = self.dimensions
    m = self.matrix
    (0..rows-1).each do |r|
      (0..cols-1).each do |c|
        if m[r][c] == s.id
          return { row: r, column: c }
        end
      end
    end
    return nil
  end

  def self.parts s, ot=nil
    plist = []
    Collection.containing(s,ot).reject { |c| c.deleted? }.each do |c|
      plist << Collection.find(c.id).position(s).merge(collection: c)
    end
    return plist
  end

  def self.spread samples, name, rows, cols

    samples_per_collection = rows * cols
    num_collections = ( samples.length / samples_per_collection.to_f ).ceil
    s = 0

    collections = (1..num_collections).collect do |i|
      c = self.new_collection name, rows, cols
      m = c.matrix
      (0..rows-1).each do |r|
        (0..cols-1).each do |c|
          if s < samples.length
            m[r][c] = samples[s].id
          end
          s += 1
        end
      end
      c.matrix = m
      c.save
      c

    end

    return collections

  end

  # METHODS #########################################################################

  def self.new_collection name

    o = ObjectType.find_by_name(name)
    raise "Could not find object type named '#{name}'." unless o

    i = Collection.new
    i.object_type_id = o.id
    i.apportion(o.rows, o.columns)
    i.quantity = 1
    i.inuse = 0
    i.location = "Bench"
    i.save
    i

  end

  def apportion r, c
    self.matrix = (Array.new(r,Array.new(c,-1)))
  end

  def associate sample_matrix

    m = self.get_data[:matrix]

    (0..sample_matrix.length-1).each do |r|
      (0..sample_matrix[r].length-1).each do |c|
        if sample_matrix[r][c].class == Sample
          m[r][c] = sample_matrix[r][c].id
        else
          m[r][c] = sample_matrix[r][c]
        end
      end
    end

    self.datum = { matrix: m }
    self.save

  end

  def set_matrix m
    self.associate m
  end

  def get_matrix
    self.datum[:matrix]
  end

  def matrix
    self.datum[:matrix]
  end

  def matrix= m
    d = self.datum
    self.datum = d.merge( { matrix: m } )
  end

  def set r, c, x
    m = self.matrix
    if x.class == Fixnum
      m[r][c] = x
    elsif x.class == Item
      if x.sample
        m[r][c] = x.sample.id
      else
        raise "When the third argument to Collection.set is an item, it should be associated with a sample."
      end
    elsif x.class == Sample
      m[r][c] = x.id
    elsif x.class == String
      m[r][c] = x.split(':')[0].to_i
    elsif !x
      m[r][c] = -1
    else
      raise "The third argument to Collection.set should be an item, a sample, or a sample id, but it was '#{x}' which is a #{x.class}"
    end
    self.matrix = m
    self.save
  end

  def next r, c, options={}

    opts = { skip_non_empty: false }.merge options

    m = self.matrix
    nr, nc = self.dimensions

    (r..nr-1).each do |row|
      (0..nc-1).each do |col|
        if row > r || col > c
          if !opts[:skip_non_empty] || m[row][col] == -1
            return [ row, col ]
          end
        end
      end
    end

    return [nil,nil]

  end

  #def [](i)
  #  self.matrix[i]
  #end

  def dimensions
    m = self.matrix
    if m && m[0]
      [ m.length, m[0].length ]
    else
      [ 0, 0 ]
    end
  end

  def num_samples

    m = self.matrix
    s = 0

    (0..m.length-1).each do |r|
      (0..m[r].length-1).each do |c|
        if m[r][c] != -1
          s += 1
        end
      end
    end

    s

  end

  def non_empty_string

    m = self.matrix
    max = [0,0]

    (0..m.length-1).each do |r|
      (0..m[r].length-1).each do |c|
        if m[r][c] != -1
          max = [r,c]
        end
      end
    end

    if m.length > 1
      "1,1 - #{max[0]+1}, #{max[1]+1}"
    else
      "1 - #{max[1]+1}"
    end

  end

end
