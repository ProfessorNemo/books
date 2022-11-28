# frozen_string_literal: true

module BlockTwo
  extend ActiveSupport::Concern

  included do
    # Отобрать различные (уникальные) элементы столбца amount таблицы book.
    scope :request6, lambda {
      connection.select_all('SELECT DISTINCT amount FROM books')
    }

    # Посчитать, количество различных книг и количество экземпляров книг каждого автора,
    # хранящихся на складе.  Столбцы назвать Автор, Различных_книг и Количество_экземпляров соответственно.
    scope :request7, lambda {
      connection.select_all('SELECT author AS Автор,
                                  count(amount) AS Различных_книг,
                                  sum(amount) AS Количество_экземпляров
                                  FROM books
                                  GROUP BY author')
    }

    # Вывести фамилию и инициалы автора, минимальную, максимальную и среднюю цену книг каждого автора.
    # Вычисляемые столбцы назвать Минимальная_цена, Максимальная_цена и Средняя_цена соответственно.
    scope :request8, lambda {
      connection.select_all('SELECT author,
                                  ROUND(MIN(price)) AS Минимальная_цена,
                                  ROUND(MAX(price)) AS Максимальная_цена,
                                  ROUND(AVG(price)) AS Средняя_цена
                                  FROM books
                                  GROUP BY author
                                  ORDER BY author')
    }

    # Для каждого автора вычислить суммарную стоимость книг (имя столбца Стоимость),
    # а также вычислить налог на добавленную стоимость  для полученных сумм (имя столбца НДС),
    # который включен в стоимость и составляет k = 20%, а также стоимость книг (Стоимость_без_НДС) без него.
    scope :request9, lambda {
      connection.select_all('SELECT author,
                                  SUM(price*amount) AS Стоимость,
                                  ROUND(SUM(price*amount*20/120)) AS НДС,
                                  ROUND(SUM(price*amount*100/120)) AS Стоимость_без_НДС
                                  FROM books
                                  GROUP BY author
                                  ORDER BY author')
    }

    # Вывести  цену самой дешевой книги, цену самой дорогой и среднюю цену уникальных книг на складе.
    # Названия столбцов Минимальная_цена, Максимальная_цена, Средняя_цена соответственно.
    scope :request10, lambda {
      connection.select_all('SELECT MIN(price) AS Минимальная_цена,
                                    MAX(price) AS Максимальная_цена,
                                    ROUND(AVG(price)) AS Средняя_цена
                                    FROM books')
    }

    # Вычислить среднюю цену и суммарную стоимость тех книг, количество экземпляров которых
    # принадлежит интервалу от 5 до 14, включительно. Столбцы назвать Средняя_цена и Стоимость.
    scope :request11, lambda {
      connection.select_all('SELECT ROUND(AVG(price)) AS Средняя_цена,
                                    ROUND(SUM(price*amount)) AS Стоимость
                                    FROM books
                                    WHERE amount BETWEEN 5 AND 14')
    }

    # Посчитать стоимость всех экземпляров каждого автора без учета книг «Идиот» и «Белая гвардия».
    # В результат включить только тех авторов, у которых суммарная стоимость книг
    # (без учета книг «Идиот» и «Белая гвардия») более 5000 руб. Вычисляемый столбец назвать Стоимость.
    # Результат отсортировать по убыванию стоимости.
    scope :request12, lambda {
      connection.select_all("SELECT author,
                                  SUM(price*amount) AS Стоимость
                                  FROM books
                                  WHERE title NOT IN ('Идиот', 'Белая гвардия')
                                  GROUP BY author
                                  HAVING SUM(price*amount) > 5000
                                  ORDER BY Стоимость DESC")
    }
    #  Вывести информацию (автора, название и цену) о  книгах, цены которых меньше или равны средней цене книг на складе.
    # Информацию вывести в отсортированном по убыванию цены виде. Среднее вычислить как среднее по цене книги.
    scope :request13, lambda {
      connection.select_all("SELECT author, title, price
                                                    FROM books
                                                    WHERE price <= (
                                                             SELECT AVG(price)
                                                             FROM books
                                                          )
                                                    ORDER BY price DESC")
    }

    #  Вывести информацию (автора, название и цену) о тех книгах, цены которых превышают минимальную цену книги
    # на складе не более чем на 150 рублей в отсортированном по возрастанию цены виде.
    scope :request14, lambda {
      connection.select_all("SELECT author, title, price
                                    FROM books
                                    WHERE (price - (SELECT MIN(price) FROM books)) <= 150
                                    ORDER BY price ASC")
    }

    #  Вывести информацию (автора, книгу и количество) о тех книгах, количество экземпляров которых в таблице book не дублируется.
    scope :request15, lambda {
      connection.select_all("SELECT author, title, amount
                                    FROM books
                                    WHERE amount IN (
                                            SELECT amount
                                            FROM books
                                            GROUP BY amount
                                            HAVING COUNT(amount) = 1
                                          )")
    }

    # Вывести информацию о книгах(автор, название, цена), цена которых меньше самой большой из минимальных цен,
    # вычисленных для каждого автора.
    scope :request16, lambda {
      connection.select_all("SELECT author, title, price
                                    FROM books
                                    WHERE price < ANY (
                                            SELECT MIN(price)
                                            FROM books
                                            GROUP BY author
                                          )")
    }

    #  Посчитать сколько и каких экземпляров книг нужно заказать поставщикам,
    # чтобы на складе стало одинаковое количество экземпляров каждой книги,
    # равное значению самого большего количества экземпляров одной книги на складе.
    # Вывести название книги, ее автора, текущее количество экземпляров на складе и количество
    # заказываемых экземпляров книг. Последнему столбцу присвоить имя Заказ. В результат не включать книги,
    # которые заказывать не нужно.
    scope :request17, lambda {
      connection.select_all("SELECT title, author, amount,
                                    (SELECT ABS(amount - (SELECT MAX(amount) FROM books ))) AS Заказ
                                    FROM books
                                    WHERE amount < (SELECT MAX(amount) FROM books)")
    }
  end
end
