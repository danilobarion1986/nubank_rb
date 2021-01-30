# frozen_string_literal: true

require_relative './expense_parser'

module Model
  # Get the necessary information from a bill's expense
  class Expense
    attr_reader :data

    def initialize(data)
      @data = ExpenseParser.call(data)
    end

    def to_ary
      @data.values_at(:data, :descricao, :categoria, :valor)
    end
  end
end
