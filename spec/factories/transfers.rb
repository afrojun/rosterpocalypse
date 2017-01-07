FactoryGirl.define do
  factory :transfer_in do
    gameweek
    roster
    player
    type "TransferIn"
  end

  factory :transfer_out do
    gameweek
    roster
    player
    type "TransferOut"
  end
end
