# frozen_string_literal: true

module BlockThree
  extend ActiveSupport::Concern

  included do
    # Уменьшить на 10% цену тех книг в таблице book, количество которых принадлежит интервалу от 5 до 10, включая границы.
    # Book.where('amount > 5 AND amount < 10')
    scope :request18, lambda {
      connection.select_all('UPDATE books
                                  SET price = ROUND(0.9 * price)
                                  WHERE amount BETWEEN 5 AND 10')
    }

    #  В таблице book необходимо скорректировать значение для покупателя в столбце buy таким образом,
    # чтобы оно не превышало количество экземпляров книг, указанных в столбце amount.
    # А цену тех книг, которые покупатель не заказывал, снизить на 10%.
    scope :request19, lambda {
      Book.connection.select_all("UPDATE books
         SET buy = CASE
                   WHEN (buy = 0) THEN amount
                   ELSE buy END,
           price = CASE
                   WHEN (buy = 0) THEN ROUND(price * 0.9, 2)
                   ELSE price END")
    }
  end
end
