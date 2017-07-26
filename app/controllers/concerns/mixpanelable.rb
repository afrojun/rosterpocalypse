module Mixpanelable
  extend ActiveSupport::Concern

  private

  def mp_track(event_name, options = {})
    mp_track_for_user(current_user, event_name, options)
  end

  def mp_track_charge(amount, options = {})
    return if token.blank?

    options[:ip] = current_user.current_sign_in_ip.to_s
    mixpanel.people.track_charge(current_user.id, amount.to_f, options)
  end

  def mp_track_for_user(user, event_name, options = {})
    return if token.blank?

    options[:ip] = user.current_sign_in_ip.to_s
    mixpanel.track(user.id, event_name, options)
  end

  def set_mp_cookie_information
    # In your case, the cookies will be namespaced differently
    # so remember to use your own namespace.
    mp_cookies = cookies[namespace]
    return if mp_cookies.blank?

    @mp_properties = safely_retrieve_attributes
  end

  def identify_on_mixpanel(user)
    return if token.blank?
    raise ArgumentError, 'User cannot be blank when identifying on mixpanel' if user.blank?
    Rails.logger.info "Identifying User #{user.id} with Mixpanel"

    # attributes is existing Mixpanel Params that are cookie'd by
    # Mixpanel Javascript
    attributes = safely_retrieve_attributes
    mixpanel_params = {
      '$email': user.email,
      '$created': user.created_at.as_json,
      '$ip': user.current_sign_in_ip.to_s,
      'user_id': user.id
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
    JSON.parse(cookies[namespace]) || {}
  rescue JSON::ParserError => e
    Rails.logger.error 'Mixpanel Analytics Cookie Retrieval Error: ' \
      "message: #{e.message}; " \
      "cookie: #{cookies[namespace]}"
    {}
  end
end
