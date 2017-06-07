class ManagersController < RosterpocalypseController
  before_action :set_manager, only: [:show, :update, :update_payment_details, :remove_payment_source]

  # GET /managers
  # GET /managers.json
  def index
    @managers = Manager.all.includes(:user).page params[:page]
  end

  # GET /managers/1
  # GET /managers/1.json
  def show
  end

  # PATCH/PUT /managers/1
  # PATCH/PUT /managers/1.json
  def update
    respond_to do |format|
      if @manager.update(manager_params)
        format.html { redirect_back(fallback_location: edit_user_registration_path, notice: 'Successfully updated.') }
        format.json { render :show, status: :ok, location: @manager }
      else
        format.html { render :edit }
        format.json { render json: @manager.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_payment_details
    stripe_api_call do
      # Update the customer if it exists, otherwise create it first
      if @manager.stripe_customer_id.present?
        @manager.update_stripe_customer_source update_payment_params[:stripeToken]
      else
        @manager.create_stripe_customer update_payment_params[:stripeToken]
      end

      "Card details updated successfully"
    end
  end

  def remove_payment_source
    stripe_api_call do
      @manager.remove_stripe_customer_source(remove_payment_params[:card_id])

      "Card successfully removed"
    end
  end


  private

    def stripe_api_call
      authorize! :update, @manager

      message = yield
      redirect_back(fallback_location: edit_user_registration_path, notice: message)
    rescue Stripe::CardError => e
      redirect_back(fallback_location: edit_user_registration_path, error: e.message)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_manager
      @manager = Manager.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def manager_params
      params.require(:manager).permit(:email_scores_updated,
                                      :email_new_feature,
                                      :email_join_league)
    end

    def update_payment_params
      params.permit(:stripeToken).tap do |payment_params|
        payment_params.require(:stripeToken)
      end
    end

    def remove_payment_params
      params.permit(:card_id).tap do |payment_params|
        payment_params.require(:card_id)
      end
    end
end
