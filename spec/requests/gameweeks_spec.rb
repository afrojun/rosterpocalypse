require 'rails_helper'

RSpec.describe "Gameweeks", type: :request do
  describe "GET /tournament/1/gameweeks" do
    it "works! (now write some real specs)" do
      sign_in :user, FactoryGirl.create(:user)
      tournament = FactoryGirl.create :tournament
      get tournament_gameweeks_path(tournament_id: tournament.id)
      expect(response).to have_http_status(200)
    end
  end
end
