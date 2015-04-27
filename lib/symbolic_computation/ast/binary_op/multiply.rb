module SymbolicComputation
  module AST

    class Multiply < BinaryOp.implement

      op :*
      simplify {
        on(Value, Value) { |v1, v2| v1 * v2 }
        on(Variable, Variable) { |v1, v2| v1 ** 2 if v1.like?(v2) }
        on_any_order(Variable, Power) { |v, p| p * v if p.like?(v) }
        on_any_order(Value, Variable) { |coef, var| Term.new(coef, var) }
      }

    end

  end
end
