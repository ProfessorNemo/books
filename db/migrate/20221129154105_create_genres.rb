# frozen_string_literal: true

class CreateGenres < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      DROP TABLE IF EXISTS genres;

      CREATE TABLE genres (
          genre_id INT GENERATED ALWAYS AS IDENTITY,
          name_genre varchar(50) NOT NULL,
          PRIMARY KEY(genre_id)
      );

      INSERT INTO genres(name_genre)
      VALUES
           ('Роман'),
           ('Поэзия'),
           ('Приключения'),
           ('Детектив');
    SQL
  end

  def self.down
    execute 'DROP TABLE genres'
  end
end
