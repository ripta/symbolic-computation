module SymbolicComputation
  module AST

    class Multiply < BinaryOp.implement

      op :*
      simplify {
        on(Variable, Variable) { |v1, v2| v1 ** 2 if v1 == v2 }
        on_any_order(Value, Variable) { |coef, var| Operand.new(coef, var) }
      }

    end

  end
end
