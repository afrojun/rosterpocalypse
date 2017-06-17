class ManagersController < RosterpocalypseController
  before_action :set_manager, only: [:show, :update, :subscribe, :unsubscribe,
                                     :reactivate_subscription, :update_payment_details,
                                     :remove_payment_source]

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
      if @manager.allow_payment_source_removal?
        @manager.remove_stripe_customer_source(remove_payment_params[:card_id])

        "Card successfully removed"
      else
        message = "Unable to remove the only card on record for an active subscription. " +
                  "Please add a new card first then remove this one."
        redirect_back(fallback_location: edit_user_registration_path,
                      alert: message) and return
      end
    end
  end

  def subscribe
    stripe_api_call do
      # Create a new Stripe customer if one doesn't exist. stripeToken is optional
      if @manager.stripe_customer_id.blank?
        @manager.create_stripe_customer params[:stripeToken]
      end
      @manager.create_stripe_subscription

      "Subscription request being processed."
    end
  end

  def unsubscribe
    stripe_api_call do
      @manager.delete_stripe_subscription

      UserMailer.subscription_cancelled(@manager.user).deliver_later

      "Successfully unsubscribed"
    end
  end

  def reactivate_subscription
    stripe_api_call do
      if @manager.stripe_customer_sources.count > 0
        @manager.reactivate_stripe_subscription

        UserMailer.subscription_reactivated(@manager.user).deliver_later

        "Subscription has been re-activated "
      else
        message = "In order to re-activate the subscription we need a card on record. " +
                  "Please add a new card then try re-activating again."
        redirect_back(fallback_location: edit_user_registration_path,
                      alert: message) and return
      end
    end
  end


  private

    def stripe_api_call
      authorize! :update, @manager

      message = yield
      redirect_back(fallback_location: edit_user_registration_path, notice: message)
    rescue Stripe::CardError => e
      # This is usually a card decline
      body = e.json_body
      err  = body[:error]

      logger.warn "[Stripe] [#{e.http_status}, #{err[:type]}] #{err[:message]} - " +
                   "Charge ID(#{err[:charge]}), Error Code( #{err[:code]}), " +
                   "Decline Code(#{err[:decline_code]}), Error Param(#{err[:param]}), "
      logger.warn "[Stripe] #{e.message}"

      redirect_back(fallback_location: edit_user_registration_path,
                    alert: "There was an error trying to use the card details provided.")
    rescue Stripe::RateLimitError => e
      logger.error "[Stripe] Too many requests made to the Stripe API too quickly: #{e.message}"
      redirect_back(fallback_location: edit_user_registration_path,
                    alert: "We were unable to complete the transaction, please try again.")
    rescue Stripe::StripeError => e
      logger.error "[Stripe] [#{e.http_status}, #{e.class}] - #{e.message}"
      redirect_back(fallback_location: edit_user_registration_path,
                    alert: "There was an internal error while processing the payment.")
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
