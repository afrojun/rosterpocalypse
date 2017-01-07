class Transfer < ApplicationRecord
  belongs_to :gameweek
  belongs_to :roster
  belongs_to :player
end

class TransferIn < Transfer
end

class TransferOut < Transfer
end
