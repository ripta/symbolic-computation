module SymbolicComputation
  module AST

    class Operand < Generator.class(:coef, :var)

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

      def pred
        self.class.new(coef + Value.new(-1), var)
      end

      def succ
        self.class.new(coef + Value.new(1), var)
      end

    end

  end
end
