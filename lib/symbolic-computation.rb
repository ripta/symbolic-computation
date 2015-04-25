
module SymbolicComputation

  class Generator

    Basic = Class.new do
      self.class.send(:define_method, :coerces) do |*target_klasses|
        coercion_klass = self
        # coerce(other) is defined on subclasses
        Basic.send(:define_method, :coerce) do |other|
          case other
          when *target_klasses
            # begin
              [coercion_klass.new(other), self]
              # [Value.new(other), self]
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

      self.class.send(:define_method, :op) do |op|
        op_klass = self
        if Basic.instance_methods.include?(op)
          raise ArgumentError, "Cannot allow #{op_klass} to operate on #{op.inspect}, because it is already claimed"
        end
        Basic.send(:define_method, op) do |*others|
          # puts "#{self.class} #{op_klass} #{others.first.inspect}"
          op_klass.new(self, *others)
        end
        self
      end
    end

    def self.class(*ivars, &blk)
      klass = Class.new(Basic) do

        attr_reader *ivars

        # def klass.abstract
        self.class.send(:define_method, :abstract) do
          self
        end

        # def klass.implement
        self.class.send(:define_method, :implement) do
          Class.new(self)
        end

        # def call(*vars)
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

        # def initialize(*_)
        define_method(:initialize) do |*_|
          ivars.each_with_index do |ivar, idx|
            instance_variable_set("@#{ivar}", _[idx])
          end
        end

        # def inspect
        define_method(:inspect) do
          inspected_ivars = ivars.map { |ivar| instance_variable_get("@#{ivar}").inspect }.join(', ')
          "#{self.class.name.split(/::/).last}(#{inspected_ivars})"
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

  BinaryOp = Generator.class(:_1, :_2).abstract
    Add = BinaryOp.implement.op(:+)
    Subtract = BinaryOp.implement.op(:-)
    Multiply = BinaryOp.implement.op(:*)
    Divide = BinaryOp.implement.op(:/)

  Value = Generator.class(:_).coerces(Numeric)
  Variable = Generator.class(:_)

end

def Parse(&blk)
  SymbolicComputation::Builder.instance_eval(&blk)
end
