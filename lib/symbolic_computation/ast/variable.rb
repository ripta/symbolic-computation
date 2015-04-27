module SymbolicComputation
  module AST

    class Variable < Generator.class(:_)

      def -@
        -1 * self
      end

      def like?(other)
        super && self._ == other._
      end

    end

  end
end
