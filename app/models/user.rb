class User < ApplicationRecord
  has_one :manager, dependent: :destroy
  has_many :identities, dependent: :destroy

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :confirmable

  validates :username,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }
  validates_format_of :username, with: /^[a-zA-Z0-9_\.]*$/, multiline: true
  validates_length_of :username, minimum: 3, maximum: 30

  after_create :create_manager
  before_update :update_manager

  def create_manager
    Manager.create user: self
  end

  # Save the associated manager so that its slug gets updated when the username changes
  def update_manager
    manager.save
  end

  def admin?
    admin
  end

  def registered?
    self.persisted?
  end

  def unconfirmed?
    unconfirmed_email.present? || confirmed_at.blank?
  end

  def owner?
    username == "rosterpocalypse" && email == "rosterpocalypse@gmail.com"
  end

  def send_devise_notification notification, *args
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # OAuth handlers
  def twitter
    identities.where(:provider => "twitter").first
  end

  def twitter_client
    @twitter_client ||= Twitter.client access_token: twitter.accesstoken
  end

  def facebook
    identities.where(:provider => "facebook").first
  end

  def facebook_client
    @facebook_client ||= Facebook.client access_token: facebook.accesstoken
  end

  def reddit
    identities.where(:provider => "reddit").first
  end

  def reddit_client
    @reddit_client ||= Reddit.client access_token: reddit.accesstoken
  end

  def google_oauth2
    identities.where(:provider => "google_oauth2").first
  end

  def google_oauth2_client
    if !@google_oauth2_client
      @google_oauth2_client = Google::APIClient.new(:application_name => 'HappySeed App', :application_version => "1.0.0" )
      @google_oauth2_client.authorization.update_token!({:access_token => google_oauth2.accesstoken, :refresh_token => google_oauth2.refreshtoken})
    end
    @google_oauth2_client
  end

end
