module SymbolicComputation
  module Generator

    module ClassMethods

      def abstract
        self
      end

      def implement(&blk)
        Class.new(self).tap { |k| k.class_eval(&blk) unless blk.nil? }
      end

    end

  end
end
