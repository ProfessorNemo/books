# frozen_string_literal: true

class CreateAuthors < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      DROP TABLE IF EXISTS authors;

      CREATE TABLE authors (
          author_id INT GENERATED ALWAYS AS IDENTITY,
          name_author varchar(50) NOT NULL,
          PRIMARY KEY(author_id)
      );

      INSERT INTO authors(name_author)
      VALUES
           ('Булгаков М.А.'),
           ('Достоевский Ф.М.'),
           ('Есенин С.А.'),
           ('Пастернак Б.Л.'),
           ('Лермонтов М.Ю.'),
           ('Роберт Льюис Стивенсон'),
           ('Жюль Верн'),
           ('Тургенев И.С.');
    SQL
  end

  def self.down
    execute 'DROP TABLE authors'
  end
end
