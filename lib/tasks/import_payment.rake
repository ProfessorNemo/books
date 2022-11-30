# frozen_string_literal: true

require 'roo'

namespace :import_payment do
  desc 'Import payments from xlsx files'

  task from_xlsx_payment: :environment do
    puts 'Importing Data Payments'

    data = Roo::Spreadsheet.open('db/db_payment.xlsx')

    headers = data.row(1)

    data.each_with_index do |row, idx|
      next if idx.zero?

      payment_data = [headers, row].transpose.to_h

      payment = Payment.new(payment_data)

      puts "Saving Payment with title '#{payment.person}'"

      payment.save!
    end
  end
end
