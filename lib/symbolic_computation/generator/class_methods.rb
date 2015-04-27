module SymbolicComputation
  module Generator

    ClassMethods = Module.new do

      # def klass.abstract
      define_method(:abstract) do
        self
      end

      # def klass.implement
      define_method(:implement) do |&blk|
        Class.new(self).tap { |k| k.class_eval(&blk) unless blk.nil? }
      end

    end

  end
end
