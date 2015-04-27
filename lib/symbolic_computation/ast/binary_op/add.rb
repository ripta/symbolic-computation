module SymbolicComputation
  module AST

    class Add < BinaryOp.implement

      op :+
      simplify {
        on(Variable, Variable) { |v1, v2| 2 * v1 if v1 == v2 }
        on(Any, Any) { |a1, a2| a1 + a2 if a1.like?(a2) }
      }

      def *(other)
        if self.class === other
          self.class.new(self.class.new(_1 * other._1, _2 * other._2), self.class.new(_1 * other._2, _2 * other._1))
        else
          self.class.new(_1 * other, _2 * other)
        end
      end

    end

  end
end
