module SymbolicComputation
  module AST

    class Power < BinaryOp.implement

      op :**
      simplify {
        on(Value, Value) { |v1, v2| v1 ** v2 }
        on(Variable, Value) { |var, val| 1 if val == 0 }
      }

      def *(other)
        if self.class === other && self._1 == other._1
          self.class.new(self._1, self._2 + other._2)
        elsif self._1.class === other && self._1 == other
          self.class.new(self._1, self._2 + 1)
        else
          super
        end
      end

      def like?(other)
        (super && self._1 == other._1) || self._1.like?(other)
      end

    end

  end
end
