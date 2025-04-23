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

ActiveRecord::Schema[7.0].define(version: 2025_04_23_171551) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.integer "role", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_memberships_on_team_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "status", default: 0
    t.integer "priority", default: 1
    t.datetime "due_date"
    t.bigint "team_id"
    t.bigint "creator_id"
    t.bigint "assigned_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_user_id"], name: "index_tasks_on_assigned_user_id"
    t.index ["creator_id"], name: "index_tasks_on_creator_id"
    t.index ["team_id"], name: "index_tasks_on_team_id"
  end

  create_table "tasks_users", id: false, force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "user_id", null: false
    t.index ["task_id", "user_id"], name: "index_tasks_users_on_task_id_and_user_id", unique: true
    t.index ["task_id"], name: "index_tasks_users_on_task_id"
    t.index ["user_id"], name: "index_tasks_users_on_user_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "creator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_teams_on_creator_id"
  end

  create_table "user_forgot_password_otps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "otp"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_forgot_password_otps_on_user_id"
  end

  create_table "user_otps", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "otp", null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_otps_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "mobile"
    t.string "email"
    t.string "password_digest"
    t.datetime "last_logged_in"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "status", default: "available"
    t.string "designation"
    t.string "experience"
    t.string "skills"
    t.string "location"
    t.boolean "active", default: false
    t.boolean "is_verified", default: false
    t.integer "failed_attempts"
    t.datetime "locked_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "memberships", "teams"
  add_foreign_key "memberships", "users", on_delete: :nullify
  add_foreign_key "tasks", "teams"
  add_foreign_key "tasks", "users", column: "assigned_user_id", on_delete: :nullify
  add_foreign_key "tasks", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "teams", "users", column: "creator_id", on_delete: :nullify
  add_foreign_key "user_forgot_password_otps", "users"
  add_foreign_key "user_otps", "users"
end
