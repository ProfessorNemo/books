# frozen_string_literal: true

require 'roo'

namespace :import do
  desc 'Import books from xlsx files'

  task from_xlsx_books: :environment do
    puts 'Importing Data Books'

    data = Roo::Spreadsheet.open('db/db_books.xlsx') # открыть таблицу xlsx

    headers = data.row(1) # получить строку заголовка

    data.each_with_index do |row, idx|
      next if idx.zero? # пропустить строку заголовка

      # создать хеш из заголовков и ячеек
      book_data = [headers, row].transpose.to_h

      # переход на следующую итерацию, если книга уже существует
      if Book.exists?(title: book_data['title'])
        puts "Book with title #{book_data['title']} already exists"

        next
      end

      book = Book.new(book_data)

      puts "Saving Book with title '#{book.title}'"

      book.save!
    end
  end

  task from_xlsx_persons_trip: :environment do
    puts 'Importing Data Persons'

    data = Roo::Spreadsheet.open('db/db_trip.xlsx')

    headers = data.row(1)

    data.each_with_index do |row, idx|
      next if idx.zero?

      trip_data = [headers, row].transpose.to_h

      trip = Trip.new(trip_data)

      puts "Saving Trip with title '#{trip.person}'"

      trip.save!
    end
  end
end
