class GamePresenter < BasePresenter
  def details
    game.game_details.includes(:player, :hero, :team).order(:team_colour, 'players.slug')
  end

  def details_by_team
    details.group_by { |detail| detail.team.name }
  end

  def teams_by_win
    game.game_details.reduce({}) { |memo, detail| memo.merge(detail.win => detail.team.name) }
  end

  alias game __getobj__
end