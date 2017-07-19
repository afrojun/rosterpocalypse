class TournamentsController < RosterpocalypseController
  before_action :set_tournament, only: %i[show edit update destroy]
  before_action :set_gameweek, only: [:show]
  before_action :set_page_title, only: %i[show edit]

  # GET /tournaments
  # GET /tournaments.json
  def index
    @tournaments = Tournament.all.includes(:games)
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
    @gameweeks = @tournament.gameweeks.includes(:games, matches: [:tournament]).select { |gameweek| gameweek.matches.any? }
    return if @gameweek.blank?

    @tournament_matches = @gameweek.matches.includes(:team_1, :team_2)
    @tournament_players = @gameweek.gameweek_players
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
    @tournament_games = nil
  end

  # GET /tournaments/1/edit
  def edit
    @tournament_games = Game.where(
      '(gameweek_id IS NULL OR gameweek_id IN (?)) AND (start_date >= ? AND start_date <= ?)',
      @tournament.gameweeks.map(&:id),
      @tournament.start_date,
      @tournament.end_date
    ).includes(:map, gameweek: [:tournament], game_details: [:team])
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
      game_ids_to_remove = @tournament.games.map(&:id) - params[:game_ids].map(&:to_i)
      games_to_remove = Game.where('id IN (?)', game_ids_to_remove)
      if games_to_remove.present?
        logger.info "Removing previously associated games from this tournament: #{games_to_remove.map(&:id)}"
        games_to_remove.each do |game|
          game.update gameweek: nil
        end
      end

      games_to_add = Game.where('id IN (?) AND (gameweek_id IS NULL OR gameweek_id NOT IN (?))', params[:game_ids], @tournament.gameweeks.map(&:id))
      if games_to_add.present?
        logger.info "Adding games to this tournament: #{games_to_add.map(&:id)}"
        games_to_add.each do |game|
          gameweek = @tournament.gameweeks.where('start_date <= ? AND end_date >= ?', game.start_date, game.start_date).first
          game.update gameweek: gameweek
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

  def set_gameweek
    @gameweek = params[:gameweek_id].present? ? Gameweek.find(params[:gameweek_id]) : @tournament.current_gameweek
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tournament_params
    params.require(:tournament).permit(:name, :region, :cycle_hours, :start_date, :end_date)
  end

  def set_page_title
    @page_title = "#{@tournament.name}#{@gameweek.present? ? " : #{@gameweek.name}" : ''}"
  end
end
