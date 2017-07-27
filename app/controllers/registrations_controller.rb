class RegistrationsController < Devise::RegistrationsController
  include Mixpanelable
  before_action :set_mp_cookie_information

  def create
    super do |resource|
      mp_track_for_user resource, 'User Signed Up' if resource.persisted?
    end
  end

  def update_resource(resource, params)
    if resource.encrypted_password.blank? # || params[:password].blank?
      resource.email = params[:email] if params[:email]
      if params[:password].present? && params[:password] == params[:password_confirmation]
        logger.info 'Updating password'
        resource.password = params[:password]
        resource.save
      end
      resource.update_without_password(params) if resource.valid?
    else
      resource.update_with_password(params)
    end
  end

  protected

  def after_update_path_for(*)
    edit_user_registration_path
  end
end
