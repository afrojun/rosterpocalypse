require 'rails_helper'

RSpec.describe PlayerGameDetail, type: :model do
  let(:player) { FactoryGirl.create :player, cost: 100 }
  let(:detail) { FactoryGirl.create :player_game_detail, player: player, assists: 5 }

  it "updates the player cost after creation" do
    cost = player.cost
    detail
    expect(player.cost).to eq (cost + detail.cost_change)
  end

  it "reverts the player cost changes before making updates" do
    initial_cost = player.cost
    detail
    cost_after_create = player.cost
    cost_change = detail.cost_change

    detail.update_attribute :assists, 1
    cost_change_after_update = detail.cost_change
    expect(player.cost).to eq initial_cost+cost_change_after_update
  end
end
