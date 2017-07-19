class TeamsController < RosterpocalypseController
  before_action :set_team, only: %i[show edit update destroy toggle_active]

  # GET /teams
  # GET /teams.json
  def index
    @teams = Team.all.includes(:players).order(active: :desc, region: :asc, slug: :asc)
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
    @players = Player.where(team: @team).includes(:team)
    @team_games = @team.games.includes(:map, :tournament, game_details: [:team]).order(start_date: :desc).distinct.page params[:page]
  end

  # GET /teams/new
  def new
    @team = Team.new
  end

  # GET /teams/1/edit
  def edit
  end

  # POST /teams
  # POST /teams.json
  def create
    @team = Team.new(team_params)

    respond_to do |format|
      if @team.save
        format.html { redirect_to @team, notice: "Team was successfully created." }
        format.json { render :show, status: :created, location: @team }
      else
        format.html { render :new }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
    respond_to do |format|
      if @team.update(team_params)
        format.html { redirect_to @team, notice: "Team was successfully updated." }
        format.json { render :show, status: :ok, location: @team }
      else
        format.html { render :edit }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
    respond_to do |format|
      if @team.destroy
        format.html { redirect_to teams_url, notice: "Team was successfully destroyed." }
        format.json { head :no_content }
      else
        format.html { redirect_to teams_url, alert: @team.errors.details[:base].map { |error| error[:error] }.to_sentence }
        format.json { render json: @team.errors, status: :unprocessable_entity }
      end
    end
  end

  def merge
    authorize! :update, Team

    message = {}
    teams = Team.where(id: params[:team_ids]).to_a

    if teams.size > 1
      primary = teams.shift

      teams.each do |team|
        team_name = team.name
        primary.merge! team

        message[:notice] = "#{message[:notice]}Merged #{team_name} with #{primary.name}. "
      end
    else
      message[:alert] = "Please choose more than 1 team to merge."
    end

    respond_to do |format|
      format.html { redirect_to teams_url, message }
      format.json { render json: message }
    end
  end

  def toggle_active
    authorize! :update, @team

    @team.toggle! :active

    respond_to do |format|
      format.html { redirect_to teams_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_team
    @team = Team.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def team_params
    params.require(:team).permit(:name, :region, :active)
  end
end
