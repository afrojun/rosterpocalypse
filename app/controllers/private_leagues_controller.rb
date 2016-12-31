class PrivateLeaguesController < LeaguesController

  private

  def set_private_league
    @league = PrivateLeague.find(params[:id])
  end

  def league_class
    PrivateLeague
  end
end