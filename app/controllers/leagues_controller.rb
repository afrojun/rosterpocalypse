class LeaguesController < RosterpocalypseController
  before_action :set_league, only: [:show, :edit, :update, :destroy, :join, :leave]

  # GET /leagues
  # GET /leagues.json
  def index
    @public_leagues = PublicLeague.includes(:tournament).
                                   where("tournament_id in (?) AND manager_id = 9",
                                          Tournament.active_tournaments.map(&:id))
    @heroes_powerhour_featured_league = PublicLeague.find('heroes-powerhour-s2-league')
  end

  # GET /leagues/1
  # GET /leagues/1.json
  def show
    @rosters = @league.rosters.includes(manager: [:user]).order(score: :desc).page params[:page]
  end

  # GET /leagues/new
  def new
    authorize! :create, league_class
    @league = league_class.new
  end

  # GET /leagues/1/edit
  def edit
  end

  # POST /leagues
  # POST /leagues.json
  def create
    authorize! :create, league_class
    logger.info "Creating a new #{league_class.to_s.titleize}."
    @league = league_class.new(league_params)
    @league.populate_default_options

    respond_to do |format|
      if @league.save
        format.html { redirect_to @league, notice: 'League was successfully created.' }
        format.json { render :show, status: :created, location: @league }
      else
        format.html { render :new }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /leagues/1
  # PATCH/PUT /leagues/1.json
  def update
    respond_to do |format|
      if @league.update(league_params)
        format.html { redirect_to @league, notice: 'League was successfully updated.' }
        format.json { render :show, status: :ok, location: @league }
      else
        format.html { render :edit }
        format.json { render json: @league.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /leagues/1
  # DELETE /leagues/1.json
  def destroy
    @league.destroy
    respond_to do |format|
      format.html { redirect_to leagues_path, notice: 'League was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /leagues/1/join
  # POST /leagues/1/join.json
  def join
    respond_to do |format|
      if roster = @league.join(current_user.manager)
        format.html {
          redirect_to manage_roster_path(roster),
                      notice: "Successfully joined League '#{@league.name}', now create a Roster for it!"
        }
        format.json { render :show, status: :ok, location: @league }
      else
        message = @league.errors[:base].to_sentence
        format.html { redirect_to @league, alert: message }
        format.json { render json: { message: message }, status: :unprocessable_entity }
      end
    end
  end

  # POST /leagues/1/leave
  # POST /leagues/1/leave.json
  def leave
    respond_to do |format|
      if roster = @league.leave(current_user.manager)
        format.html { redirect_to leagues_path, notice: "Roster '#{roster.name}' was removed from '#{@league.name}'." }
        format.json { render :show, status: :ok, location: @league }
      else
        message = @league.errors[:base].to_sentence
        format.html { redirect_to leagues_path, alert: message }
        format.json { render json: { message: message }, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_league
      @league = League.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def league_params
      league_symbol = league_class.to_s.underscore.to_sym
      params.require(league_symbol).permit(:name, :tournament_id, :description,
                                           :starting_budget, :num_transfers,
                                           :max_players_per_team, :use_representative_game,
                                           required_player_roles: [:assassin, :flex, :warrior, :support],
                                           role_stat_modifiers: [
                                                                  {assassin: [:solo_kills, :assists, :time_spent_dead, :win]},
                                                                  {flex:     [:solo_kills, :assists, :time_spent_dead, :win]},
                                                                  {warrior:  [:solo_kills, :assists, :time_spent_dead, :win]},
                                                                  {support:  [:solo_kills, :assists, :time_spent_dead, :win]}
                                                                ]
                                          ).tap do |lp|
        lp[:manager_id] = current_user.manager.id
      end
    end
end
