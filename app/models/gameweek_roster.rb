class GameweekRoster < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster
  has_many :transfers

  serialize :roster_snapshot, Hash
end
