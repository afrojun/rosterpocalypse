class MapPresenter < BasePresenter
  def map_stats
    n_games = map.games.count
    {
      n_games: n_games,
      ave_game_duration: map.games.sum(&:duration_s)/n_games
    }
  end

  alias map __getobj__
end