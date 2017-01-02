class TournamentsController < RosterpocalypseController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy]

  # GET /tournaments
  # GET /tournaments.json
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
    @tournament_games = @tournament.games.includes(:map, :tournament, game_details: [:team])
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
    @tournament_games = nil
  end

  # GET /tournaments/1/edit
  def edit
    @tournament_games = Game.where("
      (tournament_id IS NULL OR tournament_id = ?) AND (start_date >= ? AND start_date <= ?)",
      @tournament.id, @tournament.start_date, @tournament.end_date
    ).includes(:map, :tournament, game_details: [:team])
  end

  # POST /tournaments
  # POST /tournaments.json
  def create
    @tournament = Tournament.new(tournament_params)

    respond_to do |format|
      if @tournament.save
        format.html { redirect_to @tournament, notice: 'Tournament was successfully created.' }
        format.json { render :show, status: :created, location: @tournament }
      else
        format.html { render :new }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tournaments/1
  # PATCH/PUT /tournaments/1.json
  def update
    if params[:game_ids]
      games_to_remove = Game.where("id IN (?)", @tournament.games.map(&:id) - params[:game_ids].map(&:to_i))
      if games_to_remove.present?
        logger.info "Removing previously associated games from this tournament: #{games_to_remove.map(&:id)}"
        games_to_remove.each do |game|
          game.update_attribute(:tournament, nil)
        end
      end

      games_to_add = Game.where("id IN (?) AND (tournament_id IS NULL OR tournament_id != ?)", params[:game_ids], @tournament.id)
      if games_to_add.present?
        logger.info "Adding games to this tournament: #{games_to_add.map(&:id)}"
        games_to_add.each do |game|
          game.update_attribute(:tournament, @tournament)
        end
      end
    end

    respond_to do |format|
      if @tournament.update(tournament_params)
        format.html { redirect_to @tournament, notice: 'Tournament was successfully updated.' }
        format.json { render :show, status: :ok, location: @tournament }
      else
        format.html { render :edit }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tournaments/1
  # DELETE /tournaments/1.json
  def destroy
    @tournament.destroy
    respond_to do |format|
      format.html { redirect_to tournaments_url, notice: 'Tournament was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tournament
      @tournament = Tournament.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tournament_params
      params.require(:tournament).permit(:name, :region, :cycle_hours, :start_date, :end_date)
    end
end
