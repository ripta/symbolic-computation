require_relative 'symbolic_computation/simplifier'
require_relative 'symbolic_computation/generator'
require_relative 'symbolic_computation/ast'

require_relative 'symbolic_computation/builder'

def Parse(&blk)
  SymbolicComputation::Builder.instance_eval(&blk)
end

def Simplify(expr, max_depth: 500)
  return expr if max_depth <= 0
  simple = expr.simplify
  simple == expr ? simple : Simplify(simple, max_depth: max_depth - 1)
end
