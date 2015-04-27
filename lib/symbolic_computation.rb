require_relative 'symbolic_computation/simplifier'
require_relative 'symbolic_computation/generator'
require_relative 'symbolic_computation/builder'

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

def Simplify(expr, max_depth: 500)
  return expr if max_depth <= 0
  simple = expr.simplify
  simple == expr ? simple : Simplify(simple, max_depth: max_depth - 1)
end
