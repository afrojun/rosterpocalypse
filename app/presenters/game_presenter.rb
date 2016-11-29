class GamePresenter < BasePresenter
  def game_details
    PlayerGameDetail.where(game: game).includes(:player, :hero)
  end

  alias game __getobj__
end