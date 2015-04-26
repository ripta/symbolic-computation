
module SymbolicComputation

  class Simplifier

    Rule = Struct.new(:idx_orders, :logic) do
      def execute(values)
        reordered_values = idx_orders.map { |idx| values[idx] }
        logic.(*reordered_values).tap { |v| puts v.inspect }
      end
    end

    attr_reader :rules

    def initialize
      @rules = {}
    end

    def execute(values)
      return if rules.empty?

      typeset = rules.keys.find { |types| values.zip(types).all? { |value, type| value.kind_of?(type) } }
      if typeset.nil?
        nil
      else
        rules[typeset].execute(values)
      end
    end

    def permute(*types, &blk)
      idx_orders = 0.upto(types.size - 1).to_a.permutation(types.size)
      idx_orders.each do |idx_order|
        type_order = idx_order.map { |idx| types[idx] }
        if rules.key?(type_order)
          warn "Redefining simplification rule for #{types.inspect}."
        end
        rules[type_order] = Rule.new(idx_order, blk)
      end
      self
    end

  end

  class Generator

    Basic = Class.new do
      class <<self

        define_method(:coerces) do |*target_klasses|
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

        define_method(:op) do |op|
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

        define_method(:simplify) do |&blk|
          @__simplifier__ ||= Simplifier.new
          blk.nil? ? @__simplifier__ : @__simplifier__.instance_eval(&blk)
        end

      end
    end

    MetaClassMethods = Module.new do

      # def klass.abstract
      define_method(:abstract) do
        self
      end

      # def klass.implement
      define_method(:implement) do
        Class.new(self)
      end

    end

    def self.class(*ivars, &blk)
      klass = Class.new(Basic) do
        extend MetaClassMethods

        attr_reader *ivars

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
          inspected_ivars = ivars.map { |ivar| __send__(ivar).inspect }.join(', ')
          "#{self.class.name.split(/::/).last}(#{inspected_ivars})"
        end

        define_method(:simplify) do
          ivar_simplifieds = ivars.map do |ivar|
            val = __send__(ivar)
            val.respond_to?(:simplify) ? val.simplify : val
          end
          # simple = self.class.simplify.execute(ivar_simplifieds)
          # if simple
          # else
          # end
          self.class.simplify.execute(ivar_simplifieds) || self.class.new(*ivar_simplifieds)
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

  Value = Generator.class(:_).coerces(Numeric)
  Variable = Generator.class(:_)
  Operand = Generator.class(:coef, :var)

  BinaryOp = Generator.class(:_1, :_2).abstract
    Add = BinaryOp.implement.op(:+)
    Subtract = BinaryOp.implement.op(:-)
    Multiply = BinaryOp.implement.op(:*)
      Multiply.simplify do
        permute(Numeric, Variable) { |coef, var| Operand.new(Value.new(coef), var) }
        permute(Value, Variable)   { |coef, var| Operand.new(coef, var) }
      end
    Divide = BinaryOp.implement.op(:/)

end

def Parse(&blk)
  SymbolicComputation::Builder.instance_eval(&blk)
end

