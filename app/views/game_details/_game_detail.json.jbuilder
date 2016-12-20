json.extract! game_detail, :id, :player_id, :game_id, :team_id, :hero_id, :solo_kills, :assists, :deaths, :time_spent_dead, :team_colour, :win
json.url game_detail_url(game_detail, format: :json)