# frozen_string_literal: true

class CreateSupplies < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      DROP TABLE IF EXISTS supplies;

      CREATE TABLE supplies (
          supply_id INT GENERATED ALWAYS AS IDENTITY,
          title text NOT NULL,
          author varchar(50) NOT NULL,
          price NUMERIC(8, 2),
          amount INT NOT NULL,
          PRIMARY KEY(supply_id)
      );

      INSERT INTO supplies(title, author, price, amount)
      VALUES
           ('Доктор Живаго', 'Пастернак Б.Л.', 618.99, 3),
           ('Черный человек', 'Есенин С.А.', 570.20, 6),
           ('Евгений Онегин', 'Пушкин А.С.', 440.80, 5),
           ('Идиот', 'Достоевский Ф.М.', 360.80, 3);
    SQL
  end

  def self.down
    execute 'DROP TABLE supplies'
  end
end
