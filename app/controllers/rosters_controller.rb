class RostersController < RosterpocalypseController
  before_action :set_roster, only: [:show, :manage, :update, :destroy, :status, :details]

  # GET /rosters
  # GET /rosters.json
  def index
    @my_rosters = Roster.includes(players: [:team]).where("manager_id = ?", current_user.manager.id)
  end

  # GET /rosters/1
  # GET /rosters/1.json
  def show
  end

  # GET /rosters/new
  def new
    @roster = Roster.new
  end

  # GET /rosters/1/manage
  def manage
    authorize! :update, @roster

    @roster_props = {
      rosterPath: roster_url(@roster),
      manageRosterPath: details_roster_url(@roster),
      playersPath: players_url,
      rosterRegion: @roster.region,
      maxPlayersInRoster: Roster::MAX_PLAYERS,
      maxRosterValue: Roster::MAX_TOTAL_VALUE
    }
  end

  # POST /rosters
  # POST /rosters.json
  def create
    @roster = Roster.new(roster_params)

    respond_to do |format|
      if @roster.save
        # Enroll the roster in the most recently started Public League for the region that has not yet ended (if any)
        # This is best-effort and we simply carry on if we don't find a League that matches those criteria
        tournament = Tournament.where('region = ? AND end_date > ?', @roster.region, Time.now).order(start_date: :desc).first
        public_league = PublicLeague.where(tournament: tournament).first
        league_message = ""
        if public_league.present?
          logger.info "Adding the Roster '#{@roster.name}' to Public League '#{public_league.name}'"
          if public_league.add @roster
            league_message = " and added to the '#{public_league.name}' League"
          end
        end

        format.html { redirect_to manage_roster_path(@roster), notice: "Your roster was successfully created#{league_message}!" }
        format.json { render :show, status: :created, location: @roster }
      else
        format.html { render :new }
        format.json { render json: @roster.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rosters/1
  # PATCH/PUT /rosters/1.json
  def update
    respond_to do |format|
      if @roster.update_including_players(roster_params)
        format.html { redirect_to @roster, notice: "Roster was successfully updated." }
        format.json { render :show, status: :ok, location: @roster }
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

  # GET /rosters/1/status
  def status
    authorize! :read, @roster

    @gameweek = Gameweek.where(id: params[:gameweek]).first || @roster.current_gameweek
    @gameweek_roster = GameweekRoster.where(gameweek: @gameweek, roster: @roster).first
    @gameweek_players_by_player = @gameweek_roster == @roster.current_gameweek_roster ? @gameweek_roster.gameweek_players_by_player(@roster.players) : @gameweek_roster.gameweek_players_by_player
    @sidebar_props = {
      rosterPath: roster_url(@roster),
      manageRosterPath: details_roster_url(@roster)
    }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_roster
    @roster = Roster.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def roster_params
    params.require(:roster).permit(:name, :region, players: []).tap do |rp|
      rp[:manager_id] = current_user.manager.id
    end
  end
end
