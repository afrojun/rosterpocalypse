class Manager < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :user
  has_many :rosters

  def name
    user.try :username
  end

  def name_changed?
    user.try :name_changed?
  end
end
