class LeaguesController < RosterpocalypseController
  before_action :set_league, only: [:show, :edit, :update, :destroy]

  # GET /leagues
  # GET /leagues.json
  def index
    @public_leagues = PublicLeague.all.includes(manager: [:user])
    @private_leagues = if current_user.admin?
                         PrivateLeague.all.includes(manager: [:user])
                       else
                         PrivateLeague.where("manager_id = #{current_user.manager.id}").includes(manager: [:user])
                       end
  end

  # GET /leagues/1
  # GET /leagues/1.json
  def show
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
      format.html { redirect_to leagues_url, notice: 'League was successfully destroyed.' }
      format.json { head :no_content }
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
      params.require(league_symbol).permit(:name, :tournament_id, :description).tap do |lp|
        lp[:manager_id] = current_user.manager.id
      end
    end
end
