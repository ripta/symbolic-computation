module SymbolicComputation
  module AST

    class Multiply < BinaryOp.implement

      op :*
      simplify {
        on_any_order(Numeric, Variable) { |coef, var| Operand.new(Value.new(coef), var) }
        on_any_order(Value, Variable)   { |coef, var| Operand.new(coef, var) }
      }

    end

  end
end
