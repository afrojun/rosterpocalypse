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

ActiveRecord::Schema.define(version: 20161116112418) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "map"
    t.datetime "start_date"
    t.integer  "duration_s"
    t.string   "game_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games_players", id: false, force: :cascade do |t|
    t.integer "player_id",                       null: false
    t.integer "game_id",                         null: false
    t.integer "hero_id"
    t.integer "solo_kills"
    t.integer "assists"
    t.integer "deaths"
    t.integer "time_spent_dead"
    t.boolean "win",             default: false
    t.index ["game_id", "player_id"], name: "index_games_players_on_game_id_and_player_id", using: :btree
    t.index ["hero_id"], name: "index_games_players_on_hero_id", using: :btree
    t.index ["player_id", "game_id"], name: "index_games_players_on_player_id_and_game_id", using: :btree
  end

  create_table "heroes", force: :cascade do |t|
    t.string   "name"
    t.string   "internal_name"
    t.string   "classification"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       default: "",  null: false
    t.string   "role"
    t.integer  "team_id"
    t.string   "country"
    t.string   "region"
    t.integer  "cost",       default: 100, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["name"], name: "index_players_on_name", unique: true, using: :btree
    t.index ["team_id"], name: "index_players_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "username",               default: "",    null: false
    t.boolean  "admin",                  default: false, null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

end
