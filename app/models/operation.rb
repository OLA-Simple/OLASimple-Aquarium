class Operation < ActiveRecord::Base

  include FieldValuer
  include OperationPlanner

  def parent_type # interface with FieldValuer
    operation_type
  end  

  belongs_to :operation_type
  belongs_to :user
  belongs_to :job

  attr_accessible :status, :user_id, :job_id

  def set_input name, val
    set_property name, val, "input"
  end

  def set_output name, val
    set_property name, val, "output"
  end

  def inputs
    field_values.select { |ft| ft.role == 'input' }
  end

  def outputs
    field_values.select { |ft| ft.role == 'output' }
  end

  def get_input name
    inputs.find { |i| i.name == name }
  end

  def get_output name
    outputs.find { |o| o.name == name }
  end

  def recurse &block
    block.call(self)
    inputs.each do |input|
      input.predecessors.each do |pred|
        pred.operation.recurse &block
      end
    end
  end    

  def set_status_recursively str
    recurse do |op|
      puts "    Setting operation #{id} status to #{str}"
      op.status = str
      op.save
    end
  end

  def to_s
    ins = (inputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")
    outs = (outputs.collect { |fv| "#{fv.name}: #{fv.child_sample.name}" }).join(", ")    
    "#{operation_type.name} #{id} ( " + ins + " ) ==> ( " + outs + " )"
  end

end

