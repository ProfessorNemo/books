# frozen_string_literal: true

# запросы в данном модуле выполнять в хронологическом порядке с первого по последний
module One
  module BlockFine
    extend ActiveSupport::Concern

    included do
      # Для тех, кто уже оплатил штраф, вывести информацию о том, изменялась ли стандартная сумма штрафа
      scope :fine1, lambda {
        connection.select_all("SELECT  f.person, f.number_plate, f.violation,
                            CASE
                                WHEN (f.sum_fine = tv.sum_fine) THEN 'Стандартная сумма штрафа'
                                WHEN (f.sum_fine < tv.sum_fine) THEN 'Уменьшенная сумма штрафа'
                                ELSE 'Увеличенная сумма штрафа'
                            END AS description
                                FROM fines f, traffic_violations tv
                                WHERE tv.violation = f.violation and f.sum_fine IS NOT Null")
      }

    # Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными из
    # таблицы traffic_violations. При этом суммы заносить только в пустые поля столбца sum_fine.
    scope :fine2, lambda {
      connection.select_all("UPDATE fines
                               SET sum_fine = tv.sum_fine
                               FROM traffic_violations tv
                               WHERE fines.violation = tv.violation
                            AND fines.sum_fine IS NULL")
    }

    # Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили
    # одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены
    # они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру
    # машины и, наконец, по нарушению.
    scope :fine3, lambda {
      connection.select_all("SELECT person, number_plate, violation
                              FROM fines
                              GROUP by person, number_plate, violation
                              HAVING (COUNT(violation) >= 2) AND (COUNT(number_plate) >= 2)
                              ORDER by person, number_plate, violation")
    }

    #  В таблице fines увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей.
    scope :fine4, lambda {
      connection.select_all("UPDATE fines
                                  SET sum_fine = sum_fine * 2
                                  FROM (
                                        SELECT person, number_plate, violation
                                        FROM fines
                                        GROUP BY person, number_plate, violation
                                        HAVING COUNT(*) >= 2
                                        ) AS dv
                                   WHERE date_payment IS NULL
                                      AND (fines.person = dv.person)
                                     AND (fines.violation = dv.violation)")
    }

    # Водители оплачивают свои штрафы. В таблице payments занесены даты их оплаты.
    # Необходимо:
    #   в таблицу fines занести дату оплаты соответствующего штрафа из таблицы payments;
    #   уменьшить начисленный штраф в таблице fines в два раза (только для тех штрафов,
    #   информация о которых занесена в таблицу payment), если оплата произведена не позднее
    #   20 дней со дня нарушения.
    scope :fine5part1, lambda {
      connection.select_all("UPDATE fines
                              SET date_payment = p.date_payment
                              FROM payments AS p
                           WHERE
                              fines.person = p.person AND
                              fines.number_plate = p.number_plate AND
                              fines.violation = p.violation AND
                              fines.date_violation = p.date_violation AND
                              fines.date_payment IS NULL")
    }

    scope :fine5part2, lambda {
      connection.select_all("UPDATE fines
                              SET sum_fine = CASE
                                                WHEN (date_payment::date - date_violation::date) <= 20
                                                THEN 0.5 * sum_fine
                                                ELSE sum_fine
                                             END
                              WHERE date_payment IS NOT NULL")
    }

    #  Создать новую таблицу back_payments, куда внести информацию о неоплаченных штрафах
    # (ФИО, номер машины, нарушение, сумму штрафа  и  дату нарушения) из таблицы fine.
    scope :fine6, lambda {
      connection.select_all("CREATE TABLE back_payments AS
                                SELECT person, number_plate, violation, sum_fine, date_violation
                                FROM fines
                                WHERE date_payment IS NULL")
    }

    #  Удалить из таблицы fines информацию о нарушениях, совершенных раньше 1 февраля 2020 года.
    scope :fine7, lambda {
      connection.select_all("DELETE FROM fines
                              WHERE (EXTRACT( MONTH FROM date_violation ) = 1 AND
                              EXTRACT( YEAR FROM date_violation ) = 2020)
                              OR EXTRACT( YEAR FROM date_violation ) < 2020")
    }
    end
  end
end
