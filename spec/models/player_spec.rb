require 'rails_helper'

RSpec.describe Player, type: :model do
  context "#update_alternate_names" do
    context "after create" do
      it "creates an entry in the alternate name table" do
        player = FactoryGirl.create :player
        expect(player.alternate_names.map(&:alternate_name)).to eq [player.name, player.name.downcase]
      end
    end

    context "after update" do
      it "adds to the alternate name table if a new name is specified" do
        player = FactoryGirl.create :player, name: "Joe"
        player.update name: "Bob"
        expect(player.alternate_names.map(&:alternate_name)).to eq ["Joe", "joe", "Bob", "bob"]
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

    it "ignores case when finding players" do
      player = FactoryGirl.create :player, name: "BaR"
      expect(player.alternate_names.map(&:alternate_name)).to eq ["BaR", "bar"]
      found_player = Player.find_or_create_including_alternate_names "BAR"
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
    let(:hero1) { FactoryGirl.create :hero }
    let(:hero2) { FactoryGirl.create :hero }
    let(:team1) { FactoryGirl.create :team }
    let(:team2) { FactoryGirl.create :team }
    let(:player1) { FactoryGirl.create :player, team: team1, value: 100 }
    let(:player2) { FactoryGirl.create :player, team: team2, value: 100 }
    let(:game1) { FactoryGirl.create :game }
    let(:game_details1) { FactoryGirl.create :game_detail, game: game1, player: player1, team: team1, hero: hero1, solo_kills: 1, assists: 3, deaths: 2, time_spent_dead: 65, win: true }
    let(:game_details2) { FactoryGirl.create :game_detail, game: game1, player: player2, team: team2, hero: hero2, solo_kills: 3, assists: 2, deaths: 4, time_spent_dead: 165, win: false }

    context "#value_change" do
      it "calculates the value change correctly" do
        allow(game1).to receive(:players).and_return([player1, player2])
        allow(player1).to receive(:game_details).and_return(game_details1)
        allow(player2).to receive(:game_details).and_return(game_details2)

        expect(player1.send(:value_change, game_details1)).to eq 0.44333333333333336
        expect(player2.send(:value_change, game_details2)).to eq -0.71
      end
    end

    context "#update_value" do
      it "updates the value for player1 correctly" do
        game_details1
        game_details2

        allow(game1).to receive(:players).and_return([player1, player2])
        player1.update_value
        expect(player1.value).to eq 90.44
      end

      it "updates the value for player2 correctly" do
        game_details1
        game_details2

        allow(game1).to receive(:players).and_return([player1, player2])
        player2.update_value
        expect(player2.value).to eq 89.29
      end
    end
  end

  context "#infer_role" do
    let(:player) { FactoryGirl.create :player }

    context "single hero classification players" do
      it "identifies Specialist players as Flex" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Specialist" => ["foo"])
        player.infer_role
        expect(player.role).to eq "Flex"
      end

      it "identifies Multiclass players as Flex" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Multiclass" => ["foo"])
        player.infer_role
        expect(player.role).to eq "Flex"
      end

      it "identifies Assassin players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Assassin" => ["foo"])
        player.infer_role
        expect(player.role).to eq "Assassin"
      end

      it "identifies Warrior players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Warrior" => ["foo"])
        player.infer_role
        expect(player.role).to eq "Warrior"
      end

      it "identifies Support players" do
        expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Support" => ["foo"])
        player.infer_role
        expect(player.role).to eq "Support"
      end
    end

    context "multi-hero classification players" do
      context "with a single role" do
        it "identifies majority Assassin players as Assassin" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Assassin" => [1,2,3], "Specialist" => [9])
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,9])
          player.infer_role
          expect(player.role).to eq "Assassin"
        end

        it "identifies majority Specialist players as Flex" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Assassin" => [3], "Specialist" => [1,2,9])
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,9])
          player.infer_role
          expect(player.role).to eq "Flex"
        end
      end

      context "flexible role" do
        it "identifies mixed class players as Flex" do
          expect(player).to receive(:player_heroes_by_classification).at_least(:once).and_return("Assassin" => [3,4,5], "Specialist" => [1,2,9])
          expect(player).to receive(:game_details).at_least(:once).and_return([1,2,3,4,5,9])
          player.infer_role
          expect(player.role).to eq "Flex"
        end
      end
    end
  end
end
