module SymbolicComputation
  module AST

    class Variable < Generator.class(:_)

      def -@
        -1 * self
      end

    end

  end
end
