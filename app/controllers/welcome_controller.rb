class WelcomeController < ApplicationController
  include Mixpanelable
  before_action :set_mp_cookie_information

  def index
    mp_track 'View Homepage'
  end

  def letsencrypt
    render text: 'YtiJ5nqc1BuJ2bx01r9RbF3FdJaylGfUerJcncm2VTU.aU9Em34vTjJHcU9PAwtUa-O7NTQhQnJoA6FXlp6xtw0'
  end
end
