require 'rails_helper'

RSpec.describe League, type: :model do
  let(:region) { "EU" }
  let(:manager) { FactoryGirl.create :manager }
  let(:tournament) { FactoryGirl.create :tournament, region: region }
  let(:roster) { FactoryGirl.create :roster, manager: manager, tournament: tournament }
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
      expect(league.errors[:base].first).to include "You do not have a Roster for this League's tournament"
    end
  end

  context "#leave" do
    it "removes the manager's roster from the league" do
      league.add roster
      expect { league.leave(manager) }.to change(league.rosters, :count).by(-1)
    end

    it "returns the roster" do
      league.add roster
      expect(league.leave(manager).id).to eq roster.id
    end

    it "fails if a roster cannot be found for the region" do
      expect(league.leave(manager)).to eq false
      expect(league.errors[:base].first).to include "You do not have any Rosters in this League"
    end
  end

  context "#add" do
    it "doesn't allow adding a roster for a different region to the league" do
      other_tournament = FactoryGirl.create :tournament, region: "NA"
      other_roster = FactoryGirl.create :roster, tournament: other_tournament

      expect(league.add(other_roster)).to eq false
      expect(league.errors[:base].first).to match /^Unable to add Roster '\w+' to League '[\w ]+' since they are not for the same tournament/
    end

    it "adds the roster to the league" do
      expect { league.add(roster) }.to change(league.rosters, :count).by(1)
      expect(league.rosters.first).to eq roster
    end
  end

  context "#remove" do
    it "removes the roster from a league" do
      expect(league.add(roster)).to eq true
      expect { league.remove roster }.to change(roster.leagues, :count).by(-1)
    end
  end
end
