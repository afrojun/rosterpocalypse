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
      FactoryGirl.create :game_detail, player: player
      id = player.id
      player.destroy
      expect(Player.where(id: id).first).to eq player
      expect(player.errors.details[:base].first[:error]).to include("Unable to delete #{player.name}")
    end
  end

  context "updating player value" do
    let(:player) { FactoryGirl.create :player }
    let(:game_details1) { FactoryGirl.create :game_detail, player: player, solo_kills: 1, assists: 3, deaths: 2, time_spent_dead: 65, win: true }
    let(:game_details2) { FactoryGirl.create :game_detail, player: player, solo_kills: 2, assists: 6, deaths: 0, time_spent_dead: 0, win: true }
    let(:game_details3) { FactoryGirl.create :game_detail, player: player, solo_kills: 3, assists: 2, deaths: 4, time_spent_dead: 165, win: false }

    context "#value_change" do
      it "updates the value correctly" do
        expect(player.send :value_change, game_details1).to eq 2
        expect(player.send :value_change, game_details2).to eq 5
        expect(player.send :value_change, game_details3).to eq -5
      end
    end

    context "#update_value" do
      it "updates the value correctly" do
        init_details = [game_details1, game_details2, game_details3]
        player.update_value
        expect(player.value).to eq 102
      end
    end
  end

  context "#infer_role" do
    let(:player) { FactoryGirl.create :player }

    context "single hero classification players" do
      it "identifies Specialist players as Flex" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Specialist" => ["foo"]})
        player.infer_role
        expect(player.role).to eq "Flex"
      end

      it "identifies Multiclass players as Flex" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Multiclass" => ["foo"]})
        player.infer_role
        expect(player.role).to eq "Flex"
      end

      it "identifies Assassin players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Assassin" => ["foo"]})
        player.infer_role
        expect(player.role).to eq "Assassin"
      end

      it "identifies Warrior players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Warrior" => ["foo"]})
        player.infer_role
        expect(player.role).to eq "Warrior"
      end

      it "identifies Support players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Support" => ["foo"]})
        player.infer_role
        expect(player.role).to eq "Support"
      end
    end

    context "multi-hero classification players" do

      context "with a single role" do
        it "identifies majority Assassin players as Assassin" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Assassin" => [1,2,3], "Specialist" => [9]})
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,9])
          player.infer_role
          expect(player.role).to eq "Assassin"
        end

        it "identifies majority Specialist players as Flex" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Assassin" => [3], "Specialist" => [1,2,9]})
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,9])
          player.infer_role
          expect(player.role).to eq "Flex"
        end
      end

      context "flexible role" do
        it "identifies mixed class players as Flex" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return({"Assassin" => [3,4,5], "Specialist" => [1,2,9]})
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,4,5,9])
          player.infer_role
          expect(player.role).to eq "Flex"
        end
      end
    end
  end
end
