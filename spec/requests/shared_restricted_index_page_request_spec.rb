require 'rails_helper'

shared_examples_for "a restricted index page request" do |model_index_path_method|
  describe "GET /#{model_index_path_method.to_s.gsub('_path', '')}" do
    context "user not signed in" do
      it "redirects to the welcome page" do
        send :get, send(model_index_path_method)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to root_url
        expect(flash["alert"]).to match /You don't have permission to take this action/
      end
    end

    context "normal user signed in" do
      it "redirects to the welcome page" do
        sign_in :user, FactoryGirl.create(:user)
        send :get, send(model_index_path_method)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to root_url
        expect(flash["alert"]).to match /You don't have permission to take this action/
      end
    end

    context "admin user signed in" do
      it "loads the games index page" do
        sign_in :user, FactoryGirl.create(:user, admin: true)
        send :get, send(model_index_path_method)
        expect(response).to have_http_status(200)
        expect(flash["alert"]).to eq nil
      end
    end
  end
end