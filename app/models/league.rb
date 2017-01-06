class League < ApplicationRecord
  extend FriendlyId
  friendly_id :name

  belongs_to :manager
  belongs_to :tournament
  has_and_belongs_to_many :rosters

  validates :name, presence: true, uniqueness: true
  validates_format_of :name, with: /^[a-zA-Z0-9 _\.]*$/, multiline: true
  validates_length_of :name, minimum: 4, maximum: 20
  validates :type, presence: true

end
