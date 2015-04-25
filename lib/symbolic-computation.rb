
# class Numeric
#   def _
#     self
#   end

#   # def +(other)
#   #   case other
#   #   when Numeric
#   #     super
#   #   else
#   #     _
#   #   end
#   # end
# end

module SymbolicComputation

  class Generator

    Basic = Class.new do
      self.class.send(:define_method, :coerces) do |*target_klasses|
        define_method(:coerce) do |other|
          # puts "#{self}#coerce(#{other})"
          case other
          when *target_klasses
            # begin
              [self.class.new(other), self]
            # rescue => e
            #   puts "Coercion error: #{e.message}: #{e.backtrace.join("\n")}"
            #   raise e
            # end
          else
            raise TypeError, "#{self.class.name} cannot be coerced into #{other.class.name}!"
          end
        end
        self
      end
    end

    def self.class(*ivars, &blk)
      klass = Class.new(Basic) do

        if ivars.size == 1
          define_method(:call) do |*vars|
            case instance_variable_get("@#{ivars.first}")
            when self.class
              instance_variable_get("@#{ivars.first}").(*vars)
            else
              self
            end
          end
        else
          define_method(:call) do |*vars|
            self
          end
        end

        define_method(:initialize) do |*_|
          ivars.each_with_index do |ivar, idx|
            instance_variable_set("@#{ivar}", _[idx])
          end
        end

        define_method(:inspect) do
          inspected_ivars = ivars.map { |ivar| instance_variable_get("@#{ivar}").inspect }.join(', ')
          "#{self.class.name.split(/::/).last}(#{inspected_ivars})"
        end

        ivars.each do |ivar|
          define_method(ivar) { instance_variable_get("@#{ivar}") }
        end

      end

      klass.class_eval(&blk) unless blk.nil?
      klass
    end

  end

  class Builder
    class <<self
      def instance_eval(&blk)
        Expression.new super
      end

      def method_missing(name, *args, &blk)
        Variable.new(name)
      end
    end
  end

  Expression = Generator.class(:_)

  BinaryOp = Generator.class(:_1, :_2)
  Add = Class.new(BinaryOp)#.handles(:+)
  Subtract = Class.new(BinaryOp)

  Value = Generator.class(:_)#boxes(Numeric)
  Variable = Generator.class(:_).coerces(Numeric)

end

def Parse(&blk)
  SymbolicComputation::Builder.instance_eval(&blk)
end
