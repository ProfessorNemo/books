# frozen_string_literal: true

module BlockOne
  extend ActiveSupport::Concern

  included do
    # Для упаковки каждой книги требуется один лист бумаги, цена которого 1 рубль 65 копеек.
    # Посчитать стоимость упаковки для каждой книги (сколько денег потребуется, чтобы упаковать все экземпляры книги).
    scope :packaging_cost, lambda {
      connection.select_all('SELECT title, amount, ROUND(amount * 1.65, 2) AS pack FROM books')
    }

    # Для одной определенной книги из таблицы book вычислим налог на добавленную стоимость
    # (имя столбца tax) , который включен в цену и составляет k = 20%,
    # а также цену книги (price_tax) без него.
    def tax_price_tax
      transaction do
        update tax: (price / 6).round(2),
               price_tax: (price * 5 / 6).round(2)
      end
    end

    # Для всех книг из таблицы book вычислим налог на добавленную стоимость
    # (имя столбца tax) , который включен в цену и составляет k = 20%,
    # а также цену книги (price_tax) без него.
    def self.all_tax_price_tax
      transaction do
        Book.find_each do |book|
          book.update tax: (book.price / 6).round(2),
                      price_tax: (book.price * 5 / 6).round(2)
        end
      end
    end

    # При анализе продаж книг выяснилось, что наибольшей популярностью пользуются книги Михаила Булгакова,
    # на втором месте книги Сергея Есенина. Исходя из этого решили поднять цену книг Булгакова на 10%,
    # а цену книг Есенина - на 5%. Написать запрос, куда включить автора, название книги и новую цену,
    # последний столбец назвать new_price. Значение округлить до двух знаков после запятой

    scope :price_increase, lambda {
      Book.connection.select_all("SELECT author, title,
         CASE WHEN (author='Булгаков М.А.') THEN ROUND(price*1.1)
         WHEN (author='Есенин С.А.') THEN ROUND(price*1.05)
         ELSE price END AS
         new_price FROM books")
    }

    # Вывести автора, название  и цены тех книг, количество которых меньше 10.

    scope :request1, lambda {
      find_by_sql('SELECT author, title, price FROM books WHERE amount < 10')
    }

    # Вывести название, автора,  цену  и количество всех книг, цена которых меньше 500 или больше 600,
    # а стоимость всех экземпляров этих книг больше или равна 5000.

    scope :request2, lambda {
      find_by_sql('SELECT title, author, price, amount FROM books
   WHERE (price < 500 OR price > 600) AND (price * amount) >= 5000')
    }

    # Вывести название и авторов тех книг, цены которых принадлежат интервалу от 540.50 до 800 (включая границы),
    #  а количество или 2, или 3, или 5, или 7 .
    #
    scope :request3, lambda {
      find_by_sql('SELECT title, author FROM books
                WHERE (price >= 540.50 AND price <= 800) AND amount IN (2, 3, 5, 7)')
    }

    # Вывести  автора и название  книг, количество которых принадлежит интервалу от 2 до 14 (включая границы).
    # Информацию  отсортировать сначала по авторам (в обратном алфавитном порядке), а затем по названиям книг (по алфавиту).

    scope :request4, lambda {
      Book.connection.select_all('SELECT author, title
                    FROM books
                    WHERE (amount BETWEEN 2 AND 14)
                    ORDER BY author DESC, title')
    }

    # Вывести название и автора тех книг, название которых состоит из двух и более слов,
    # а инициалы автора содержат букву «С». Считать, что в названии слова отделяются друг
    # от друга пробелами и не содержат знаков препинания, между фамилией автора и инициалами
    # обязателен пробел, инициалы записываются без пробела в формате: буква, точка, буква, точка.
    # Информацию отсортировать по названию книги в алфавитном порядке.

    scope :request5, lambda {
      Book.connection.select_all("SELECT title, author
                                FROM books
                                WHERE title LIKE '%_ _%' AND author LIKE '%С.%'
                                ORDER BY title ASC")
    }
  end
end
