class Api::SessionsController < Api::BaseApiController
  prepend_before_action :equire_no_authentication, only: [:create]

  before_action :ensure_params_exist

  respond_to :json

  def create
    build_resource
    resource = User.find_for_database_authentication(login: params[:user_login][:login])
    return invalid_login_attempt unless resource

    if resource.valid_password?(params[:user_login][:password])
      sign_in('user', resource)
      render json: { success: true, auth_token: resource.authentication_token, login: resource.login, email: resource.email }
      return
    end
    invalid_login_attempt
  end

  def destroy
    sign_out(resource_name)
  end

  protected

  def ensure_params_exist
    return if params[:user_login].present?
    render json: { success: false, message: 'missing user_login parameter' }, status: 422
  end

  def invalid_login_attempt
    warden.custom_failure!
    render json: { success: false, message: 'Error with your login or password' }, status: 401
  end
end
