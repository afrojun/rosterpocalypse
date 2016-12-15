class ManagersController < RosterpocalypseController
  before_action :set_manager, only: [:show]

  # GET /managers
  # GET /managers.json
  def index
    @managers = Manager.all
  end

  # GET /managers/1
  # GET /managers/1.json
  def show
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_manager
      @manager = Manager.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manager_params
      params.require(:manager).permit(:user_id)
    end
end
