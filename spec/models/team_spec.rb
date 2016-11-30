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
  end
end
