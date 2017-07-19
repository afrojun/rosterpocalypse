class RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      track_sign_up resource
    end
  end

  def update_resource resource, params
    if resource.encrypted_password.blank? # || params[:password].blank?
      resource.email = params[:email] if params[:email]
      if params[:password].present? && params[:password] == params[:password_confirmation]
        logger.info "Updating password"
        resource.password = params[:password]
        resource.save
      end
      resource.update_without_password(params) if resource.valid?
    else
      resource.update_with_password(params)
    end
  end

  protected

  def after_update_path_for resource
    edit_user_registration_path
  end

  def track_sign_up resource
    mixpanel_params = {
      email: resource.email,
      nickname: resource.username,
      created: resource.created_at.as_json,
      ip: resource.current_sign_in_ip
    }

    attributes = JSON.parse cookies["mp_#{ENV["MIXPANEL_ID"]}_mixpanel"]
    distinct_id = attributes.delete('distinct_id')

    mixpanel = Mixpanel::Tracker.new(ENV["MIXPANEL_ID"])

    # Alias the User with the old distinct ID
    mixpanel.alias resource.id, distinct_id: distinct_id if distinct_id
    # Set user properties
    ip = resource.current_sign_in_ip.present? ? resource.current_sign_in_ip.to_s : 0
    mixpanel.people.set resource.id, mixpanel_params, ip
    mixpanel.track resource.id, 'User Signed Up'
  rescue => e
    logger.error "Failed to track user with Mixpanel: [#{e.class}] #{e.message}"
    logger.error "#{e.backtrace}"
  end
end