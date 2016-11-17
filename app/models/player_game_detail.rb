class PlayerGameDetail < ApplicationRecord
  belongs_to :player
  belongs_to :game
  belongs_to :hero
end
