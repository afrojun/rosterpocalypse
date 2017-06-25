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

ActiveRecord::Schema.define(version: 20170625132758) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

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
    t.integer  "map_id",      null: false
    t.integer  "gameweek_id"
    t.datetime "start_date",  null: false
    t.integer  "duration_s",  null: false
    t.string   "game_hash",   null: false
    t.string   "slug",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "match_id"
    t.index ["game_hash"], name: "index_games_on_game_hash", unique: true, using: :btree
    t.index ["gameweek_id"], name: "index_games_on_gameweek_id", using: :btree
    t.index ["map_id"], name: "index_games_on_map_id", using: :btree
    t.index ["match_id"], name: "index_games_on_match_id", using: :btree
    t.index ["slug"], name: "index_games_on_slug", unique: true, using: :btree
    t.index ["start_date"], name: "index_games_on_start_date", using: :btree
  end

  create_table "gameweek_players", force: :cascade do |t|
    t.integer  "gameweek_id",                    null: false
    t.integer  "player_id",                      null: false
    t.text     "points_breakdown"
    t.integer  "points",           default: 0,   null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.float    "value"
    t.integer  "team_id"
    t.float    "pick_rate",        default: 0.0, null: false
    t.float    "efficiency",       default: 0.0, null: false
    t.index ["gameweek_id", "player_id"], name: "index_gameweek_players_on_gameweek_id_and_player_id", using: :btree
    t.index ["gameweek_id"], name: "index_gameweek_players_on_gameweek_id", using: :btree
    t.index ["player_id", "gameweek_id"], name: "index_gameweek_players_on_player_id_and_gameweek_id", using: :btree
    t.index ["player_id"], name: "index_gameweek_players_on_player_id", using: :btree
    t.index ["points"], name: "index_gameweek_players_on_points", using: :btree
  end

  create_table "gameweek_players_rosters", id: false, force: :cascade do |t|
    t.integer "gameweek_roster_id", null: false
    t.integer "gameweek_player_id", null: false
    t.index ["gameweek_player_id", "gameweek_roster_id"], name: "index_gameweek_players_rosters_on_gw_player_id_and_gw_roster_id", using: :btree
    t.index ["gameweek_roster_id", "gameweek_player_id"], name: "index_gameweek_players_rosters_on_gw_roster_id_and_gw_player_id", using: :btree
  end

  create_table "gameweek_rosters", force: :cascade do |t|
    t.integer  "gameweek_id",                     null: false
    t.integer  "roster_id",                       null: false
    t.integer  "available_transfers", default: 1, null: false
    t.text     "roster_snapshot"
    t.integer  "points"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["gameweek_id", "roster_id"], name: "index_gameweek_rosters_on_gameweek_id_and_roster_id", using: :btree
    t.index ["gameweek_id"], name: "index_gameweek_rosters_on_gameweek_id", using: :btree
    t.index ["points"], name: "index_gameweek_rosters_on_points", using: :btree
    t.index ["roster_id", "gameweek_id"], name: "index_gameweek_rosters_on_roster_id_and_gameweek_id", using: :btree
    t.index ["roster_id"], name: "index_gameweek_rosters_on_roster_id", using: :btree
  end

  create_table "gameweek_statistics", force: :cascade do |t|
    t.integer  "gameweek_id",       null: false
    t.text     "dream_team"
    t.text     "top_transfers_in"
    t.text     "top_transfers_out"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["gameweek_id"], name: "index_gameweek_statistics_on_gameweek_id", unique: true, using: :btree
  end

  create_table "gameweeks", force: :cascade do |t|
    t.string   "name",             null: false
    t.integer  "tournament_id"
    t.datetime "start_date",       null: false
    t.datetime "roster_lock_date"
    t.datetime "end_date",         null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["end_date"], name: "index_gameweeks_on_end_date", using: :btree
    t.index ["roster_lock_date"], name: "index_gameweeks_on_roster_lock_date", using: :btree
    t.index ["start_date"], name: "index_gameweeks_on_start_date", using: :btree
    t.index ["tournament_id"], name: "index_gameweeks_on_tournament_id", using: :btree
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

  create_table "league_gameweek_players", force: :cascade do |t|
    t.integer  "league_id",                      null: false
    t.integer  "gameweek_player_id",             null: false
    t.text     "points_breakdown"
    t.integer  "points",             default: 0, null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["gameweek_player_id", "league_id"], name: "idx_league_gameweek_players_on_gameweek_player_id_and_league_id", using: :btree
    t.index ["gameweek_player_id"], name: "index_league_gameweek_players_on_gameweek_player_id", using: :btree
    t.index ["league_id", "gameweek_player_id"], name: "idx_league_gameweek_players_on_league_id_and_gameweek_player_id", using: :btree
    t.index ["league_id"], name: "index_league_gameweek_players_on_league_id", using: :btree
  end

  create_table "leagues", force: :cascade do |t|
    t.string   "name",                                    null: false
    t.text     "description"
    t.integer  "manager_id",                              null: false
    t.integer  "tournament_id",                           null: false
    t.string   "type",                                    null: false
    t.string   "slug",                                    null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.float    "starting_budget",         default: 500.0, null: false
    t.integer  "num_transfers",           default: 1,     null: false
    t.integer  "max_players_per_team",    default: 5,     null: false
    t.boolean  "use_representative_game", default: false, null: false
    t.text     "role_stat_modifiers",                     null: false
    t.text     "required_player_roles",                   null: false
    t.boolean  "featured",                default: false, null: false
    t.index ["featured"], name: "index_leagues_on_featured", using: :btree
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
    t.string   "slug",                                   null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "customer_type",          default: 0,     null: false
    t.string   "stripe_customer_id"
    t.string   "stripe_subscription_id"
    t.string   "stripe_payment_plan_id"
    t.integer  "subscription_status",    default: 0,     null: false
    t.boolean  "email_scores_updated",   default: false, null: false
    t.boolean  "email_new_feature",      default: false, null: false
    t.boolean  "email_join_league",      default: false, null: false
    t.index ["slug"], name: "index_managers_on_slug", unique: true, using: :btree
    t.index ["stripe_customer_id"], name: "index_managers_on_stripe_customer_id", unique: true, using: :btree
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

  create_table "matches", force: :cascade do |t|
    t.integer  "team_1_id",               null: false
    t.integer  "team_2_id",               null: false
    t.integer  "gameweek_id",             null: false
    t.integer  "stage_id"
    t.integer  "best_of",     default: 1, null: false
    t.datetime "start_date",              null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["gameweek_id"], name: "index_matches_on_gameweek_id", using: :btree
    t.index ["stage_id"], name: "index_matches_on_stage_id", using: :btree
    t.index ["start_date"], name: "index_matches_on_start_date", using: :btree
    t.index ["team_1_id"], name: "index_matches_on_team_1_id", using: :btree
    t.index ["team_2_id"], name: "index_matches_on_team_2_id", using: :btree
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
    t.string   "name",       default: "",    null: false
    t.string   "role"
    t.integer  "team_id"
    t.string   "country"
    t.float    "value",      default: 100.0, null: false
    t.string   "slug",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
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
    t.string   "name",                      null: false
    t.integer  "manager_id",                null: false
    t.integer  "tournament_id",             null: false
    t.integer  "score",         default: 0, null: false
    t.string   "slug",                      null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["manager_id"], name: "index_rosters_on_manager_id", using: :btree
    t.index ["name"], name: "index_rosters_on_name", unique: true, using: :btree
    t.index ["score"], name: "index_rosters_on_score", using: :btree
    t.index ["slug"], name: "index_rosters_on_slug", unique: true, using: :btree
    t.index ["tournament_id"], name: "index_rosters_on_tournament_id", using: :btree
  end

  create_table "stages", force: :cascade do |t|
    t.string   "name"
    t.integer  "tournament_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["tournament_id"], name: "index_stages_on_tournament_id", using: :btree
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
    t.string   "name",                       null: false
    t.string   "region"
    t.boolean  "active",     default: false, null: false
    t.string   "slug",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["active"], name: "index_teams_on_active", using: :btree
    t.index ["name"], name: "index_teams_on_name", unique: true, using: :btree
    t.index ["region"], name: "index_teams_on_region", using: :btree
    t.index ["slug"], name: "index_teams_on_slug", unique: true, using: :btree
  end

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",        null: false
    t.string   "region",      null: false
    t.integer  "cycle_hours", null: false
    t.datetime "start_date",  null: false
    t.datetime "end_date",    null: false
    t.string   "slug",        null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["end_date"], name: "index_tournaments_on_end_date", using: :btree
    t.index ["name"], name: "index_tournaments_on_name", unique: true, using: :btree
    t.index ["slug"], name: "index_tournaments_on_slug", unique: true, using: :btree
    t.index ["start_date"], name: "index_tournaments_on_start_date", using: :btree
  end

  create_table "transfers", force: :cascade do |t|
    t.integer  "gameweek_roster_id", null: false
    t.integer  "player_in_id",       null: false
    t.integer  "player_out_id",      null: false
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["gameweek_roster_id"], name: "index_transfers_on_gameweek_roster_id", using: :btree
    t.index ["player_in_id"], name: "index_transfers_on_player_in_id", using: :btree
    t.index ["player_out_id"], name: "index_transfers_on_player_out_id", using: :btree
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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["username"], name: "index_users_on_username", unique: true, using: :btree
  end

  add_foreign_key "game_details", "games"
  add_foreign_key "game_details", "heroes"
  add_foreign_key "game_details", "players"
  add_foreign_key "game_details", "teams"
  add_foreign_key "games", "gameweeks"
  add_foreign_key "games", "maps"
  add_foreign_key "games", "matches"
  add_foreign_key "gameweek_players", "gameweeks"
  add_foreign_key "gameweek_players", "players"
  add_foreign_key "gameweek_rosters", "gameweeks"
  add_foreign_key "gameweek_rosters", "rosters"
  add_foreign_key "gameweek_statistics", "gameweeks"
  add_foreign_key "gameweeks", "tournaments"
  add_foreign_key "identities", "users"
  add_foreign_key "league_gameweek_players", "gameweek_players"
  add_foreign_key "league_gameweek_players", "leagues"
  add_foreign_key "leagues", "managers"
  add_foreign_key "leagues", "tournaments"
  add_foreign_key "managers", "users"
  add_foreign_key "matches", "gameweeks"
  add_foreign_key "matches", "stages"
  add_foreign_key "player_alternate_names", "players"
  add_foreign_key "rosters", "managers"
  add_foreign_key "rosters", "tournaments"
  add_foreign_key "stages", "tournaments"
  add_foreign_key "team_alternate_names", "teams"
  add_foreign_key "transfers", "gameweek_rosters"
end
