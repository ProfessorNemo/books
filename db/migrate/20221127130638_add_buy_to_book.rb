# frozen_string_literal: true

class AddBuyToBook < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      ALTER TABLE books ADD COLUMN "buy" integer DEFAULT 0;
      ALTER TABLE books ADD CONSTRAINT buy_check CHECK (buy >= 0);
    SQL
  end

  def self.down
    execute <<~SQL.squish
      ALTER TABLE books DROP COLUMN buy;
    SQL
  end
end
