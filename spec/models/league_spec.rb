require 'rails_helper'

RSpec.describe League, type: :model do
  let(:region) { "EU" }
  let(:manager) { FactoryGirl.create :manager }
  let(:tournament) { FactoryGirl.create :tournament, region: region }
  let(:roster) { FactoryGirl.create :roster, manager: manager, region: region }
  let(:league) { FactoryGirl.create :public_league, tournament: tournament }
  let(:private_league) { FactoryGirl.create :private_league, tournament: tournament, manager: manager }

  context "#join" do
    it "adds the manager's roster to the league" do
      roster
      expect { league.join(manager) }.to change(league.rosters, :count).by(1)
      expect(league.rosters.first).to eq roster
    end

    it "returns the roster" do
      roster
      expect(league.join(manager).id).to eq roster.id
    end

    it "fails if a roster cannot be found for the region" do
      expect(league.join(manager)).to eq false
      expect(league.errors[:base].first).to include "You do not have a Roster for the 'EU' region"
    end
  end

  context "#leave" do
    it "removes the manager's roster from the league" do
      league.add roster
      private_league.add roster
      expect { league.leave(manager) }.to change(league.rosters, :count).by(-1)
    end

    it "returns the roster" do
      league.add roster
      private_league.add roster
      expect(league.leave(manager).id).to eq roster.id
    end

    it "fails if a roster cannot be found for the region" do
      expect(league.leave(manager)).to eq false
      expect(league.errors[:base].first).to include "You do not have any Rosters in this League"
    end
  end

  context "#add" do
    it "doesn't allow adding a roster for a different region to the league" do
      roster = FactoryGirl.create :roster, region: "NA"
      expect(league.add(roster)).to eq false
      expect(league.errors[:base].first).to match /^Unable to add Roster '\w+' for region '\w+' to League/
    end

    it "adds the roster to the league" do
      expect { league.add(roster) }.to change(league.rosters, :count).by(1)
      expect(league.rosters.first).to eq roster
    end

    it "creates gameweek_rosters for all gameweeks in the tournament" do
      expect(league.add(roster)).to eq true
      expect(roster.gameweek_rosters.count).to eq 3
    end

    it "creates only one set of gameweek_rosters for all leagues for a tournament" do
      expect(league.add(roster)).to eq true
      expect(private_league.add(roster)).to eq true
      expect(roster.gameweek_rosters.count).to eq 3
    end
  end

  context "#remove" do
    it "doesn't allow removing a roster from all leagues" do
      expect(league.add(roster)).to eq true
      expect(league.remove(roster)).to eq false
      expect(league.errors[:base].first).to include "Unable to leave league"
    end

    it "removes the roster from a league" do
      expect(league.add(roster)).to eq true
      expect(private_league.add(roster)).to eq true
      expect { league.remove roster }.to change(roster.leagues, :count).by(-1)
    end

    it "deletes gameweek_rosters if the roster is not in any leagues for a tournament" do
      tournament2 = FactoryGirl.create :tournament, region: region
      league2 = FactoryGirl.create :private_league, tournament: tournament2
      league.add roster
      league2.add roster
      expect(roster.gameweek_rosters.count).to eq 6
      league2.remove roster
      expect(roster.gameweek_rosters.count).to eq 3
    end

    it "only deletes gameweek_rosters that have no points" do
      tournament2 = FactoryGirl.create :tournament, region: region
      league2 = FactoryGirl.create :private_league, tournament: tournament2
      league.add roster
      league2.add roster
      expect(roster.gameweek_rosters.count).to eq 6
      gameweek_roster = roster.gameweek_rosters_for_tournament(tournament2).first
      gameweek_roster.update_attribute(:points, 123)
      league2.remove roster
      expect(roster.gameweek_rosters.count).to eq 4
      expect(roster.gameweek_rosters).to include gameweek_roster
    end
  end
end
