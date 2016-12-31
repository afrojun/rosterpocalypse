require 'rails_helper'

RSpec.describe "Games", type: :request do
  describe "GET /games" do
    context "user not signed in" do
      it "redirects to the sign in page" do
        get games_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to new_user_session_url
      end
    end

    context "user signed in" do
      it "loads the games index page" do
        sign_in :user, FactoryGirl.create(:user)
        get games_path
        expect(response).to have_http_status(200)
      end
    end
  end
end
