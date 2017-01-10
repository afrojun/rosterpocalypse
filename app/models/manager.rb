class Manager < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :user
  has_many :rosters, dependent: :destroy
  has_many :leagues, dependent: :destroy

  def name
    user.try :username
  end

  def name_changed?
    user.try :username_changed?
  end

  def private_leagues
    leagues.where(type: "PrivateLeague")
  end

  def participating_in_private_leagues
    (rosters.map(&:private_leagues).flatten + private_leagues.to_a).uniq
  end
end
