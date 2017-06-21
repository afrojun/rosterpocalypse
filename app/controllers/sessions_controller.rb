class SessionsController < Devise::SessionsController

  def create
    super do |resource|
      track_sign_in resource
    end
  end

  protected

    def track_sign_in resource
      mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_ID"])
      mixpanel.track resource.id, 'User Signed In'
    end

end