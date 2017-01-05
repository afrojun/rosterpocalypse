class PlayersController < RosterpocalypseController
  before_action :set_player, only: [:show, :edit, :update, :destroy]

  # GET /players
  # GET /players.json
  def index
    region = params[:region]
    active = params[:active]

    @teams_filter = {}
    @teams_filter[:region] = region if region && Team::REGIONS.include?(region)
    @teams_filter[:active] = (active == "true") if active && ["true", "false"].include?(active)

    region_teams = Team.where(@teams_filter)
    @players = Player.includes(:game_details, :team).where(team: region_teams).order(:slug)
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player_games = @player.games.includes(:map, :tournament, game_details: [:team])
  end

  # GET /players/new
  def new
    @player = Player.new
  end

  # GET /players/1/edit
  def edit
  end

  # POST /players
  # POST /players.json
  def create
    @player = Player.new(player_params)

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: "Player was successfully created." }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1
  # PATCH/PUT /players/1.json
  def update
    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1
  # DELETE /players/1.json
  def destroy
    respond_to do |format|
      if @player.destroy
        format.html { redirect_to players_url, notice: "Player was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to players_url, alert: @player.errors.details[:base].map{ |error| error[:error] }.to_sentence }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  def merge
    authorize! :update, Player

    message = {}
    players = Player.where(id: params[:player_ids]).to_a

    if players.size > 1
      player_names = []

      # We choose the primary player to be the one with the most recent game
      players.sort_by! do |player|
        player.games.order(start_date: :desc).first
      end
      primary = players.shift

      players.each do |player|
        player_name = player.name
        primary.merge! player
        player_names << player_name
      end
      message[:notice] = "Merge successful! Merged #{player_names.to_sentence} with #{primary.name}."
    else
      message[:alert] = "Please choose more than 1 player to merge."
    end

    respond_to do |format|
      format.html { redirect_to players_url, message }
      format.json { render json: message }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name, :role, :country, :value, :team_id)
    end
end
