module SymbolicComputation
  module AST

    class Value < Generator.class(:_)

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

      def *(other)
        if self.class === other
          self.class.new(self._ * other._)
        else
          super
        end
      end

      def /(other)
        if self.class === other
          self.class.new(self._.to_f / other._.to_f)
        else
          super
        end
      end

      def **(other)
        if self.class === other
          self.class.new(self._.to_f ** other._.to_f)
        else
          super
        end
      end

      def ==(other)
        return _ == other if _.class === other
        super
      end

    end

  end
end
