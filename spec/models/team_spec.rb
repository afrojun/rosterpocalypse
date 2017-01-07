require 'rails_helper'

RSpec.describe Team, type: :model do
  it "creates an entry in the alternate name table via a callback" do
    team = FactoryGirl.create :team
    expect(TeamAlternateName.where(alternate_name: team.name).first.team).to eq team
  end

  context "#find_or_create_including_alternate_names" do
    it "creates a new team when it doesn't already exist" do
      team = Team.find_or_create_including_alternate_names "foo"
      expect(team.name).to eq "foo"
    end

    it "finds an existing team if one exists" do
      team = FactoryGirl.create :team, name: "bar"
      found_team = Team.find_or_create_including_alternate_names "bar"
      expect(found_team).to eql team
    end

    it "ignores case when finding teams" do
      team = FactoryGirl.create :team, name: "BaR Team"
      expect(team.alternate_names.map(&:alternate_name)).to eq ["BaR Team", "bar team"]
      found_team = Team.find_or_create_including_alternate_names "BAR TEaM"
      expect(found_team).to eql team
    end
  end

  context "#destroy" do
    let(:team) { FactoryGirl.create :team }

    it "succeeds if there are no associated games" do
      id = team.id
      team.destroy
      expect(Team.where(id: id)).to be_blank
    end

    it "fails if there are any associated games" do
      FactoryGirl.create :game_detail, team: team
      id = team.id
      team.destroy
      expect(Team.where(id: id).first).to eq team
      expect(team.errors.details[:base].first[:error]).to include("Unable to delete #{team.name}")
    end
  end
end
