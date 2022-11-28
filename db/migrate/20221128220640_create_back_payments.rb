class CreateBackPayments < ActiveRecord::Migration[6.1]
  def self.up
    execute <<~SQL.squish
      CREATE TABLE back_payments AS
      SELECT person, number_plate, violation, sum_fine, date_violation
      FROM fines
      WHERE date_payment IS NULL;

      ALTER TABLE back_payments ADD COLUMN id serial PRIMARY KEY;
    SQL
  end

  def self.down
    execute 'DROP TABLE back_payments'
  end
end

#  Создать новую таблицу back_payments, куда внести информацию о неоплаченных штрафах
# (ФИО, номер машины, нарушение, сумму штрафа  и  дату нарушения) из таблицы fine.
