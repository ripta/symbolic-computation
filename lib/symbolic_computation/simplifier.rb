module SymbolicComputation
  class Simplifier

    Rule = Struct.new(:idx_orders, :logic) do
      def execute(values)
        reordered_values = idx_orders.map { |idx| values[idx] }
        logic.(*reordered_values) #.tap { |v| puts v.inspect }
      end
    end

    attr_reader :rules

    def initialize
      @rules = {}
    end

    def execute(values)
      return if rules.empty?

      typeset = rules.keys.find { |types| values.zip(types).all? { |value, type| value.kind_of?(type) } }
      if typeset.nil?
        # puts "TS_XX: #{values.size}##{values.inspect} => nil (options were #{rules.keys.inspect})"
        nil
      else
        # puts "TS_OK: #{values.inspect} => #{typeset.inspect}"
        rules[typeset].execute(values)
      end
    end

    def on(*types, &blk)
      set(types, 0.upto(types.size - 1).to_a, blk)
    end

    def on_any_order(*types, &blk)
      idx_orders = 0.upto(types.size - 1).to_a.permutation(types.size)
      idx_orders.each do |idx_order|
        type_order = idx_order.map { |idx| types[idx] }
        set(type_order, idx_order, blk)
      end
      self
    end

    private

    def set(type_order, idx_order, blk)
      if rules.key?(type_order)
        warn "Redefining simplification rule for #{types.inspect}."
      end
      rules[type_order] = Rule.new(idx_order, blk)
    end

  end
end