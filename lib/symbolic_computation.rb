module SymbolicComputation

  class Simplifier

    Rule = Struct.new(:idx_orders, :logic) do
      def execute(values)
        reordered_values = idx_orders.map { |idx| values[idx] }
        logic.(*reordered_values) #.tap { |v| puts v.inspect }
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
        # puts "TS_XX: #{values.size}##{values.inspect} => nil (options were #{rules.keys.inspect})"
        nil
      else
        # puts "TS_OK: #{values.inspect} => #{typeset.inspect}"
        rules[typeset].execute(values)
      end
    end

    def on(*types, &blk)
      set(types, 0.upto(types.size - 1).to_a, blk)
    end

    def on_any_order(*types, &blk)
      idx_orders = 0.upto(types.size - 1).to_a.permutation(types.size)
      idx_orders.each do |idx_order|
        type_order = idx_order.map { |idx| types[idx] }
        set(type_order, idx_order, blk)
      end
      self
    end

    private

    def set(type_order, idx_order, blk)
      if rules.key?(type_order)
        warn "Redefining simplification rule for #{types.inspect}."
      end
      rules[type_order] = Rule.new(idx_order, blk)
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
            #puts "Basic##{op}"
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
      define_method(:implement) do |&blk|
        Class.new(self).tap { |k| k.class_eval(&blk) unless blk.nil? }
      end

    end

    def self.basic
      Basic
    end

    def self.class(*ivars, &blk)
      klass = Class.new(Basic) do
        extend MetaClassMethods

        attr_reader *ivars

        # def ==(other)
        define_method(:==) do |other|
          if self.class == other.class
            # ivars.map { |ivar| send(ivar) } == ivars.map { |ivar| other.send(ivar) }
            ivars.all? { |ivar| send(ivar) == other.send(ivar) }
          else
            false
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
          self.class.simplify.execute(ivar_simplifieds) || self.class.new(*ivar_simplifieds)
        end

      end

      if blk.nil?
        klass
      else
        Class.new(klass).tap { |k| k.class_eval(&blk) }
      end
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

end

module SymbolicComputation

  Any = Generator.basic
  Expression = Generator.class(:_)

  Value = Generator.class(:_) do
    coerces Numeric

    def -@
      self.class.new(-self._)
    end

    def +(other)
      if self.class === other
        self.class.new(self._ + other._)
      else
        super
      end
    end

    def ==(other)
      return _ == other if Numeric === other
      super
    end
  end
  Variable = Generator.class(:_) do
    def -@
      -1 * self
    end
  end
  Operand = Generator.class(:coef, :var) do
    simplify {
      on(Value, Variable) { |val, var|
        if val == 0
          val
        elsif val == 1
          var
        else
          # noop
        end
      }
    }

    def -@
      self.class.new(-coef, var)
    end

    def +(other)
      if self.class === other && var == other.var
        self.class.new(coef + other.coef, var)
      else
        super
      end
    end

    def pred
      self.class.new(coef + Value.new(-1), var)
    end

    def succ
      self.class.new(coef + Value.new(1), var)
    end
  end

  UnaryOp = Generator.class(:_1).abstract
    # UnaryMinus = UnaryOp.implement.op(:-@)

  BinaryOp = Generator.class(:_1, :_2).abstract
    Add = BinaryOp.implement do
      op :+
      simplify {
        # 2x + 3x => 5x
        on(Operand, Operand) { |o1, o2| o1 + o2 if o1.var == o2.var }
        # x + x => 2x
        on(Variable, Variable) { |v1, v2| 2 * v1 if v1 == v2 }
        # 2x + x => 3x
        on_any_order(Operand, Variable) { |o, v| o.succ if o.var == v }
      }
    end
    Subtract = BinaryOp.implement do
      op :-
      simplify {
        on(Any, Variable) { |a, v| puts "(Any, Variable)"; a + (-v) }
        on(Any, Numeric) { |a, n| puts "(Any, Numeric)"; a + (-n) }
        on(Any, Value) { |a, v| puts "(Any, Value)"; a + (-v) }
      }
    end
    Multiply = BinaryOp.implement do
      op :*
      simplify {
        on_any_order(Numeric, Variable) { |coef, var| Operand.new(Value.new(coef), var) }
        on_any_order(Value, Variable)   { |coef, var| Operand.new(coef, var) }
      }
    end
    Divide = BinaryOp.implement.op(:/)

end

def Parse(&blk)
  SymbolicComputation::Builder.instance_eval(&blk)
end

def Simplify(expr, max_depth = 500)
  return expr if max_depth <= 0
  simple = expr.simplify
  simple == expr ? simple : Simplify(simple, max_depth - 1)
end
