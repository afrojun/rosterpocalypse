require 'rails_helper'

RSpec.describe "Rosters", type: :request do
  describe "GET /rosters" do
    it "works! (now write some real specs)" do
      sign_in :user, FactoryGirl.create(:user)
      get rosters_path
      expect(response).to have_http_status(200)
    end
  end
end
