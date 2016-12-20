class GameDetailsController < RosterpocalypseController
  before_action :set_game_detail, only: [:show, :edit, :update, :destroy]
  before_action :set_game, only: [:index, :new, :create]

  # GET /games/1/details
  # GET /games/1/details.json
  def index
    @game_details = @game.game_details
  end

  # GET /details/1
  # GET /details/1.json
  def show
  end

  # GET /games/1/details/new
  def new
    @game_detail = GameDetail.new
  end

  # GET /games/1/edit
  def edit
  end

  # POST /games/1/details
  # POST /games/1/details.json
  def create
    @game_detail = GameDetail.new(game_detail_params)

    respond_to do |format|
      if @game_detail.save
        format.html { redirect_to detail_url(@game_detail), notice: 'Game detail was successfully created.' }
        format.json { render :show, status: :created, location: @game_detail }
      else
        format.html { render :new }
        format.json { render json: @game_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /games/1
  # PATCH/PUT /games/1.json
  def update
    respond_to do |format|
      if @game_detail.update(game_detail_params)
        format.html { redirect_to @game_detail.game, notice: 'Game detail was successfully updated.' }
        format.json { render :show, status: :ok, location: @game_detail }
      else
        format.html { render :edit }
        format.json { render json: @game_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /games/1
  # DELETE /games/1.json
  def destroy
    game = @game_detail.game
    @game_detail.destroy
    respond_to do |format|
      format.html { redirect_to game_details_url(game), notice: 'Game detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_game_detail
      @game_detail = GameDetail.find(params[:id])
    end

    def set_game
      @game = Game.find(params[:game_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def game_detail_params
      params.require(:detail).permit(:player_id, :game_id, :team_id, :hero_id, :solo_kills, :assists, :deaths, :time_spent_dead, :team_colour, :win)
    end
end
