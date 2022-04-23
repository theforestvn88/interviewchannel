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

ActiveRecord::Schema.define(version: 2022_04_23_083956) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "applyings", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "candidate_id", null: false
    t.bigint "interviewer_id", null: false
    t.text "intro"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["candidate_id"], name: "index_applyings_on_candidate_id"
    t.index ["interviewer_id"], name: "index_applyings_on_interviewer_id"
    t.index ["message_id", "candidate_id"], name: "index_applyings_on_message_id_and_candidate_id", unique: true
    t.index ["message_id"], name: "index_applyings_on_message_id"
  end

  create_table "interviews", force: :cascade do |t|
    t.string "note"
    t.datetime "start_time", precision: 6
    t.datetime "end_time", precision: 6
    t.text "code"
    t.boolean "result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "interviewer_id", null: false
    t.bigint "candidate_id", null: false
    t.index ["candidate_id"], name: "index_interviews_on_candidate_id"
    t.index ["interviewer_id"], name: "index_interviews_on_interviewer_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "channel"
    t.text "content"
    t.datetime "expired_at", precision: 6
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "applying_id", null: false
    t.bigint "user_id", null: false
    t.string "content", limit: 150
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["applying_id"], name: "index_replies_on_applying_id"
    t.index ["user_id"], name: "index_replies_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uid"
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "image"
    t.string "github"
    t.text "cv"
    t.text "watch_tags"
  end

  add_foreign_key "applyings", "messages"
  add_foreign_key "applyings", "users", column: "candidate_id"
  add_foreign_key "applyings", "users", column: "interviewer_id"
  add_foreign_key "interviews", "users", column: "candidate_id"
  add_foreign_key "interviews", "users", column: "interviewer_id"
  add_foreign_key "messages", "users"
  add_foreign_key "replies", "applyings"
  add_foreign_key "replies", "users"
end
