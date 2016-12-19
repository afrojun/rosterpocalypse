require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:roster) { FactoryGirl.create :roster }

  context "#update_including_players" do
    it "updates the roster name" do
      expect(roster.update_including_players(name: "foo-roster")).to eq true
      expect(roster.name).to eq "foo-roster"
    end

    it "rejects invalid updates to the roster name" do
      expect(roster.update_including_players(name: nil)).to eq false
    end

    it "updates the associated players" do
      player1 = FactoryGirl.create :player
      player2 = FactoryGirl.create :player

      expect(roster.update_including_players(players: [player1.id, player2.id])).to eq true

      expect(roster.players).to eq [player1, player2]
    end

    it "overwrites the existing associated players" do
      player1 = FactoryGirl.create :player
      player2 = FactoryGirl.create :player
      player3 = FactoryGirl.create :player
      player4 = FactoryGirl.create :player

      expect(roster.update_including_players(players: [player1.id, player2.id])).to eq true
      expect(roster.players).to eq [player1, player2]

      expect(roster.update_including_players(players: [player3.id, player4.id])).to eq true
      expect(roster.players).to eq [player3, player4]
    end

    it "ignores non-existent players" do
      player1 = FactoryGirl.create :player
      expect(roster.update_including_players(players: [player1.id, 9999])).to eq true
      expect(roster.players).to eq [player1]
    end

    it "rejects updates with more than 5 players" do
      response = roster.update_including_players(players: [1,2,3,4,5,6])
      expect(response).to be false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["may have a maximum of 5 players"])
    end
  end
end
