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

  def generic_callback provider
    @identity = Identity.find_for_oauth env["omniauth.auth"].except("extra")

    @user = @identity.user || current_user
    if @user.nil?
      @user = if provider == "reddit"
                User.find_or_create_by(
                  email: "#{@identity.name}@reddit.com",
                  username: "#{@identity.name}_reddit"
                )
              else
                User.find_or_create_by(
                  email: @identity.email,
                  username: (@identity.nickname || @identity.email.split("@").first)
                )
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
      session["devise.#{provider}_data"] = env["omniauth.auth"].except("extra")
      redirect_to new_user_registration_url
    end
  end
end