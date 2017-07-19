class GamesController < RosterpocalypseController
  before_action :set_game, only: %i[show edit update destroy swap_teams]

  # GET /games
  # GET /games.json
  def index
    @games = Game.includes(:map, :tournament, game_details: [:team]).order(start_date: :desc).page params[:page]
  end

  # GET /games/1
  # GET /games/1.json
  def show
  end

  # GET /games/new
  def new
    @game = Game.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games
  # POST /games.json
  def create
    @game = Game.new(game_params)

    respond_to do |format|
      if @game.save
        format.html { redirect_to @game, notice: 'Game was successfully created.' }
        format.json { render :show, status: :created, location: @game }
      else
        format.html { render :new }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game.update(game_params)
        format.html { redirect_to @game, notice: 'Game was successfully updated.' }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { render :edit }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    @game.destroy
    respond_to do |format|
      format.html { redirect_to games_url, notice: 'Game was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def bulk_destroy
    authorize! :destroy, Game

    games = Game.where(id: params[:game_ids])
    n_games = games.size
    result = games.all?(&:destroy)

    respond_to do |format|
      if result
        format.html { redirect_to games_url, notice: "All #{n_games} games were successfully destroyed." }
        format.json { head :no_content }
      else
        message = "Some games failed to be destroyed."
        format.html { redirect_to games_url, notice: message }
        format.json { render json: { error: message }, status: :unprocessable_entity }
      end
    end
  end

  def swap_teams
    authorize! :update, @game

    respond_to do |format|
      if @game.swap_teams
        format.html { redirect_to @game, notice: "Successfully swapped teams." }
        format.json { render :show, status: :ok, location: @game }
      else
        format.html { redirect_to @game, notice: "Failed to swap teams." }
        format.json { render json: @game.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_game
    @game = Game.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def game_params
    params.require(:game).permit(:map_id, :start_date, :duration_s, :game_hash, :match_id)
  end

  # We use the presenter to set this from the view
  def set_page_title
    @page_title = nil
  end
end
