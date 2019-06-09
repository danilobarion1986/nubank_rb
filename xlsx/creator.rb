# frozen_string_literal: true

require 'spreadsheet_architect'
require 'date'
require_relative '../model/expense'

module Xlsx
  # Create a .xlsx file using bill data
  class Creator
    HEADERS = %w[Data Descrição Valor Categoria].freeze

    def self.call(bill)
      xlsx_data = SpreadsheetArchitect.to_xlsx(headers: HEADERS, data: values_from(bill))
      now = Time.now.strftime('%d_%m_%y__%H_%M')

      File.open("nubank_bill_#{now}.xlsx", 'w+b') { |file| file.write(xlsx_data) }
    end

    private

    def self.values_from(bill)
      bill.items.map { |expense| Model::Expense.new(expense).to_ary }
    end
  end
end
