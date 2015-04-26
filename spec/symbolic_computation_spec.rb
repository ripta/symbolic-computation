RSpec.describe SymbolicComputation::Expression do

  Add      = SymbolicComputation::Add
  Multiply = SymbolicComputation::Multiply
  Operand  = SymbolicComputation::Operand
  Subtract = SymbolicComputation::Subtract
  Value    = SymbolicComputation::Value
  Variable = SymbolicComputation::Variable

  describe '#Parse' do

    context '5' do
      parsing { 5 }
      expr { 5 }
      it { is_expected.to eq(expr) }
    end

    context 'x' do
      parsing { x }
      expr { Variable.new(:x) }
      it { is_expected.to eq(expr) }
    end

    context 'Add' do
      context '5 + 2' do
        parsing { 5 + 2 }
        expr { 7 }
        it { is_expected.to eq(expr) }
      end

      context 'x + 2' do
        parsing { x + 2 }
        expr { Add.new(Variable.new(:x), 2) }
        it { is_expected.to eq(expr) }
      end

      context '2 + x' do
        parsing { 2 + x }
        expr { Add.new(Value.new(2), Variable.new(:x)) }
        it { is_expected.to eq(expr) }
      end

      context 'x + x' do
        parsing { x + x }
        expr { Add.new(Variable.new(:x), Variable.new(:x)) }
        it { is_expected.to eq(expr) }
      end

      context 'x + y' do
        parsing { x + y }
        expr { Add.new(Variable.new(:x), Variable.new(:y)) }
        it { is_expected.to eq(expr) }
      end
    end

    context 'Subtract' do
      context '5 - 2' do
        parsing { 5 - 2 }
        expr { 3 }
        it { is_expected.to eq(expr) }
      end

      context 'x - x' do
        parsing { x - x }
        expr { Subtract.new(Variable.new(:x), Variable.new(:x)) }
        it { is_expected.to eq(expr) }
      end
    end

    context 'Multiply' do
      context '9 * 6' do
        parsing { 9 * 6 }
        expr { 54 }
        it { is_expected.to eq(expr) }
      end

      context '9 * x' do
        parsing { 9 * x }
        expr { Multiply.new(Value.new(9), Variable.new(:x)) }
        it { is_expected.to eq(expr) }
      end
    end

  end

  describe '#Simplify' do
    context 'x + x' do
      simplify { x + x }
      expr { Operand.new(Value.new(2), Variable.new(:x)) }
      it { is_expected.to eq(expr) }
    end

    context '2 * x + 3 * x' do
      simplify { 2 * x + 3 * x }
      expr { Operand.new(Value.new(5), Variable.new(:x)) }
      it { is_expected.to eq(expr) }
    end

    context '2 * x - x' do
      simplify { 2 * x - x }
      expr { Variable.new(:x) }
      it { is_expected.to eq(expr) }
    end

    context '5 * x - x' do
      simplify { 5 * x - x }
      expr { Operand.new(Value.new(4), Variable.new(:x)) }
      it { is_expected.to eq(expr) }
    end

    context '2 * x - x - x' do
      simplify { 2 * x - x - x }
      expr { Value.new(0) }
      it { is_expected.to eq(expr) }
    end
  end

end
