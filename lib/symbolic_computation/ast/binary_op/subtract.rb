module SymbolicComputation
  module AST

    Subtract = BinaryOp.implement do
      op :-
      simplify {
        on(Any, Variable) { |a, v| puts "(Any, Variable)"; a + (-v) }
        on(Any, Numeric) { |a, n| puts "(Any, Numeric)"; a + (-n) }
        on(Any, Value) { |a, v| puts "(Any, Value)"; a + (-v) }
      }
    end

  end
end
