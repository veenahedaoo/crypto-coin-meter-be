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

ActiveRecord::Schema[8.1].define(version: 2026_03_23_155915) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "coin_lists", force: :cascade do |t|
    t.decimal "ath"
    t.date "ath_date"
    t.decimal "atl", default: "0.0"
    t.date "atl_date"
    t.string "coingecko_symbol", null: false
    t.datetime "created_at", null: false
    t.string "icon_url"
    t.boolean "is_active", default: true, null: false
    t.datetime "last_sync_time", null: false
    t.date "launch_date"
    t.decimal "max_supply"
    t.string "symbol", null: false
    t.string "symbol_name", null: false
    t.decimal "total_supply"
    t.datetime "updated_at", null: false
    t.string "volume"
    t.index ["coingecko_symbol"], name: "index_coin_lists_on_coingecko_symbol", unique: true
    t.index ["symbol_name"], name: "index_coin_lists_on_symbol_name"
  end
end
