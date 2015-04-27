module SymbolicComputation
  module AST

    class Subtract < BinaryOp.implement

      op :-
      simplify {
        on(Any, Object) { |any, obj| any + (-obj) }
      }

    end

  end
end
