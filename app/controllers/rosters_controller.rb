class RostersController < RosterpocalypseController
  before_action :set_roster, only: [:show, :manage, :update, :destroy, :status, :details]
  before_action :set_gameweek, only: [:show]
  before_action :set_page_title, only: [:show, :edit]

  # GET /rosters
  # GET /rosters.json
  def index
    @my_rosters = Roster.includes(:tournament).where("manager_id = ? AND tournament_id in (?)", current_user.manager.id, Tournament.active_tournaments.map(&:id))
  end

  # GET /rosters/1
  # GET /rosters/1.json
  def show
    @gameweek_roster = GameweekRoster.where(gameweek: @gameweek, roster: @roster).first
    @gameweek_rosters = @gameweek.gameweek_rosters.order("points")
    @gameweek_players = if @gameweek_roster.gameweek_players.blank?
                          @roster.players.includes(:team).map do |player|
                            GameweekPlayer.new(gameweek: @gameweek, player: player, team: player.team)
                          end
                        else
                          @gameweek_roster.gameweek_players.includes(:player, :team).all
                        end
    @sidebar_props = {
      rosterPath: roster_url(@roster),
      rosterDetailsPath: details_roster_url(@roster),
      showPrivateLeagues: current_user.manager == @roster.manager
    }
  end

  # GET /rosters/1/manage
  def manage
    authorize! :update, @roster

    @roster_props = {
      rosterPath: roster_url(@roster),
      rosterDetailsPath: details_roster_url(@roster),
      playersPath: players_url,
      rosterRegion: @roster.region,
      maxPlayersInRoster: Roster::MAX_PLAYERS,
      maxRosterValue: Roster::MAX_TOTAL_VALUE,
      showPrivateLeagues: current_user.manager == @roster.manager
    }
  end

  # PATCH/PUT /rosters/1
  # PATCH/PUT /rosters/1.json
  def update
    respond_to do |format|
      if @roster.update_including_players(roster_params)
        format.html { redirect_to @roster, notice: "Roster was successfully updated." }
        format.json { render :details, status: :ok, location: @roster }
      else
        format.html { render :manage }
        format.json { render json: @roster.errors.map{ |key, message| "#{key.capitalize} #{message}" }.to_sentence, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rosters/1
  # DELETE /rosters/1.json
  def destroy
    @roster.destroy
    respond_to do |format|
      format.html { redirect_to rosters_url, notice: "Roster was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def details
    authorize! :read, @roster
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_roster
    @roster = Roster.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def roster_params
    params.require(:roster).permit(:name, :tournament_id, players: []).tap do |rp|
      rp[:manager_id] = current_user.manager.id
    end
  end

  def set_gameweek
    @gameweek = Gameweek.where(id: params[:gameweek]).first || (@roster.current_gameweek_roster.points.present? ? @roster.current_gameweek : @roster.previous_gameweek)
  end

  def set_page_title
    @page_title = "Roster: #{@roster.name}#{@gameweek.present? ? " : #{@gameweek.name}" : ""}"
  end
end
