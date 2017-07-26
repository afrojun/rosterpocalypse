class WelcomeController < ApplicationController
  include Mixpanelable
  before_action :set_mp_cookie_information

  def index
    id = user_signed_in? ? current_user.id : safely_retrieve_attributes['distinct_id']
    mixpanel.track id, 'View Homepage', welcome_params if id.present?
  end

  def letsencrypt
    render text: 'YtiJ5nqc1BuJ2bx01r9RbF3FdJaylGfUerJcncm2VTU.aU9Em34vTjJHcU9PAwtUa-O7NTQhQnJoA6FXlp6xtw0'
  end

  protected

  # Never trust parameters from the scary internet, only allow the white list through.
  def welcome_params
    params.permit(:ref, :source)
  end

end
