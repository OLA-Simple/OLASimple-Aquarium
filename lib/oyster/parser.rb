module Oyster

  class Parser < Lang::Parser

    def initialize contents
      @tok = Lang::Tokenizer.new contents 
      @metacol = Metacol.new
      functions
      time_functions
      super() # adds array, string, collection, sample functions
    end   

    def functions
      add_function :completed, 1
      add_function :error, 1
      add_function :quantity, 1
      add_function :min_quantity, 1
      add_function :max_quantity, 1
      add_function :return_value, 2
      add_function :hours_elapsed, 2
      add_function :minutes_elapsed, 2
    end

    def parse
      statements
      @metacol
    end

    def statements

      while @tok.current != 'EOF'

        case @tok.current

          when 'argument'
            arguments

          when 'place'
            place

          when 'transition'
            trans

          when 'wire'
            wire

          else
            if @tok.next == '='
              a = assign
              @metacol.scope.set a[:lhs], @metacol.scope.evaluate( a[:rhs] )
            else  
              raise "Could not find a statement to parse at #{@tok.current}"
            end

        end

      end

    end

  end

end
