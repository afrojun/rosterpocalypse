require 'rails_helper'

RSpec.describe "Managers", type: :request do
  describe "GET /managers" do
    it "works! (now write some real specs)" do
      sign_in :user, FactoryGirl.create(:user)
      get managers_path
      expect(response).to have_http_status(200)
    end
  end
end
