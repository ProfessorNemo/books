# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_11_29_161125) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", primary_key: "author_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "name_author", limit: 50, null: false
  end

  create_table "back_payments", id: :serial, force: :cascade do |t|
    t.string "person", limit: 30
    t.string "number_plate", limit: 6
    t.string "violation", limit: 50
    t.decimal "sum_fine", precision: 8, scale: 2
    t.date "date_violation"
  end

  create_table "book_editions", primary_key: "book_edition_id", id: :integer, default: nil, force: :cascade do |t|
    t.text "title", null: false
    t.integer "author_id", null: false
    t.integer "genre_id"
    t.decimal "price", precision: 8, scale: 2
    t.integer "amount", null: false
  end

  create_table "books", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.string "author", limit: 50, null: false
    t.decimal "price", precision: 8, scale: 2
    t.integer "amount"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "tax"
    t.float "price_tax"
    t.integer "buy", default: 0
    t.index ["title"], name: "uniq_title", unique: true
    t.check_constraint "buy >= 0", name: "buy_check"
  end

  create_table "cities", primary_key: "city_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "name_city", limit: 50, null: false
  end

  create_table "fines", id: :serial, force: :cascade do |t|
    t.string "person", limit: 30
    t.string "number_plate", limit: 6
    t.string "violation", limit: 50
    t.decimal "sum_fine", precision: 8, scale: 2
    t.date "date_violation"
    t.date "date_payment"
  end

  create_table "genres", primary_key: "genre_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "name_genre", limit: 50, null: false
  end

  create_table "orders", id: :serial, force: :cascade do |t|
    t.string "author", limit: 50
    t.text "title"
    t.decimal "amount"
  end

  create_table "payments", id: :serial, force: :cascade do |t|
    t.string "person", limit: 30
    t.string "number_plate", limit: 6
    t.string "violation", limit: 50
    t.date "date_violation"
    t.date "date_payment"
  end

  create_table "supplies", primary_key: "supply_id", id: :integer, default: nil, force: :cascade do |t|
    t.text "title", null: false
    t.string "author", limit: 50, null: false
    t.decimal "price", precision: 8, scale: 2
    t.integer "amount", null: false
  end

  create_table "traffic_violations", id: :serial, force: :cascade do |t|
    t.string "violation", limit: 50
    t.decimal "sum_fine", precision: 8, scale: 2
  end

  create_table "trips", id: :serial, force: :cascade do |t|
    t.string "person", limit: 30, null: false
    t.string "city", limit: 25, null: false
    t.decimal "per_diem", precision: 8, scale: 2
    t.date "date_first"
    t.date "date_last"
  end

  add_foreign_key "book_editions", "authors", primary_key: "author_id", name: "book_editions_author_id_fkey", on_delete: :cascade
  add_foreign_key "book_editions", "genres", primary_key: "genre_id", name: "book_editions_genre_id_fkey", on_delete: :cascade
end
