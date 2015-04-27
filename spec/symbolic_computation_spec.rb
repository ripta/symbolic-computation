RSpec.describe SymbolicComputation do

  Add      = SymbolicComputation::AST::Add
  Multiply = SymbolicComputation::AST::Multiply
  Term  = SymbolicComputation::AST::Term
  Power    = SymbolicComputation::AST::Power
  Subtract = SymbolicComputation::AST::Subtract
  Value    = SymbolicComputation::AST::Value
  Variable = SymbolicComputation::AST::Variable

  describe '#==' do
    context 'Value(5)' do
      subject { Value.new(5) }
      it { is_expected.to eq(5) }
      it { is_expected.to eq(Value.new(5)) }
    end
  end

  describe '#eql?' do
    context 'Value(5)' do
      subject { Value.new(5) }
      it { is_expected.not_to eql(5) }
      it { is_expected.to eql(Value.new(5)) }
    end
  end

  describe '#Parse' do

    context '5' do
      parsing { 5 }
      expr { 5 }
      it_parses_and_validates
    end

    context 'x' do
      parsing { x }
      expr { Variable.new(:x) }
      it_parses_and_validates
    end

    context 'Add' do
      context '5 + 2' do
        parsing { 5 + 2 }
        expr { 7 }
        it_parses_and_validates
      end

      context 'x + 2' do
        parsing { x + 2 }
        expr { Add.new(Variable.new(:x), Value.new(2)) }
        it_parses_and_validates
      end

      context '2 + x' do
        parsing { 2 + x }
        expr { Add.new(Value.new(2), Variable.new(:x)) }
        it_parses_and_validates
      end

      context 'x + x' do
        parsing { x + x }
        expr { Add.new(Variable.new(:x), Variable.new(:x)) }
        it_parses_and_validates
      end

      context 'x + y' do
        parsing { x + y }
        expr { Add.new(Variable.new(:x), Variable.new(:y)) }
        it_parses_and_validates
      end
    end

    context 'Subtract' do
      context '5 - 2' do
        parsing { 5 - 2 }
        expr { 3 }
        it_parses_and_validates
      end

      context 'x - x' do
        parsing { x - x }
        expr { Subtract.new(Variable.new(:x), Variable.new(:x)) }
        it_parses_and_validates
      end
    end

    context 'Multiply' do
      context '9 * 6' do
        parsing { 9 * 6 }
        expr { 54 }
        it_parses_and_validates
      end

      context '9 * x' do
        parsing { 9 * x }
        expr { Multiply.new(Value.new(9), Variable.new(:x)) }
        it_parses_and_validates
      end
    end

  end

  describe '#Simplify' do
    context 'x + x' do
      simplify { x + x }
      expr { Term.new(Value.new(2), Variable.new(:x)) }
      it_parses_and_validates
    end

    context 'x + y' do
      simplify { x + y }
      expr { Add.new(Variable.new(:x), Variable.new(:y)) }
      it_parses_and_validates
    end

    context '2 * x + 3 * x' do
      simplify { 2 * x + 3 * x }
      expr { Term.new(Value.new(5), Variable.new(:x)) }
      it_parses_and_validates
    end

    context '3 * x + 5 * y' do
      simplify { 3 * x + 5 * y }
      expr { Add.new(Term.new(Value.new(3), Variable.new(:x)), Term.new(Value.new(5), Variable.new(:y))) }
      it_parses_and_validates
    end

    context '2 * x - x' do
      simplify { 2 * x - x }
      expr { Variable.new(:x) }
      it_parses_and_validates
    end

    context '5 * x - x' do
      simplify { 5 * x - x }
      expr { Term.new(Value.new(4), Variable.new(:x)) }
      it_parses_and_validates
    end

    context '2 * x - x - x' do
      simplify { 2 * x - x - x }
      expr { Value.new(0) }
      it_parses_and_validates
    end

    context 'x * x' do
      simplify { x * x }
      expr { Power.new(Variable.new(:x), Value.new(2)) }
      it_parses_and_validates
    end

    context 'x ** 3' do
      simplify { x ** 3 }
      expr { Power.new(Variable.new(:x), Value.new(3)) }
      it_parses_and_validates
    end

    context 'x ** x' do
      simplify { x ** x }
      expr { Power.new(Variable.new(:x), Variable.new(:x)) }
      it_parses_and_validates
    end

    context 'x ** 2 * y' do
      simplify { x ** 2 * x }
      expr { Multiply.new(Power.new(Variable.new(:x), Value.new(2)), Variable.new(:x)) }
    end

    context 'x ** (2 * y)' do
      simplify { x ** (2 * x) }
      expr { Power.new(Variable.new(:x), Term.new(Value.new(2), Variable.new(:x))) }
      it_parses_and_validates
    end

    context '1 / x' do
      simplify { 1 / x }
      expr { Multiply.new(Value.new(1), Power.new(Variable.new(:x), Value.new(-1))) }
      it_parses_and_validates
    end

    context '2 * x / y' do
      simplify { 2 * x / y }
      expr { Multiply.new(Term.new(Value.new(2), Variable.new(:x)), Power.new(Variable.new(:y), Value.new(-1))) }
      it_parses_and_validates
    end

    context 'x / x' do
      simplify { x / x }
      expr { Value.new(1) }
      it_parses_and_validates
    end

    context '(3 + x) / 2' do
      simplify { (3 + x) / 2 }
      expr { Add.new(Value.new(1.5), Term.new(Value.new(0.5), Variable.new(:x))) }
      it_parses_and_validates
    end

    context '6 / x / x' do
      simplify { 6 / x / x }
      expr { Multiply.new(Multiply.new(Value.new(6), Power.new(Variable.new(:x), Value.new(-1))), Power.new(Variable.new(:x), Value.new(-1))) }
      it_parses_and_validates
    end

  end

end
