class HeroPresenter < BasePresenter
  def hero_stats
    n_games = hero.games.count
    wins = hero.game_details.sum {|g| g.win ? 1 : 0}
    win_percent = n_games > 0 ? ((wins.to_f/n_games.to_f) * 100).ceil : 0

    {
      n_games: n_games,
      wins: wins,
      losses: n_games - wins,
      win_percent: win_percent
    }
  end

  alias hero __getobj__
end