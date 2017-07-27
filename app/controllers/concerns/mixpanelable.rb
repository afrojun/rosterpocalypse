module Mixpanelable
  extend ActiveSupport::Concern

  private

  def mp_track(event_name, options = {})
    if user_signed_in?
      mp_track_for_user(current_user, event_name, options)
    elsif (id = @mp_properties && @mp_properties['distinct_id'])
      mp_track_for_id(id, event_name, options)
    else
      logger.warn 'Unable to track a vist using Mixpanel, ID is missing'
    end
  end

  def mp_track_charge(amount, options = {})
    return if token.blank?

    options[:ip] = current_user.current_sign_in_ip.to_s
    mixpanel.people.track_charge(current_user.id, amount.to_f, options)
  end

  def mp_track_for_user(user, event_name, options = {})
    if user.mp_properties.blank?
      user.update mp_properties: @mp_properties
      identify_on_mixpanel user
    end

    options[:sign_in_ip] = user.current_sign_in_ip.to_s
    mp_track_for_id(user.id, event_name, options)
  end

  def mp_track_for_id(id, event_name, options = {})
    return if token.blank?

    session_params = {
      ip: request.ip,
      '$browser': browser.name,
      '$browser_version': browser.full_version,
      '$device': browser.device.name,
      '$current_url': request.original_url,
      '$os': browser.platform.name
    }

    options.
      merge!(session_params).
      merge!(campaign_tracking_params.to_h).
      merge!(@mp_properties)

    Rails.logger.info "Sending '#{event_name}' event to Mixpanel with options: " \
      "#{options.inspect}"

    mixpanel.track(id, event_name, options)
  end

  def set_mp_cookie_information
    @mp_properties = safely_retrieve_attributes
    Rails.logger.info "Set up @mp_properties: #{@mp_properties.inspect}"
  end

  def identify_on_mixpanel(user)
    return if token.blank?
    raise ArgumentError, 'User cannot be blank when identifying on mixpanel' if user.blank?
    Rails.logger.info "Identifying User #{user.id} with Mixpanel"

    # attributes is existing Mixpanel Params that are cookie'd by
    # Mixpanel Javascript
    attributes = @mp_properties
    mixpanel_params = {
      '$name': user.username,
      '$email': user.email,
      '$created': user.created_at.as_json,
      '$ip': user.current_sign_in_ip.to_s,
      '$browser': browser.name,
      '$browser_version': browser.full_version,
      '$os': browser.platform.name,
      'user_id': user.id,
      'manager_id': user.manager.id
    }.merge(attributes)

    distinct_id = mixpanel_params['distinct_id']

    # Alias the User with the old distinct ID
    mixpanel.alias user.id, distinct_id if distinct_id.present?

    # Set user properties
    Rails.logger.info "Current Mixpanel User IP: #{user.current_sign_in_ip}"
    mixpanel.people.set user.id, mixpanel_params, user.current_sign_in_ip.to_s

    mp_track_for_user user, 'User Identified'
  end

  def mixpanel
    @mixpanel ||= Mixpanel::Tracker.new(token)
  end

  def token
    !Rails.env.test? && ENV['MIXPANEL_ID']
  end

  def namespace
    "mp_#{token}_mixpanel"
  end

  def safely_retrieve_attributes
    JSON.parse(cookies.fetch(namespace)) || {}
  rescue => e
    Rails.logger.error 'Mixpanel Analytics Cookie Retrieval Error: ' \
      "[#{e.class}] #{e.message}; " \
      "cookie: #{cookies[namespace].inspect}; " \
      "user_agent: #{request.user_agent}"
    {}
  end

  def campaign_tracking_params
    params.permit(:ref, :source, :utm_content, :utm_medium, :utm_source, :utm_campaign)
  end
end
