class GameweekRoster < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster

  serialize :roster_snapshot, Hash
end
