# frozen_string_literal: true

class CreatePayments < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE payments (
          id serial PRIMARY KEY,
          person VARCHAR(30),
          number_plate varchar(6),
          violation VARCHAR(50),
          date_violation DATE,
          date_payment DATE
      );
    SQL
  end

  def self.down
    execute 'DROP TABLE payments'
  end
end
