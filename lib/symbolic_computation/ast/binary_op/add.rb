module SymbolicComputation
  module AST

    class Add < BinaryOp.implement

      op :+
      simplify {
        on(Variable, Variable) { |v1, v2| 2 * v1 if v1 == v2 }
        on(Any, Any) { |a1, a2| a1 + a2 if a1.like?(a2) }
      }

    end

  end
end
