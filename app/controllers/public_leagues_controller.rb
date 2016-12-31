class PublicLeaguesController < LeaguesController

  private

  def set_public_league
    @league = PublicLeague.find(params[:id])
  end

  def league_class
    PublicLeague
  end
end