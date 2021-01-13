# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_12_132052) do

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "first_name", limit: 32
    t.string "last_name", limit: 32
    t.boolean "delete_flag", default: false
    t.string "email"
    t.integer "age"
    t.string "gender"
    t.string "login"
    t.string "crypted_password"
    t.string "salt", limit: 40
    t.string "home_number", limit: 20
    t.string "mobile_number", limit: 20
    t.string "work_number", limit: 20
    t.string "fax_number", limit: 20
    t.string "other_numbers", limit: 64
    t.string "address", limit: 128
    t.string "city"
    t.string "state"
    t.bigint "pin_code"
    t.string "country"
    t.string "auth_token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
