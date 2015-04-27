module SymbolicComputation
  module AST

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

  end
end
