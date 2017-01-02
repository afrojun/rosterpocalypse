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

ActiveRecord::Schema.define(version: 20161230100949) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree
  end

  create_table "game_details", force: :cascade do |t|
    t.integer  "game_id",                         null: false
    t.integer  "player_id",                       null: false
    t.integer  "hero_id",                         null: false
    t.integer  "team_id",                         null: false
    t.integer  "solo_kills",      default: 0,     null: false
    t.integer  "assists",         default: 0,     null: false
    t.integer  "deaths",          default: 0,     null: false
    t.integer  "time_spent_dead", default: 0,     null: false
    t.string   "team_colour",                     null: false
    t.boolean  "win",             default: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["game_id"], name: "index_game_details_on_game_id", using: :btree
    t.index ["hero_id"], name: "index_game_details_on_hero_id", using: :btree
    t.index ["player_id"], name: "index_game_details_on_player_id", using: :btree
    t.index ["team_id"], name: "index_game_details_on_team_id", using: :btree
  end

  create_table "games", force: :cascade do |t|
    t.integer  "map_id",        null: false
    t.integer  "tournament_id"
    t.datetime "start_date",    null: false
    t.integer  "duration_s",    null: false
    t.string   "game_hash",     null: false
    t.string   "slug",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["game_hash"], name: "index_games_on_game_hash", unique: true, using: :btree
    t.index ["map_id"], name: "index_games_on_map_id", using: :btree
    t.index ["slug"], name: "index_games_on_slug", unique: true, using: :btree
    t.index ["tournament_id"], name: "index_games_on_tournament_id", using: :btree
  end

  create_table "heroes", force: :cascade do |t|
    t.string   "name",           null: false
    t.string   "internal_name",  null: false
    t.string   "classification"
    t.string   "slug",           null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["internal_name"], name: "index_heroes_on_internal_name", unique: true, using: :btree
    t.index ["name"], name: "index_heroes_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_heroes_on_slug", unique: true, using: :btree
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "accesstoken"
    t.string   "refreshtoken"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "nickname"
    t.string   "image"
    t.string   "phone"
    t.string   "urls"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["user_id"], name: "index_identities_on_user_id", using: :btree
  end

  create_table "leagues", force: :cascade do |t|
    t.string   "name",          null: false
    t.text     "description"
    t.integer  "manager_id",    null: false
    t.integer  "tournament_id", null: false
    t.string   "type",          null: false
    t.string   "slug",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["manager_id"], name: "index_leagues_on_manager_id", using: :btree
    t.index ["name"], name: "index_leagues_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_leagues_on_slug", unique: true, using: :btree
    t.index ["tournament_id"], name: "index_leagues_on_tournament_id", using: :btree
    t.index ["type"], name: "index_leagues_on_type", using: :btree
  end

  create_table "leagues_rosters", id: false, force: :cascade do |t|
    t.integer "league_id", null: false
    t.integer "roster_id", null: false
    t.index ["league_id", "roster_id"], name: "index_leagues_rosters_on_league_id_and_roster_id", using: :btree
    t.index ["roster_id", "league_id"], name: "index_leagues_rosters_on_roster_id_and_league_id", using: :btree
  end

  create_table "managers", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_managers_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_managers_on_user_id", using: :btree
  end

  create_table "maps", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_maps_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_maps_on_slug", unique: true, using: :btree
  end

  create_table "player_alternate_names", force: :cascade do |t|
    t.integer  "player_id"
    t.string   "alternate_name", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["alternate_name"], name: "index_player_alternate_names_on_alternate_name", unique: true, using: :btree
    t.index ["player_id"], name: "index_player_alternate_names_on_player_id", using: :btree
  end

  create_table "players", force: :cascade do |t|
    t.string   "name",       default: "",  null: false
    t.string   "role"
    t.integer  "team_id"
    t.string   "country"
    t.string   "region"
    t.integer  "cost",       default: 100, null: false
    t.string   "slug",                     null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["name"], name: "index_players_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_players_on_slug", unique: true, using: :btree
    t.index ["team_id"], name: "index_players_on_team_id", using: :btree
  end

  create_table "players_rosters", id: false, force: :cascade do |t|
    t.integer "roster_id", null: false
    t.integer "player_id", null: false
    t.index ["player_id", "roster_id"], name: "index_players_rosters_on_player_id_and_roster_id", using: :btree
    t.index ["roster_id", "player_id"], name: "index_players_rosters_on_roster_id_and_player_id", using: :btree
  end

  create_table "rosters", force: :cascade do |t|
    t.string   "name",                   null: false
    t.integer  "manager_id",             null: false
    t.integer  "score",      default: 0, null: false
    t.string   "slug",                   null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.index ["manager_id"], name: "index_rosters_on_manager_id", using: :btree
    t.index ["name"], name: "index_rosters_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_rosters_on_slug", unique: true, using: :btree
  end

  create_table "team_alternate_names", force: :cascade do |t|
    t.integer  "team_id"
    t.string   "alternate_name", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["alternate_name"], name: "index_team_alternate_names_on_alternate_name", unique: true, using: :btree
    t.index ["team_id"], name: "index_team_alternate_names_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "slug",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_teams_on_slug", unique: true, using: :btree
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "region",      null: false
    t.integer  "cycle_hours", null: false
    t.datetime "start_date",  null: false
    t.datetime "end_date"
    t.string   "slug",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["name"], name: "index_tournaments_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_tournaments_on_slug", unique: true, using: :btree
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

  add_foreign_key "game_details", "games"
  add_foreign_key "game_details", "heroes"
  add_foreign_key "game_details", "players"
  add_foreign_key "game_details", "teams"
  add_foreign_key "games", "maps"
  add_foreign_key "games", "tournaments"
  add_foreign_key "identities", "users"
  add_foreign_key "leagues", "managers"
  add_foreign_key "leagues", "tournaments"
  add_foreign_key "managers", "users"
  add_foreign_key "player_alternate_names", "players"
  add_foreign_key "rosters", "managers"
  add_foreign_key "team_alternate_names", "teams"
end
