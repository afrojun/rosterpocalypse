require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:roster) { FactoryGirl.create :roster }

  context "validations" do
    context "region must be one of the pre-defined regions" do
      it "creates rosters with a valid region" do
        na_roster = FactoryGirl.create :roster, region: "NA"
        expect(na_roster).to be_persisted
      end

      it "fails to create rosters with an invalid region" do
        expect { FactoryGirl.create :roster, region: "Foo" }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "#validate_one_roster_per_region" do
      let(:manager) { FactoryGirl.create :manager }

      it "fails to create the roster when another exists for that region" do
        success = FactoryGirl.create :roster, region: "NA", manager: manager
        expect(success).to be_persisted
        manager.rosters = [success]
        expect { FactoryGirl.create :roster, region: "NA", manager: manager }.to raise_error ActiveRecord::RecordInvalid
      end

      it "fails to update the roster when another exists for that region" do
        success = FactoryGirl.create :roster, region: "NA", manager: manager
        expect(success).to be_persisted
        manager.rosters = [success]
        failure = FactoryGirl.create :roster, region: "EU", manager: manager
        expect(failure).to be_persisted
        manager.reload
        manager.rosters << failure
        expect { failure.update_attributes!(region: "NA") }.to raise_error ActiveRecord::RecordInvalid
        failure.reload
        expect(failure.region).to eq "EU"
      end
    end

  end

  context "#update_including_players" do
    let(:support_player) { FactoryGirl.create :player, role: "Support" }
    let(:warrior_player) { FactoryGirl.create :player, role: "Warrior" }

    it "updates the roster name" do
      expect(roster.update_including_players(name: "foo-roster")).to eq true
      expect(roster.name).to eq "foo-roster"
    end

    it "rejects invalid updates to the roster name" do
      expect(roster.update_including_players(name: nil)).to eq false
    end

    it "updates the associated players" do
      player1 = FactoryGirl.create :player

      expect(roster.update_including_players(players: [warrior_player.id, support_player.id])).to eq true
      expect(roster.players).to eq [warrior_player, support_player]
    end

    it "requires at least 1 support player and 1 warrior player" do
      player1 = FactoryGirl.create :player
      expect(roster.update_including_players(players: [player1.id])).to eq false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["need to include at least one dedicated Support player", "need to include at least one dedicated Warrior player"])
    end

    it "requires at least 1 support player" do
      expect(roster.update_including_players(players: [warrior_player.id])).to eq false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["need to include at least one dedicated Support player"])
    end

    it "requires at least 1 warrior player" do
      expect(roster.update_including_players(players: [support_player.id])).to eq false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["need to include at least one dedicated Warrior player"])
    end

    it "overwrites the existing associated players" do
      player1 = FactoryGirl.create :player
      player2 = FactoryGirl.create :player

      expect(roster.update_including_players(players: [player1.id, support_player.id, warrior_player.id])).to eq true
      expect(roster.players).to eq [player1, support_player, warrior_player]

      expect(roster.update_including_players(players: [player2.id, support_player.id, warrior_player.id])).to eq true
      expect(roster.players).to eq [player2, support_player, warrior_player]
    end

    it "ignores non-existent players" do
      player1 = FactoryGirl.create :player
      expect(roster.update_including_players(players: [player1.id, support_player.id, warrior_player.id, 9999])).to eq true
      expect(roster.players).to eq [player1, support_player, warrior_player]
    end

    it "rejects updates with more than 5 players" do
      response = roster.update_including_players(players: [1,2,3,4,5,6])
      expect(response).to be false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["may have a maximum of 5 players"])
    end
  end
end
