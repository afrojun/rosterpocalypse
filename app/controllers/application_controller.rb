class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :set_csrf_cookie

  protected

  def set_csrf_cookie
    if protect_against_forgery?
      cookies['csrftoken'] = form_authenticity_token
    end
  end

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :sign_in, keys: [:email, :password, :remember_me]
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

end
