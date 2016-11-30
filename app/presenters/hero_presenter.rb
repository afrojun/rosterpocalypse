class HeroPresenter < BasePresenter
  def hero_stats
    n_games = hero.games.count
    wins = hero.player_game_details.sum {|g| g.win ? 1 : 0}
    losses = n_games - wins
    win_percent = ((wins.to_f/n_games.to_f) * 100).ceil
    {
      n_games: n_games,
      wins: wins,
      losses: losses,
      win_percent: win_percent
    }
  end

  alias hero __getobj__
end