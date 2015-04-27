module SymbolicComputation
  module AST

    class Divide < BinaryOp.implement

      op :/
      simplify {
        on(Any, Value) { |any, val| any * val ** -1 }
        on(Any, Variable) { |any, var| any * var ** -1 }
      }

    end

  end
end
