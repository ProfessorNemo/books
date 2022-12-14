# frozen_string_literal: true

module Two
  module UpdateBlock
    extend ActiveSupport::Concern

    included do
      # Включить новых авторов в таблицу authors с помощью запроса на добавление,
      # а затем вывести все данные из таблицы author.  Новыми считаются авторы,
      # которые есть в таблице supply, но нет в таблице author
      scope :request10, lambda {
                          connection.select_all('INSERT INTO authors (name_author)
                                        SELECT supplies.author
                                        FROM
                                            authors
                                            RIGHT JOIN supplies on authors.name_author = supplies.author
                                        WHERE name_author IS Null')
                        }

     # Добавить новые книги из таблицы supplies в таблицу book_editions.
     # Затем вывести для просмотра таблицу book.
     scope :request11, lambda {
       connection.select_all('INSERT INTO book_editions (title, author_id, price, amount)
                                    SELECT title, author_id, price, amount
                                    FROM
                                        authors
                                        INNER JOIN supplies ON authors.name_author = supplies.author
                                    WHERE amount <> 0')
     }

     # (Например) Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги
     # «Остров сокровищ» Стивенсона - «Приключения».
     scope :request12, lambda {
       connection.select_all("UPDATE book_editions b
                                  SET genre_id =
                                      CASE
                                          WHEN (b.book_edition_id = 16 OR b.book_edition_id = 18 OR b.book_edition_id = 10)
                                          THEN (SELECT genre_id FROM genres WHERE name_genre = 'Роман')
                                          WHEN (b.book_edition_id = 17 OR b.book_edition_id = 19)
                                          THEN (SELECT genre_id FROM genres WHERE name_genre = 'Поэзия')
                                          ELSE b.genre_id
                                      END")
     }

     # Убрать повторяющиеся книги, посчитать суммарную цену, стоимость  одноой книги и общее количество экземпяров
     # каждой книги.
     scope :request13, lambda {
       connection.select_all("SELECT title,
                                     SUM(amount) AS Количество,
                                     SUM(price) AS Стоимость_коллекции,
                                     ROUND(SUM(price) / SUM(amount), 2) AS Цена_одной_книги
                                     FROM book_editions
                                     GROUP BY title
                                     ORDER BY title")
     }

     # Удалить всех авторов и все их книги, общее количество книг которых меньше 20.
     scope :request14, lambda {
       connection.select_all("DELETE FROM authors
                                    WHERE author_id IN
                                        (
                                        SELECT author_id
                                        FROM book_editions
                                        GROUP BY author_id
                                        HAVING SUM(amount) < 20)")
     }

     #  Удалить все жанры, к которым относится меньше 4-х книг. В таблице book_editions
     # для этих жанров установить значение Null.
     scope :request15, lambda {
       connection.select_all("DELETE FROM genres
                                  WHERE genre_id in (SELECT genre_id
                                                     FROM book_editions
                                                     GROUP BY genre_id
                                                     HAVING COUNT(amount) < 4)")
     }
     # Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов.
     # В запросе для отбора авторов использовать полное название жанра, а не его id.
     scope :request16, lambda {
       connection.select_all("DELETE FROM authors a
                                  USING
                                      authors
                                      INNER JOIN book_editions USING(author_id)
                                  WHERE book_editions.genre_id IN
                                                    (SELECT genre_id
                                                     FROM genres
                                                     WHERE name_genre = 'Поэзия')")
     }

      # Для книг, которые уже есть на складе (в таблице book_editions), но по другой цене, чем в поставке (supplies),
      # необходимо в таблице book_editions увеличить количество на значение, указанное в поставке, и пересчитать цену.
      # А в таблице supply обнулить количество этих книг
      scope :request17, lambda {
        connection.select_all("WITH supply_values AS (
                                      /*Получаем количество и цену книг из supplies до обнуления*/
                                      SELECT
                                        authors.author_id,
                                        supplies.author,
                                        supplies.title,
                                        supplies.amount,
                                        supplies.price
                                      FROM
                                        book_editions
                                        JOIN authors USING (author_id)
                                        JOIN supplies ON book_editions.title = supplies.title
                                          AND name_author = supplies.author
                                          AND book_editions.price <> supplies.price
                                    ),
                                    cte AS (
                                      /*Обнуляем значение amount в supplies из рассчитанной таблицы supply_values*/
                                      UPDATE
                                        supplies
                                      SET
                                        amount = 0
                                      FROM
                                        supply_values sv
                                      WHERE
                                        supplies.author = sv.author
                                        AND supplies.title = sv.title)
                                    UPDATE
                                      book_editions
                                    SET
                                      price = (book_editions.price * book_editions.amount + sv.price * sv.amount) / (book_editions.amount + sv.amount),
                                      amount = book_editions.amount + sv.amount
                                    FROM
                                      supply_values sv
                                    WHERE
                                      book_editions.title = sv.title AND
                                      book_editions.author_id = sv.author_id
                                    RETURNING
                                      *")
      }
    end
  end
end
