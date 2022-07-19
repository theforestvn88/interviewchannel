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

ActiveRecord::Schema.define(version: 2022_07_19_075815) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "interview_state", ["wait", "in_process", "finish", "canceled"]
  create_enum "stone_type", ["comment", "interview", "assignment", "apply"]

  create_table "applyings", force: :cascade do |t|
    t.bigint "message_id", null: false
    t.bigint "candidate_id", null: false
    t.bigint "interviewer_id", null: false
    t.text "intro"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "open", default: true
    t.index ["candidate_id"], name: "index_applyings_on_candidate_id"
    t.index ["interviewer_id"], name: "index_applyings_on_interviewer_id"
    t.index ["message_id", "candidate_id"], name: "index_applyings_on_message_id_and_candidate_id", unique: true
    t.index ["message_id"], name: "index_applyings_on_message_id"
  end

  create_table "assignments", force: :cascade do |t|
    t.bigint "interview_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["interview_id", "user_id"], name: "index_assignments_on_interview_id_and_user_id", unique: true
    t.index ["interview_id"], name: "index_assignments_on_interview_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "friend_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "custom_name", null: false
    t.index ["user_id", "friend_id"], name: "index_contacts_on_user_id_and_friend_id", unique: true
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "engagings", force: :cascade do |t|
    t.bigint "applying_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["applying_id", "user_id"], name: "index_engagings_on_applying_id_and_user_id", unique: true
    t.index ["applying_id"], name: "index_engagings_on_applying_id"
    t.index ["user_id"], name: "index_engagings_on_user_id"
  end

  create_table "interviews", force: :cascade do |t|
    t.string "note"
    t.datetime "start_time", precision: 6
    t.datetime "end_time", precision: 6
    t.text "code"
    t.boolean "result"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "candidate_id", null: false
    t.bigint "applying_id"
    t.bigint "owner_id", null: false
    t.string "title"
    t.integer "round", default: 1
    t.bigint "head_id"
    t.enum "state", default: "wait", null: false, enum_type: "interview_state"
    t.index ["applying_id"], name: "index_interviews_on_applying_id"
    t.index ["candidate_id"], name: "index_interviews_on_candidate_id"
    t.index ["head_id"], name: "index_interviews_on_head_id"
    t.index ["owner_id"], name: "index_interviews_on_owner_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "channel"
    t.text "content"
    t.datetime "expired_at", precision: 6
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "views", default: 0
    t.integer "applyings_count"
    t.string "title"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "replies", force: :cascade do |t|
    t.bigint "applying_id", null: false
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.enum "milestone", default: "comment", null: false, enum_type: "stone_type"
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
    t.json "social"
    t.string "brief_intro"
    t.integer "messages_count", default: 0, null: false
    t.integer "interviews_count", default: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "applyings", "messages"
  add_foreign_key "applyings", "users", column: "candidate_id"
  add_foreign_key "applyings", "users", column: "interviewer_id"
  add_foreign_key "contacts", "users"
  add_foreign_key "contacts", "users", column: "friend_id"
  add_foreign_key "engagings", "applyings"
  add_foreign_key "engagings", "users"
  add_foreign_key "interviews", "applyings"
  add_foreign_key "interviews", "interviews", column: "head_id"
  add_foreign_key "interviews", "users", column: "candidate_id"
  add_foreign_key "interviews", "users", column: "owner_id"
  add_foreign_key "messages", "users"
  add_foreign_key "replies", "applyings"
  add_foreign_key "replies", "users"
end
