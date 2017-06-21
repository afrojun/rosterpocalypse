class WelcomeController < ApplicationController
  def index
    id = if user_signed_in?
           current_user.id
         else
           attributes = JSON.parse cookies["mp_#{ENV["MIXPANEL_ID"]}_mixpanel"]
           distinct_id = attributes.delete('distinct_id')
         end

    mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_ID"])
    mixpanel.track id, 'View Homepage'
  end

  def letsencrypt
    render text: "zUglz6mntarZhmduCG_0VKRdX2K4BwbBPX8ONPaIWic.Gw5TZZlZX9cQX1gHyGpt_NSCFx9i0l_VQKEE99-44CY"
  end
end
