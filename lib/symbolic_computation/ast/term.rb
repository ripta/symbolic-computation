module SymbolicComputation
  module AST

    class Term < Generator.class(:coef, :var)

      simplify {
        on(Value, Variable) { |val, var|
          if val == 0
            val
          elsif val == 1
            var
          else
            # noop
          end
        }
      }

      def -@
        self.class.new(-coef, var)
      end

      def +(other)
        if self.class === other && var == other.var
          self.class.new(coef + other.coef, var)
        else
          super
        end
      end

      def like?(other)
        (super && var == other.var) || var.like?(other)
      end

    end

  end
end
