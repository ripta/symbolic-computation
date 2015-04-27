module SymbolicComputation
  module AST

    class Add < BinaryOp.implement

      op :+
      simplify {
        # 2x + 3x => 5x
        on(Term, Term) { |o1, o2| o1 + o2 if o1.like?(o2) }
        # x + x => 2x
        on(Variable, Variable) { |v1, v2| 2 * v1 if v1.like?(v2) }
        on(Value, Value) { |v1, v2| v1 + v2 }
        # 2x + x => 3x
        on_any_order(Term, Variable) { |o, v| o.succ if o.var == v }
      }

    end

  end
end
