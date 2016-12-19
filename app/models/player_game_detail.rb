class PlayerGameDetail < ApplicationRecord
  belongs_to :player
  belongs_to :game
  belongs_to :hero
  belongs_to :team
  # Other attributes
  # solo_kills, assists, deaths, time_spent_dead, team_colour, win

end
