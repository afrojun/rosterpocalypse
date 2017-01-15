module DeviseHelper

  def identity_provider_logo provider
    content_tag :i, "", class: "fa fa-2x #{identity_provider_logo_class_map[provider]}", title: provider.to_s.split("_").first.capitalize
  end

  def identity_provider_logos user
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