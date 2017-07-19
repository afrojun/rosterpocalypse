module DeviseHelper
  # This returns the confirmation email if it is valid, or nil otherwise
  def valid_confirmation_email(user)
    user.confirmation_email if valid_email?(user.confirmation_email)
  end

  def user_manage_payments_url
    edit_user_registration_url + "#manage_payments"
  end

  def user_manage_payments_page
    edit_user_registration_path + "#manage_payments"
  end

  def valid_email?(email)
    # These domains were used to create fake email addresses for users that
    # created accounts using Reddit or Battle.net logins. We need to move away
    # from this now so these domains are treated as invalid.
    invalid_email_domains = ["reddit.com", "bnet.com"]

    email_domain = email && email.split("@").last
    !invalid_email_domains.include?(email_domain)
  end

  def identity_provider_logo(provider)
    if provider == :bnet
      battlenet_logo
    else
      content_tag :i, "", class: "fa fa-2x #{identity_provider_logo_class_map[provider]}", title: provider.to_s.split("_").first.capitalize
    end
  end

  def battlenet_logo
    image_tag "battlenet_logo.png", title: "Battle.net", size: 32, style: "margin-bottom: 1em;"
  end

  def identity_provider_logos(user)
    user.identities.map do |id|
      identity_provider_logo id.provider.to_sym
    end.join(" ").html_safe
  end

  def identity_provider_logo_class_map
    {
      reddit: "fa-reddit-alien reddit-red",
      facebook: "fa-facebook facebook-blue",
      twitter: "fa-twitter twitter-blue",
      google_oauth2: "fa-google google-plus-red"
    }
  end
end