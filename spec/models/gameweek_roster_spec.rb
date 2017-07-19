require 'rails_helper'

RSpec.describe GameweekRoster, type: :model do
  let(:tournament) { FactoryGirl.create :tournament }
  let(:league) { FactoryGirl.create :private_league, tournament: tournament }
  let(:roster) { FactoryGirl.create :roster, tournament: tournament }
  let(:gameweek_roster) { roster.gameweek_rosters[1] }
  let(:gameweek) { gameweek_roster.gameweek }
  let(:num_players) { 5 }
  let(:players) { FactoryGirl.create_list :player, num_players }
  let(:gameweek_players) do
    players.map do |player|
      FactoryGirl.create :gameweek_player, player: player, gameweek: gameweek
    end
  end
  let(:league_gameweek_players) do
    gameweek_players.map do |gameweek_player|
      FactoryGirl.create :league_gameweek_player, gameweek_player: gameweek_player, league: league
    end
  end

  context "#next" do
    it "returns the gameweek_roster for the next gameweek" do
      expect(roster.gameweek_rosters[0].next).to eq roster.gameweek_rosters[1]
    end

    it "returns the last gameweek_roster if there is no next gameweek_roster" do
      expect(roster.gameweek_rosters[3].next).to eq roster.gameweek_rosters[3]
    end

    it "returns nil if 'safe' is set to false" do
      expect(roster.gameweek_rosters[3].next(false)).to eq nil
    end
  end

  context "#previous" do
    it "returns the gameweek_roster for the previous gameweek" do
      expect(roster.gameweek_rosters[1].previous).to eq roster.gameweek_rosters[0]
    end

    it "returns the first gameweek_roster if there is no previous gameweek_roster" do
      expect(roster.gameweek_rosters[0].previous).to eq roster.gameweek_rosters[0]
    end

    it "returns nil if 'safe' is set to false" do
      expect(roster.gameweek_rosters[0].previous(false)).to eq nil
    end
  end

  context "#create_snapshot" do
    it "returns false if there are no players" do
      expect(gameweek_roster.create_snapshot).to eq false
      expect(gameweek_roster.roster_snapshot).to eq({})
    end

    it "creates the snapshot if there are 5 players" do
      expect(gameweek_roster.create_snapshot(players)).to eq true
      expect(gameweek_roster.roster_snapshot[:player_ids]).to eq players.map(&:id)
    end

    it "defaults to getting the players from the roster" do
      roster.players << players
      expect(gameweek_roster.create_snapshot).to eq true
      expect(gameweek_roster.roster_snapshot[:player_ids]).to eq players.map(&:id)
    end
  end

  context "#update_points" do
    context "error cases" do
      it "returns false if there is no snapshot" do
        expect(gameweek_roster.update_points).to eq false
      end

      context "less than 5 players" do
        let(:num_players) { 3 }

        it "returns false" do
          gameweek_roster.create_snapshot(players)
          expect(gameweek_roster.update_points).to eq false
          expect(gameweek_roster.points).to eq nil
        end
      end

      context "expensive players" do
        let(:players) { FactoryGirl.create_list :player, num_players, value: 110 }

        it "returns false" do
          gameweek_roster.create_snapshot(players)
          expect(gameweek_roster.update_points).to eq false
          expect(gameweek_roster.points).to eq nil
        end
      end
    end

    it "updates points for valid snapshots" do
      roster.add_to league
      league_gameweek_players

      gameweek_roster.create_snapshot(players)
      gameweek_roster.add_gameweek_players
      expect(gameweek_roster.update_points).to eq true
      expect(gameweek_roster.points).to eq 75
    end
  end
end
