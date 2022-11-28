# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE orders AS
      SELECT author, title,
      (SELECT ROUND(AVG(amount)) FROM books) AS amount
      FROM books
      WHERE amount < (SELECT AVG(amount) FROM books);

      ALTER TABLE orders ADD COLUMN id serial PRIMARY KEY;
    SQL
  end

  def self.down
    execute 'DROP TABLE orders'
  end
end

# Создать таблицу заказы (orders), куда включить авторов и названия тех книг,
# количество экземпляров которых в таблице book меньше среднего количества
# экземпляров книг в таблице book. В таблицу включить столбец amount, в котором
# для всех книг указать одинаковое значение - среднее количество экземпляров книг
# в таблице books.
