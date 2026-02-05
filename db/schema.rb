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

ActiveRecord::Schema[8.1].define(version: 2026_02_05_031113) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alembic_version", primary_key: "version_num", id: { type: :string, limit: 32 }, force: :cascade do |t|
  end

  create_table "appointments", id: :serial, force: :cascade do |t|
    t.integer "duration_minutes"
    t.float "no_show_probability"
    t.integer "patient_id"
    t.integer "room_id"
    t.integer "staff_id"
    t.datetime "start_time", precision: nil, null: false
    t.index ["id"], name: "ix_appointments_id"
  end

  create_table "newsletter_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "status", default: "active", null: false
    t.datetime "subscribed_at"
    t.string "unsubscribe_token", null: false
    t.datetime "unsubscribed_at"
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["email"], name: "index_newsletter_subscriptions_on_email", unique: true
    t.index ["status"], name: "index_newsletter_subscriptions_on_status"
    t.index ["unsubscribe_token"], name: "index_newsletter_subscriptions_on_unsubscribe_token", unique: true
    t.index ["user_id"], name: "index_newsletter_subscriptions_on_user_id"
  end

  create_table "patients", id: :serial, force: :cascade do |t|
    t.integer "age"
    t.integer "prior_no_shows"
    t.index ["id"], name: "ix_patients_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.boolean "published", default: true, null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "views_count", default: 0, null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["published"], name: "index_posts_on_published"
    t.index ["user_id", "created_at"], name: "index_posts_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
    t.index ["views_count"], name: "index_posts_on_views_count"
  end

  create_table "rooms", id: :serial, force: :cascade do |t|
    t.string "room_type"
  end

  create_table "staff", id: :serial, force: :cascade do |t|
    t.string "role"
    t.time "shift_end"
    t.time "shift_start"
  end

  create_table "users", force: :cascade do |t|
    t.string "avatar"
    t.text "bio"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.datetime "current_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "email"
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at"
    t.string "last_sign_in_ip"
    t.datetime "locked_at"
    t.string "name"
    t.integer "posts_count", default: 0, null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.string "username"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "appointments", "patients", name: "appointments_patient_id_fkey"
  add_foreign_key "appointments", "rooms", name: "appointments_room_id_fkey"
  add_foreign_key "appointments", "staff", name: "appointments_staff_id_fkey"
  add_foreign_key "newsletter_subscriptions", "users"
  add_foreign_key "posts", "users"
end
