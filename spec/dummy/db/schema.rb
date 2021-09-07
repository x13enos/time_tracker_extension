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

ActiveRecord::Schema.define(version: 2021_07_06_122312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

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

  create_table "reports", force: :cascade do |t|
    t.integer "user_id"
    t.string "uuid"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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
    t.integer "project_id"
    t.integer "user_id", null: false
    t.text "description"
    t.datetime "time_start"
    t.float "spent_time", default: 0.0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "assigned_date"
    t.integer "workspace_id"
  end

  create_table "time_tracker_extension_time_locking_periods", force: :cascade do |t|
    t.integer "workspace_id"
    t.integer "user_id"
    t.date "beginning_of_period"
    t.date "end_of_period"
    t.boolean "approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "telegram_message_id"
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
    t.string "timezone"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
