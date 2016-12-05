class RosterPlayer < ApplicationRecord
  has_one :roster
  has_one :player
end
