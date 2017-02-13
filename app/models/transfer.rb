class Transfer < ApplicationRecord
  belongs_to :gameweek_roster
  has_one :gameweek, through: :gameweek_roster
  has_one :roster, through: :gameweek_roster
  belongs_to :player_in, class_name: "Player"
  belongs_to :player_out, class_name: "Player"
end
