class MapPresenter < BasePresenter
  def map_stats
    ave_duration = map.duration_percentile(50)
    {
      n_games: map.games.size,
      ave_game_duration: ave_duration ? ave_duration.round : 0
    }
  end

  alias map __getobj__
end
