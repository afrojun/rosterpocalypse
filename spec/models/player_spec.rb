require 'rails_helper'

RSpec.describe Player, type: :model do
  it "creates an entry in the alternate name table via a callback" do
    player = FactoryGirl.create :player
    expect(PlayerAlternateName.where(alternate_name: player.name).first.player).to eq player
  end

  context "#find_or_create_including_alternate_names" do
    it "creates a new player when it doesn't already exist" do
      player = Player.find_or_create_including_alternate_names "foo"
      expect(player.name).to eq "foo"
    end

    it "finds an existing player if one exists" do
      player = FactoryGirl.create :player, name: "bar"
      found_player = Player.find_or_create_including_alternate_names "bar"
      expect(found_player).to eql player
    end
  end
end
