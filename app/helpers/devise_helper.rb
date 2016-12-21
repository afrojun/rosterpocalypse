module DeviseHelper

  def identity_provider_logo provider
    content_tag :i, "", class: "fa fa-2x #{identity_provider_logo_class_map[provider]}"
  end

  def identity_provider_logos user
    user.identities.map do |id|
      identity_provider_logo id.provider.to_sym
    end.join(" ").html_safe
  end

  def identity_provider_logo_class_map
    {
      reddit: "fa-reddit-square reddit-red",
      facebook: "fa-facebook-square facebook-blue",
      twitter: "fa-twitter-square twitter-blue",
      google_oauth2: "fa-google-plus-square google-plus-red"
    }
  end

end