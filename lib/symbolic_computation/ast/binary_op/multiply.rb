module SymbolicComputation
  module AST

    class Multiply < BinaryOp.implement

      op :*
      simplify {
        on(Variable, Variable) { |v1, v2| v1 ** 2 if v1 == v2 }
        on_any_order(Variable, Power) { |v, p| p * v if p._1 == v }
        on_any_order(Value, Variable) { |coef, var| Term.new(coef, var) }
        # on_any_order(Value, Variable) { |coef, var| Operand.new(coef, var ** 1) }
        # on(Variable, Any) { |var, any| var ** 1 * any }
      }

    end

  end
end
