class GameweekPlayer < ApplicationRecord
  belongs_to :gameweek
  belongs_to :player
end
