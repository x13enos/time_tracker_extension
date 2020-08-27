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

ActiveRecord::Schema.define(version: 2020_08_21_184606) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "regexp_of_grouping"
    t.integer "workspace_id"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.index ["project_id", "user_id"], name: "index_projects_users_on_project_id_and_user_id"
    t.index ["user_id", "project_id"], name: "index_projects_users_on_user_id_and_project_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "workspace_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags_time_records", id: false, force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "time_record_id", null: false
    t.index ["tag_id", "time_record_id"], name: "index_tags_time_records_on_tag_id_and_time_record_id"
    t.index ["time_record_id", "tag_id"], name: "index_tags_time_records_on_time_record_id_and_tag_id"
  end

  create_table "time_records", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.text "description", null: false
    t.datetime "time_start"
    t.float "spent_time", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "assigned_date"
  end

  create_table "time_tracker_extension_time_locking_periods", force: :cascade do |t|
    t.integer "workspace_id"
    t.integer "user_id"
    t.date "beginning_of_period"
    t.date "end_of_period"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workspace_id", "user_id"], name: "locking_period_workspace_and_user_index"
  end

  create_table "time_tracker_extension_time_locking_rules", force: :cascade do |t|
    t.integer "workspace_id"
    t.integer "period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email", null: false
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "locale", default: "en"
    t.integer "active_workspace_id"
    t.string "telegram_token"
    t.integer "telegram_id"
    t.index ["telegram_id"], name: "index_users_on_telegram_id", unique: true
    t.index ["telegram_token"], name: "index_users_on_telegram_token", unique: true
  end

  create_table "users_workspaces", force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.integer "role", default: 0
    t.jsonb "notification_rules", default: []
    t.index ["user_id", "workspace_id"], name: "index_users_workspaces_on_user_id_and_workspace_id", unique: true
    t.index ["workspace_id", "user_id"], name: "index_users_workspaces_on_workspace_id_and_user_id", unique: true
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
