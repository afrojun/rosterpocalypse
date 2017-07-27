class SessionsController < Devise::SessionsController
  include Mixpanelable
  before_action :set_mp_cookie_information

  def create
    super do |resource|
      mp_track_for_user resource, 'User Signed In' if resource.persisted?
    end
  end
end
