require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:roster) { FactoryGirl.create :roster }

  context "#update" do
    it "updates the roster name" do
      roster.update(name: "foo-roster")
      expect(roster.name).to eq "foo-roster"
    end

    it "updates the associated players" do
      player1 = FactoryGirl.create :player
      player2 = FactoryGirl.create :player

      roster.update(players: [player1.id, player2.id])

      expect(roster.players).to eq [player1, player2]
    end

    it "overwrites the existing associated players" do
      player1 = FactoryGirl.create :player
      player2 = FactoryGirl.create :player
      player3 = FactoryGirl.create :player
      player4 = FactoryGirl.create :player

      roster.update(players: [player1.id, player2.id])
      expect(roster.players).to eq [player1, player2]

      roster.update(players: [player3.id, player4.id])
      expect(roster.players).to eq [player3, player4]
    end

    it "ignores non-existent players" do
      player1 = FactoryGirl.create :player
      roster.update(players: [player1.id, 9999])
      expect(roster.players).to eq [player1]
    end

    it "rejects updates with more than 5 players" do
      response = roster.update(players: [1,2,3,4,5,6])
      expect(response).to be false
      expect(roster.players).to eq []
      expect(roster.errors.messages).to include(rosters: ["may have a maximum of 5 players"])
    end
  end
end
