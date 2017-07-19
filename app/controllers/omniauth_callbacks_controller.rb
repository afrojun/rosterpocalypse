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
    login_only_callback 'reddit'
  end

  def bnet
    login_only_callback 'bnet'
  end

  # This allows users who have previously used one of these services to log in, to continue to
  # do so, however we don't allow any new accounts to be created.
  def login_only_callback(provider)
    @identity = Identity.find_for_oauth request.env["omniauth.auth"].except("extra")
    @user = @identity.try(:user) || current_user

    if @user.present? && @user.persisted?
      @user = FormUser.find @user.id
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider.humanize.split(" ").first) if is_navigational_format?
    else
      message = "Creation of new accounts using #{provider.capitalize} is no longer supported."
      logger.warn message.to_s
      flash[:alert] = "#{message}. Please use one of the other supported services or email."
      redirect_to new_user_registration_url
    end
  end

  # Log in or create a new account based on the OAuth information provided
  def generic_callback(provider)
    @identity = Identity.find_or_create_for_oauth request.env["omniauth.auth"].except("extra")

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
              else
                message = "Unable to retrieve the email address from the OAuth details provided by #{provider}"
                logger.error "#{message}: #{request.env['omniauth.auth'].except('extra')}"
                flash[:alert] = "#{message}."
                redirect_to new_user_registration_url
              end

      @identity.update user_id: @user.id
    end

    if @user.persisted?
      @identity.update user_id: @user.id
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
