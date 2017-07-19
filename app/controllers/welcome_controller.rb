class WelcomeController < ApplicationController
  def index
    id = if user_signed_in?
           current_user.id
         else
           attributes = JSON.parse cookies["mp_#{ENV['MIXPANEL_ID']}_mixpanel"]
           attributes.delete('distinct_id') if attributes.present?
         end

    if id.present?
      mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_ID"])
      mixpanel.track id, 'View Homepage'
    end
  rescue => e
    logger.error "Failed to track user with Mixpanel: [#{e.class}] #{e.message}"
    logger.error e.backtrace.to_s
  end

  def letsencrypt
    render text: "YtiJ5nqc1BuJ2bx01r9RbF3FdJaylGfUerJcncm2VTU.aU9Em34vTjJHcU9PAwtUa-O7NTQhQnJoA6FXlp6xtw0"
  end
end
