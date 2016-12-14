class RostersController < RosterpocalypseController
  before_action :set_roster, only: [:show, :edit, :update, :destroy]

  # GET /rosters
  # GET /rosters.json
  def index
    @my_rosters = current_user.blank? ? [] : Roster.where(manager: current_user)
    @rosters = Roster.all
  end

  # GET /rosters/1
  # GET /rosters/1.json
  def show
  end

  # GET /rosters/new
  def new
    @roster = Roster.new
  end

  # GET /rosters/1/edit
  def edit
  end

  # POST /rosters
  # POST /rosters.json
  def create
    @roster = Roster.new(roster_params)

    respond_to do |format|
      if @roster.save
        format.html { redirect_to edit_roster_path(@roster), notice: 'Your roster was successfully created, now add some players to it!' }
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
      if @roster.update(roster_params)
        format.html { redirect_to @roster, notice: 'Roster was successfully updated.' }
        format.json { render :show, status: :ok, location: @roster }
      else
        format.html { render :edit }
        format.json { render json: @roster.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rosters/1
  # DELETE /rosters/1.json
  def destroy
    @roster.destroy
    respond_to do |format|
      format.html { redirect_to rosters_url, notice: 'Roster was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_roster
    @roster = Roster.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def roster_params
    params.require(:roster).permit(:name).tap do |rp|
      rp[:manager_id] = current_user.manager.id
    end
  end
end
