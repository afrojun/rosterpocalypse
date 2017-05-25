class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    generic_callback 'facebook'
  end

  def twitter
    generic_callback 'twitter'
  end

  def google_oauth2
    generic_callback 'google_oauth2'
  end

  def reddit
    generic_callback 'reddit'
  end

  def bnet
    generic_callback 'bnet'
  end

  def generic_callback provider
    @identity = Identity.find_for_oauth request.env["omniauth.auth"].except("extra")

    @user = @identity.user || current_user
    if @user.nil?
      @user = if @identity.email.present?
                # Google, Facebook and Twitter provide email addresses
                User.find_or_create_by(email: @identity.email) do |u|
                  u.username = @identity.nickname
                  # We assume that emails we get from these providers are accurate
                  # and don't need to re-confirm them
                  u.confirmed_at = Time.now.utc
                end
              elsif @identity.name.present?
                # This is used for reddit and bnet since they don't provide user emails
                User.find_or_create_by(email: "#{@identity.name}@#{provider}.com") do |u|
                  u.username = "#{@identity.name}_#{provider}"
                end
              else
                message = "Unable to infer the email address from the OAuth details provided by #{provider}"
                logger.error "#{message}: #{request.env["omniauth.auth"].except("extra")}"
                flash[:notice] = "#{message}."
                redirect_to new_user_registration_url
              end

      @identity.update_attribute :user_id, @user.id
    end

    if @user.persisted?
      @identity.update_attribute :user_id, @user.id
      # This is because we've created the user manually, and Device expects a
      # FormUser class (with the validations)
      @user = FormUser.find @user.id
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.humanize.split(" ").first) if is_navigational_format?
    else
      session["devise.#{provider}_data"] = request.env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url
    end
  end
end