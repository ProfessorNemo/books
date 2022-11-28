# frozen_string_literal: true

class CreateTrips < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE trips (
          id serial PRIMARY KEY,
          person varchar(30) NOT NULL,
          city varchar(25) NOT NULL,
          per_diem NUMERIC(8, 2),
          date_first date,
          date_last date
      );
    SQL
  end

  def self.down
    execute 'DROP TABLE trips'
  end
end
