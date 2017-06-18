require 'rails_helper'

RSpec.describe League, type: :model do
  let(:region) { "EU" }
  let(:manager) { FactoryGirl.create :manager }
  let(:now) { Time.now.utc }
  let(:tournament) { FactoryGirl.create :tournament, region: region, start_date:  now - 1.day, end_date: now + 1.day }
  let(:roster) { FactoryGirl.create :roster, manager: manager, tournament: tournament }
  let(:league) { FactoryGirl.create :public_league, tournament: tournament }
  let(:private_league) { FactoryGirl.create :private_league, tournament: tournament, manager: manager }


  context "validations" do
    it "doesn't allow creation of more than 10 active leagues per manager" do
      10.times do
        FactoryGirl.create :private_league, manager: manager, tournament: tournament
      end
      expect {
        FactoryGirl.create :private_league, manager: manager, tournament: tournament
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "allows site admins to create more than 10 active leagues" do
      allow(manager.user).to receive(:admin?).and_return true

      10.times do
        FactoryGirl.create :private_league, manager: manager, tournament: tournament
      end
      expect {
        FactoryGirl.create :private_league, manager: manager, tournament: tournament
      }.not_to raise_error
    end
  end

  context "#join" do
    it "adds the manager's roster to the league" do
      expect { league.join(manager) }.to change(league.rosters, :count).by(1)
      expect(league.rosters.first).to eq Roster.first
    end

    it "returns the roster" do
      expect(league.join(manager)).to be_a Roster
    end

    it "fails if the manager already has a roster in the league" do
      roster.add_to league
      manager.rosters = [roster]
      expect(league.join(manager)).to eq false
      expect(league.errors[:base].first).to include "Only one roster per manager is allowed"
    end

    context "inactive tournament" do
      let(:now) { Time.now.utc - 1.week }

      it "fails to join the league" do
        expect(league.join(manager)).to eq false
        expect(league.errors[:base].first).to include "Unable to join a league for an inactive tournament"
      end
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
      expect(league.errors[:base].first).to match /^Unable to add Roster '[\w-]+' to League '[\w-]+' since they are not for the same tournament/
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
