class Manager < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :user
  has_many :rosters

  def name
    user.username
  end
end
