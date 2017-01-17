class PlayersController < RosterpocalypseController
  before_action :set_player, only: [:show, :edit, :update, :destroy]
  before_action :set_team_filter, only: [:index, :merge]

  # GET /players
  # GET /players.json
  def index
    region_teams = Team.where @teams_filter
    @players = Player.includes(:game_details, :team).where(team: region_teams).order(:slug)
  end

  # GET /players/1
  # GET /players/1.json
  def show
    @player_games = @player.games.includes(:map, :tournament, game_details: [:team]).order(start_date: :desc).page params[:page]
  end

  # GET /players/new
  def new
    @player = Player.new
    @teams = Team.order(:name)
  end

  # GET /players/1/edit
  def edit
    if @player.team.try(:region).present?
      @teams = Team.where(region: @player.team.region).order(:name)
    else
      @teams = Team.order(:name)
    end
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

    response, response_message = Player.merge_players players

    if response
      message[:notice] = response_message
    else
      message[:alert] = response_message
    end

    respond_to do |format|
      format.html { redirect_to players_url(region: @teams_filter[:region], active: @teams_filter[:active]), message }
      format.json { render json: message }
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    def set_team_filter
      region = params[:region]
      active = params[:active]

      @teams_filter = {}
      @teams_filter[:region] = region if region && Team::REGIONS.include?(region)
      @teams_filter[:active] = (active == "true") if active && ["true", "false"].include?(active)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def player_params
      params.require(:player).permit(:name, :role, :country, :value, :team_id)
    end
end
