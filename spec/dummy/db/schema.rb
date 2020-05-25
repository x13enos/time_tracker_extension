# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_24_123118) do

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
    t.integer "role"
    t.string "locale", default: "en"
    t.integer "active_workspace_id"
  end

  create_table "users_workspaces", id: false, force: :cascade do |t|
    t.bigint "workspace_id", null: false
    t.bigint "user_id", null: false
    t.index ["user_id", "workspace_id"], name: "index_users_workspaces_on_user_id_and_workspace_id"
    t.index ["workspace_id", "user_id"], name: "index_users_workspaces_on_workspace_id_and_user_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

