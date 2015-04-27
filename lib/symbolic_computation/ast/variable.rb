module SymbolicComputation
  module AST

    Variable = Generator.class(:_) do
      def -@
        -1 * self
      end
    end

  end
end
