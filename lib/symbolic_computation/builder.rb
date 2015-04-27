module SymbolicComputation
  class Builder

    class <<self

      def instance_eval(&blk)
        AST::Expression.new super
      end

      def method_missing(name, *args, &blk)
        AST::Variable.new(name)
      end

    end

  end
end
