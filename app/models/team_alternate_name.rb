class TeamAlternateName < ApplicationRecord
  belongs_to :team

  validates :alternate_name, presence: true, uniqueness: true
end
