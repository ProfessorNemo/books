# frozen_string_literal: true

module BlockTrip
  extend ActiveSupport::Concern

  included do
    # Вывести из таблицы trip информацию о командировках тех сотрудников, фамилия которых
    # заканчивается на букву «а», в отсортированном по убыванию даты последнего дня
    # командировки виде. В результат включить столбцы name, city, per_diem, date_first, date_last.
    scope :trip1, lambda {
      connection.select_all("SELECT person, city, per_diem, date_first, date_last
                                FROM trips
                                WHERE person like '%а %'
                                ORDER BY date_last desc")
    }

  # Вывести в алфавитном порядке фамилии и инициалы тех сотрудников, которые были в командировке в Москве.
  scope :trip2, lambda {
    connection.select_all("SELECT DISTINCT person
                                FROM trips
                                WHERE city = 'Москва'
                                ORDER BY person")
  }

  # Для каждого города посчитать, сколько раз сотрудники в нем были.
  # Информацию вывести в отсортированном в алфавитном порядке по названию городов.
  # Вычисляемый столбец назвать Количество.
  scope :trip3, lambda {
    connection.select_all("SELECT city, COUNT(city) AS Количество
                                FROM trips
                                GROUP BY city
                                ORDER BY city")
  }

  # Вывести два города, в которых чаще всего были в командировках сотрудники. Вычисляемый столбец назвать Количество
  scope :trip4, lambda {
    connection.select_all("SELECT city, COUNT(city) as Количество
                                FROM trips
                                GROUP BY city
                                ORDER BY Количество DESC
                                LIMIT 2")
  }

  # Вывести информацию о командировках во все города кроме Москвы и Санкт-Петербурга.
  # (ФИО сотрудников, город, длительность командировки в днях, при этом первый и последний день
  # относится к периоду командировки).Последний столбец назвать Длительность.
  # Информацию вывести в упорядоченном по убыванию длительности поездки.
  scope :trip5, lambda {
    connection.select_all("SELECT person, city,
                              ((date_last::date - date_first::date) + 1) AS Длительность
                              FROM trips
                              WHERE city NOT IN ('Москва', 'Санкт-Петербург')
                              ORDER BY Длительность DESC")
  }

    # Вывести информацию о командировках сотрудника(ов), которые были самыми короткими по времени.
    # В результат включить столбцы name, city, date_first, date_last.
    scope :trip6, lambda {
      connection.select_all("SELECT person, city, date_first, date_last
                                    FROM trips
                                    WHERE
                                        ABS(((date_last::date - date_first::date) + 1)) = (
                                            SELECT
                                                MIN(ABS(((date_last::date - date_first::date) + 1)))
                                            FROM trips)")
    }

    # Вывести информацию о командировках, начало и конец которых относятся к одному месяцу
    # (год может быть любой). В результат включить столбцы name, city, date_first, date_last.
    # Строки отсортировать сначала в алфавитном порядке по названию города, а затем по фамилии сотрудника.
    scope :trip7, lambda {
      connection.select_all("SELECT person, city, date_first, date_last
                                    FROM trips
                                    WHERE to_char(date_first, 'TMMonth') = to_char(date_last, 'TMMonth')
                                    ORDER BY city, person")
    }

    # Вывести название месяца и количество командировок для каждого месяца. Считаем, что командировка относится
    # к некоторому месяцу, если она началась в этом месяце. Информацию вывести сначала в отсортированном по
    # убыванию количества, а потом в алфавитном порядке по названию месяца виде. Название столбцов – Месяц и Количество.
    scope :trip8, lambda {
      connection.select_all("SELECT to_char(date_first, 'TMMonth') AS Месяц,
                                    COUNT(to_char(date_first, 'TMMonth')) AS Количество
                                    FROM trips
                                    GROUP BY to_char(date_first, 'TMMonth')
                                    ORDER BY Количество DESC, Месяц")
    }

    # Вывести сумму суточных (произведение количества дней командировки и размера суточных) для командировок,
    # первый день которых пришелся на февраль или март 2020 года. Значение суточных для каждой командировки
    # занесено в столбец per_diem. Вывести ФИО сотрудника, город, первый день командировки и сумму суточных.
    # Последний столбец назвать Сумма. Информацию отсортировать сначала  в алфавитном порядке по фамилиям
    # сотрудников, а затем по убыванию суммы суточных.
    scope :trip9, lambda {
      find_by_sql("SELECT person, city, date_first,
                                   ROUND(((date_last::date - date_first::date) + 1) * per_diem, 2) AS Сумма
                                FROM trips
                                WHERE ( EXTRACT( MONTH FROM date_first ) = 2 OR EXTRACT( MONTH FROM date_first ) = 3 )
                                      AND ( EXTRACT( YEAR FROM date_first ) = 2020 )
                                ORDER BY person, Сумма DESC")
    }

    # Вывести ФИО и общую сумму суточных, полученных за все командировки для тех сотрудников,
    # которые были в командировках больше чем 3 раза, в отсортированном по убыванию сумм суточных виде.
    # Последний столбец назвать Сумма.
    scope :trip10, lambda {
      connection.select_all("SELECT person,
                                 SUM(((date_last::date - date_first::date) + 1) * per_diem) AS Сумма
                              FROM trips
                              GROUP BY person
                              HAVING COUNT(person) > 3
                              ORDER BY Сумма DESC")
    }
  end
end
