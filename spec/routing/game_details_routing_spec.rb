require "rails_helper"

RSpec.describe GameDetailsController, type: :routing do
  describe "routing" do
    it "routes to #new" do
      expect(get: "/games/1/details/new").to route_to("game_details#new", game_id: "1")
    end

    it "routes to #edit" do
      expect(get: "/details/1/edit").to route_to("game_details#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/games/1/details").to route_to("game_details#create", game_id: "1")
    end

    it "routes to #update via PUT" do
      expect(put: "/details/1").to route_to("game_details#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/details/1").to route_to("game_details#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/details/1").to route_to("game_details#destroy", id: "1")
    end
  end
end
