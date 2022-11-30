# frozen_string_literal: true

class CreateBookEditions < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      DROP TABLE IF EXISTS book_editions;

      CREATE TABLE book_editions (
          book_edition_id INT GENERATED ALWAYS AS IDENTITY,
          title text NOT NULL,
          author_id INT NOT NULL,
          genre_id INT,
          price NUMERIC(8, 2),
          amount INT NOT NULL,
          PRIMARY KEY(book_edition_id),
          FOREIGN KEY (author_id) REFERENCES authors (author_id) ON DELETE CASCADE,
          FOREIGN KEY (genre_id)  REFERENCES genres (genre_id) ON DELETE CASCADE
      );

      INSERT INTO book_editions(title, author_id, genre_id, price, amount)
      VALUES
           ('Мастер и Маргарита', 1, 1, 670.99, 3),
           ('Белая гвардия', 1, 1, 540.50, 5),
           ('Идиот', 2, 1, 460.00, 10),
           ('Братья Карамазовы', 2, 1, 799.01, 3),
           ('Игрок', 2, 1, 480.50, 10),
           ('Стихотворения и поэмы', 3, 2, 650.00, 15),
           ('Черный человек', 3, 2, 570.20, 6),
           ('Лирика', 4, 1, 518.99, 10),
           ('Герой нашего времени', 5, 2, 570.59, 2),
           ('Доктор Живаго', 5, 1, 740.50, 5),
           ('Остров сокровищ', 6, 3, 850.45, 9),
           ('Чёрная стрела', 6, 3, 720.00, 11),
           ('20000 лье под водой', 7, 3, 1150.24, 4),
           ('Таинственный остров', 7, 3, 925.86, 6),
           ('Записки охотника', 8, 1, 580.34, 12);
    SQL
  end

  def self.down
    execute 'DROP TABLE book_editions'
  end
end
