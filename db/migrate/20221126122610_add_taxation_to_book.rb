# frozen_string_literal: true

class AddTaxationToBook < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      ALTER TABLE books ADD COLUMN "tax" FLOAT;
      ALTER TABLE books ADD COLUMN "price_tax" FLOAT;
    SQL
  end

  def self.down
    execute <<~SQL.squish
      ALTER TABLE books DROP COLUMN tax;
      ALTER TABLE books DROP COLUMN price_tax;
    SQL
  end
end
