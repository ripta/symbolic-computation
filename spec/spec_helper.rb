require_relative '../lib/symbolic_computation'

module ContextHelper

  def expr(&blk)
    let(:expr) { SymbolicComputation::Expression.new(blk.call) }
  end

  def it_parses_and_validates
    it do
      expect { subject }.not_to raise_exception
      expect(subject).to eql(expr)
    end
  end

  def parsing(&blk)
    subject { Parse(&blk) }
  end

  def simplify(&blk)
    subject { Simplify(Parse(&blk)) }
  end

end

module TestHelper
  # SymbolicComputation.constants.each do |const|
  #   self.const_set(const, SymbolicComputation.const_get(const))
  # end
end

RSpec.configure do |c|

  c.extend ContextHelper
  c.include TestHelper

  c.fail_fast = false

  if c.files_to_run.one?
    c.formatter = :documentation
  else
    c.formatter = :progress
  end

  c.order = :random
  Kernel.srand c.seed

  c.expect_with :rspec do |exp|
    exp.syntax = :expect
  end

  c.mock_with :rspec do |mocks|
    mocks.syntax = :expect
    mocks.verify_partial_doubles = false
  end

end
