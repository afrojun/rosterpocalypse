require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:roster) { FactoryGirl.create :roster }

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
