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
end
