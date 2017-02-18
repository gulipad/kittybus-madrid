# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170218150237) do

  create_table "blackllists", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "favorites", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "stop_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "favorites", ["user_id"], name: "index_favorites_on_user_id"

  create_table "notifications", force: :cascade do |t|
    t.string   "campaign_name"
    t.integer  "user_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "subscription_step"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string   "campaign_name"
    t.integer  "user_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "fb_id",                 limit: 8
    t.datetime "last_message_received"
    t.integer  "state_machine"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.text     "profile"
  end

end
