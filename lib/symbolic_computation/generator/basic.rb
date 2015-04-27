module SymbolicComputation
  module Generator

    class Basic
      class <<self

        def coerce(value)
          coerced_type = coercer_registry.keys.find do |type|
            # puts "#{value.inspect}.kind_of?(#{type.inspect})"
            value.kind_of?(type)
          end
          if coerced_type.nil?
            # warn "Cannot coerce #{value.inspect}"
            value
          else
            coercer = coercer_registry[coerced_type]
            self == coercer ? value : coercer.new(value)
          end
        end

        def coercer_registry
          @@coercer_registry ||= { }
        end

        def coerces(*target_klasses)
          coercion_klass = self

          target_klasses.each do |target_klass|
            coercion_klass.coercer_registry[target_klass] = coercion_klass
          end

          # FIXME: this should be defined on the subklass instead, but there are resolution problems
          # coercion_klass.send(:define_method, :coerce) do |other|
          Basic.send(:define_method, :coerce) do |other|
            case other
            when *target_klasses
              [coercion_klass.new(other), self]
            else
              raise TypeError, "#{self.class.name} cannot be coerced into #{other.class.name}!"
            end
          end
          self
        end

        def op(operator)
          op_klass = self

          if Basic.instance_methods.include?(operator)
            raise ArgumentError, "Cannot allow #{op_klass} to operate on #{operator.inspect}, because it is already claimed"
          end

          Basic.send(:define_method, operator) do |*others|
            #puts "Basic##{op}"
            # puts "#{self.class} #{op_klass} #{others.first.inspect}"
            op_klass.new(self, *others)
          end

          self
        end

        def simplify(&blk)
          @__simplifier__ ||= Simplifier.new
          blk.nil? ? @__simplifier__ : @__simplifier__.instance_eval(&blk)
        end

      end
    end

  end
end
