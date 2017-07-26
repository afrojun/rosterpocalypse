class SessionsController < Devise::SessionsController
  include Mixpanelable
  before_action :set_mp_cookie_information

  def create
    super do |resource|
      if resource.persisted?
        if resource.mp_properties.blank?
          resource.update mp_properties: @mp_properties
          identify_on_mixpanel resource
        end
        mp_track_for_user resource, 'User Signed In'
      end
    end
  end
end
