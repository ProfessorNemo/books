# frozen_string_literal: true

class CreateBooks < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE books (
          id serial PRIMARY KEY,
          title text NOT NULL,
          author varchar(50) NOT NULL,
          price DECIMAL(8, 2),
          amount integer,
          CONSTRAINT uniq_title UNIQUE(title),
          created_at timestamp(6) NOT NULL,
          updated_at timestamp(6) NOT NULL
      );
    SQL
  end

  def self.down
    execute 'DROP TABLE books'
  end
end
