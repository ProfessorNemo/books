# frozen_string_literal: true

require 'roo'

namespace :import_fines do
  desc 'Import fines from xlsx files'

  task from_xlsx_fines: :environment do
    puts 'Importing Data Fines'

    data = Roo::Spreadsheet.open('db/db_fine.xlsx')

    headers = data.row(1)

    data.each_with_index do |row, idx|
      next if idx.zero?

      fine_data = [headers, row].transpose.to_h

      fine = Fine.new(fine_data)

      puts "Saving Fine with title '#{fine.person}'"

      fine.save!
    end
  end

  task from_xlsx_traffic_violations: :environment do
    puts 'Importing Data Traffic Violations'

    data = Roo::Spreadsheet.open('db/db_traffic_violation.xlsx')

    headers = data.row(1)

    data.each_with_index do |row, idx|
      next if idx.zero?

      traffic_data = [headers, row].transpose.to_h

      traffic = TrafficViolation.new(traffic_data)

      puts "Saving Traffic Violations with title '#{traffic.violation}'"

      traffic.save!
    end
  end
end
