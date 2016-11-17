class GameStatsIngestionService

  def self.populate_from_json json
    if json
      game = Game.find_or_create_by(game_hash: json["unique_id"]) do |g|
               g.map = json["map_name"]
               g.start_date = json["start_date_utc"]
               g.duration_s = json["duration"]
             end

      json["player_details"].each do |_, player_detail|
        player = Player.find_or_create_by(name: player_detail["name"])
        hero = Hero.find_or_create_by(internal_name: player_detail["hero"])

        player_game = PlayerGameDetail.create(
          player: player,
          game: game,
          hero: hero,
          solo_kills: player_detail["SoloKill"],
          assists: player_detail["Assists"],
          deaths: player_detail["Deaths"],
          time_spent_dead: player_detail["TimeSpentDead"],
          win: player_detail["result"] == "win" ? true : false
        )
      end
    else
      Rails.logger.warn "No json input provided!"
    end
  end

end