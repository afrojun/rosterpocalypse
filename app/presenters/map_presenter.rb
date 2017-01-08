class MapPresenter < BasePresenter
  def map_stats
    {
      n_games: map.games.size,
      ave_game_duration: map.duration_percentile(50).round
    }
  end

  alias map __getobj__
end