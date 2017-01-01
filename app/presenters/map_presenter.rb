class MapPresenter < BasePresenter
  def map_stats
    n_games = map.games.size
    {
      n_games: n_games,
      ave_game_duration: n_games > 0 ? map.games.collect(&:duration_s).sum/n_games : 0
    }
  end

  alias map __getobj__
end