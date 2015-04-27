module SymbolicComputation
  module AST

    Value = Generator.class(:_) do
      coerces Numeric

      def -@
        self.class.new(-self._)
      end

      def +(other)
        if self.class === other
          self.class.new(self._ + other._)
        else
          super
        end
      end

      def ==(other)
        return _ == other if Numeric === other
        super
      end
    end

  end
end
