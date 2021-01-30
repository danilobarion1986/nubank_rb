# frozen_string_literal: true

require 'date'

module Model
  # Parse expense data
  class ExpenseParser
    def self.call(data)
      {
        data: Date.parse(data[:post_date]).strftime('%d/%m/%y'),
        descricao: data[:title],
        categoria: data[:category],
        valor: (data[:amount] / 100.0)
      }
    rescue
      {}
    end
  end
end
