# frozen_string_literal: true

module Two
  module Edition
    extend ActiveSupport::Concern

    included do
      # Вывести название, жанр и цену тех книг, количество которых больше 8, в отсортированном по убыванию цены виде.
      scope :request1, lambda {
        connection.select_all('SELECT title, name_genre, price
                                    FROM book_editions AS b
                                    INNER JOIN genres AS g
                                        ON b.genre_id = g.genre_id
                                    WHERE b.amount > 8
                                    ORDER BY 3 DESC')
      }

      # Вывести все жанры, которые не представлены в книгах на складе.
      scope :request2, lambda {
        connection.select_all('SELECT name_genre
                                    FROM genres AS g
                                    LEFT JOIN book_editions AS b
                                        ON g.genre_id = b.genre_id
                                    WHERE title IS NULL')
      }

     # Необходимо в каждом городе провести выставку книг каждого автора в течение 2020 года.
     # Дату проведения выставки выбрать случайным образом. Создать запрос, который выведет город,
     # автора и дату проведения выставки. Последний столбец назвать Дата. Информацию вывести,
     # отсортировав сначала в алфавитном порядке по названиям городов, а потом по убыванию дат
     # проведения выставок.
     scope :request3, lambda {
                        connection.select_all("SELECT
                                  name_city,
                                  name_author,
                                  ('2020-01-01'::date + (RANDOM() * INTERVAL '365 days'))::date AS Дата
                              FROM cities CROSS JOIN authors
                              ORDER BY name_city ASC, Дата DESC")
                      }

      # Вывести информацию о книгах (жанр, книга, автор), относящихся к жанру, включающему слово «Роман» в
      # отсортированном по названиям книг виде.
      scope :request4, lambda {
        connection.select_all("SELECT name_genre, title, name_author
                                    FROM
                                        authors AS a
                                        INNER JOIN book_editions AS b ON a.author_id = b.author_id
                                        INNER JOIN genres AS g ON g.genre_id = b.genre_id
                                    WHERE name_genre LIKE '%Роман%'
                                    ORDER BY title")
      }

      # Посчитать количество экземпляров книг каждого автора из таблицы author. Вывести тех авторов,
      # количество книг которых меньше 10, в отсортированном по возрастанию количества виде.
      # Последний столбец назвать Количество.
      scope :request5, lambda {
        connection.select_all("SELECT name_author, SUM(amount) AS Количество
                                    FROM
                                        authors LEFT JOIN book_editions
                                        ON authors.author_id = book_editions.author_id
                                    GROUP BY name_author
                                    HAVING SUM(amount) < 10 OR SUM(amount) IS NULL
                                    ORDER BY Количество ASC")
      }

      # Вывести авторов, общее количество книг которых на складе максимально.
      scope :request6, lambda {
        connection.select_all("SELECT name_author, SUM(amount) as Количество
                                      FROM
                                          authors AS a INNER JOIN book_editions AS b
                                          on a.author_id = b.author_id
                                      GROUP BY name_author
                                      HAVING SUM(amount) =
                                           (/* вычисляем максимальное из общего количества книг каждого автора */
                                            SELECT MAX(sum_amount) AS max_sum_amount
                                            FROM
                                                (/* считаем количество книг каждого автора */
                                                  SELECT author_id, SUM(amount) AS sum_amount
                                                  FROM book_editions GROUP BY author_id
                                                ) query_in
                                            )")
      }

      # Вывести в алфавитном порядке всех авторов, которые пишут только в одном жанре.
      scope :request7, lambda {
        connection.select_all("SELECT name_author
                              FROM
                                  authors
                                  INNER JOIN book_editions USING(author_id)
                              GROUP BY
                                  name_author
                              HAVING
                                  COUNT(distinct(genre_id)) = 1
                              ORDER BY
                                  name_author;
                              ")
      }

      # Вывести информацию о книгах (название книги, ФИО автора, название жанра, цену за все экземпляры и
      # количество экземпляров книги), написанных в самых популярных жанрах, в отсортированном в алфавитном
      # порядке по названию книг виде. Самым популярным считать жанр, общее количество экземпляров книг которого
      # на складе максимально.
      scope :request8, lambda {
        connection.select_all("SELECT title, name_author, name_genre, SUM(price * amount) AS sum_price, amount
                                FROM
                                    authors AS a
                                    INNER JOIN book_editions AS b ON a.author_id = b.author_id
                                    INNER JOIN genres AS g ON b.genre_id = g.genre_id
                                GROUP BY title, name_author, name_genre, amount, g.genre_id
                                HAVING g.genre_id IN
                                         (/* выбираем автора, если он пишет книги в самых популярных жанрах*/
                                          SELECT query_in_1.genre_id
                                          FROM
                                              ( /* выбираем id жанра и количество произведений, относящихся к нему */
                                                SELECT genre_id, SUM(amount) AS sum_amount
                                                FROM book_editions
                                                GROUP BY genre_id
                                               )query_in_1
                                          INNER JOIN
                                              ( /* выбираем запись, в которой указан id жанра с максимальным количеством книг */
                                                SELECT genre_id, SUM(amount) AS sum_amount
                                                FROM book_editions
                                                GROUP BY genre_id
                                                ORDER BY sum_amount DESC
                                                LIMIT 1
                                               ) query_in_2
                                          ON query_in_1.sum_amount= query_in_2.sum_amount
                                         )
                                ORDER BY title")
      }

      # Если в таблицах supplies и book_editions есть одинаковые книги, которые имеют равную цену,
      # вывести их название и автора, а также посчитать общее количество экземпляров книг
      # в таблицах supplies и book_editions, столбцы назвать Название, Автор и Количество.
      scope :request9, lambda {
        connection.select_all("SELECT b.title AS Название,
                                      name_author AS Автор,
                                      SUM(s.amount) + SUM(b.amount) AS Количество
                               FROM
                                   authors AS a
                                   INNER JOIN book_editions AS b USING (author_id)
                                   INNER JOIN supplies AS s ON b.title = s.title
                                                        AND a.name_author = s.author
                                                        AND s.price = b.price
                                   GROUP BY b.title, name_author")
      }
    end
  end
end
