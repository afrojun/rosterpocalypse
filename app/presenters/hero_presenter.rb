class HeroPresenter < BasePresenter
  def details
    @details ||= hero.game_details
  end

  def hero_stats
    n_games = details.size
    wins = details.select(&:win).size
    win_percent = n_games.positive? ? ((wins.to_f / n_games.to_f) * 100).round(2) : 0

    {
      n_games: n_games,
      wins: wins,
      losses: n_games - wins,
      win_percent: win_percent
    }
  end

  alias hero __getobj__
end
