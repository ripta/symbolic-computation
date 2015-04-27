module SymbolicComputation
  module AST

    BinaryOp = Generator.class(:_1, :_2).abstract

  end
end

require_relative 'binary_op/add'
require_relative 'binary_op/subtract'
require_relative 'binary_op/power'
require_relative 'binary_op/multiply'
require_relative 'binary_op/divide'
