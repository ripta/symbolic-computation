require_relative 'generator/basic'
require_relative 'generator/class_methods'

module SymbolicComputation
  module Generator

    def self.basic
      Basic
    end

    def self.class(*ivars, &blk)
      klass = Class.new(Basic) do
        extend ClassMethods

        attr_reader *ivars

        # def ==(other)
        define_method(:==) do |other|
          if self.class == other.class
            # ivars.map { |ivar| send(ivar) } == ivars.map { |ivar| other.send(ivar) }
            ivars.all? { |ivar| send(ivar) == other.send(ivar) }
          else
            false
          end
        end

        define_method(:eql?) do |other|
          if self.class == other.class
            ivars.all? { |ivar| send(ivar).eql? other.send(ivar) }
          else
            false
          end
        end

        # def initialize(*_)
        define_method(:initialize) do |*_|
          ivars.each_with_index do |ivar, idx|
            instance_variable_set("@#{ivar}", self.class.coerce(_[idx]))
          end
        end

        # def inspect
        define_method(:inspect) do
          inspected_ivars = ivars.map { |ivar| __send__(ivar).inspect }.join(', ')
          "#{self.class.name.split(/::/).last}(#{inspected_ivars})"
        end

        define_method(:simplify) do
          ivar_simplifieds = ivars.map do |ivar|
            val = __send__(ivar)
            val.respond_to?(:simplify) ? val.simplify : val
          end
          self.class.simplify.execute(ivar_simplifieds) || self.class.new(*ivar_simplifieds)
        end

      end

      if blk.nil?
        klass
      else
        Class.new(klass).tap { |k| k.class_eval(&blk) }
      end
    end

  end
end
