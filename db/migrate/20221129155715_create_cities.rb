# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE cities (
          city_id INT GENERATED ALWAYS AS IDENTITY,
          name_city varchar(50) NOT NULL,
          PRIMARY KEY(city_id)
      );

      INSERT INTO cities(name_city)
      VALUES
           ('Москва'),
           ('Санкт-Петербург'),
           ('Владивосток');
    SQL
  end

  def self.down
    execute 'DROP TABLE cities'
  end
end
