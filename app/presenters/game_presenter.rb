class GamePresenter < BasePresenter
  def game_details
    game.game_details.includes(:player, :hero, :team).order(:team_colour, 'players.slug')
  end

  def teams
    game_details.group_by { |details| details.team.name }
  end

  def winner
    game_details.where("win = true").first.team_colour
  end

  alias game __getobj__
end