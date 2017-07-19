class Identity < ApplicationRecord
  belongs_to :user

  validates :uid, :provider, presence: true
  validates :uid, uniqueness: { scope: :provider }

  def self.find_for_oauth(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end

  def self.find_or_create_for_oauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |identity|
      identity.accesstoken = auth.credentials.token
      identity.refreshtoken = auth.credentials.refresh_token
      identity.name = auth.info.name || auth.info.battletag.tr("#", ".")
      identity.email = auth.info.email
      identity.nickname = auth.info.nickname ||
                            (auth.info.email && auth.info.email.split("@").first) ||
                            (auth.info.name && auth.info.name.split.first) ||
                            auth.info.battletag.tr("#", ".")
      identity.image = auth.info.image
      identity.phone = auth.info.phone
      identity.urls = (auth.info.urls || "").to_json
    end
  end
end
