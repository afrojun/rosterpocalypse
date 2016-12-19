require 'rails_helper'

RSpec.describe Player, type: :model do
  context "#update_alternate_names" do

    context "after create" do
      it "creates an entry in the alternate name table" do
        player = FactoryGirl.create :player
        expect(player.alternate_names.map(&:alternate_name)).to eq [player.name]
      end

    end

    context "after update" do
      it "adds to the alternate name table if a new name is specified" do
        player = FactoryGirl.create :player, name: "Joe"
        player.update_attribute :name, "Bob"
        expect(player.alternate_names.map(&:alternate_name)).to eq ["Joe", "Bob"]
      end

    end

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

  context "#destroy" do
    let(:player) { FactoryGirl.create :player }

    it "succeeds if there are no associated games" do
      id = player.id
      player.destroy
      expect(Player.where(id: id)).to be_blank
    end

    it "fails if there are any associated games" do
      FactoryGirl.create :player_game_detail, player: player
      id = player.id
      player.destroy
      expect(Player.where(id: id).first).to eq player
      expect(player.errors.details[:base].first[:error]).to include("Unable to delete #{player.name}")
    end
  end
end
