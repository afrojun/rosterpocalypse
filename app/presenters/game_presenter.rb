class GamePresenter < BasePresenter
  def game_details
    game.player_game_details.includes(:player, :hero, :team)
  end

  def teams
    {
      red: game_details.where("team_colour = 'red'").first.team,
      blue: game_details.where("team_colour = 'blue'").first.team,
    }
  end

  def winner
    game_details.where("win = true").first.team_colour
  end

  alias game __getobj__
end