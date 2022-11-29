# frozen_string_literal: true

class CreateTrafficViolations < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE traffic_violations (
          id serial PRIMARY KEY,
          violation VARCHAR(50),
          sum_fine NUMERIC(8, 2)
      );
    SQL
  end

  def self.down
    execute 'DROP TABLE traffic_violations'
  end
end
