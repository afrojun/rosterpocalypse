class Identity < ApplicationRecord
  belongs_to :user

  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth auth
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |identity|
      identity.accesstoken = auth.credentials.token
      identity.refreshtoken = auth.credentials.refresh_token
      identity.name = auth.info.name || auth.info.battletag.split("#").first
      identity.email = auth.info.email
      identity.nickname = auth.info.nickname || auth.info.battletag.gsub("#", ".")
      identity.image = auth.info.image
      identity.phone = auth.info.phone
      identity.urls = (auth.info.urls || "").to_json
    end
  end
end
