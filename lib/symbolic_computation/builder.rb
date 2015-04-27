module SymbolicComputation
  class Builder

    class <<self

      def instance_eval(&blk)
        Expression.new super
      end

      def method_missing(name, *args, &blk)
        Variable.new(name)
      end

    end

  end
end
