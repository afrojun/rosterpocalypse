require "rails_helper"

RSpec.describe GameweeksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gameweeks").to route_to("gameweeks#index")
    end

    it "routes to #show" do
      expect(:get => "/gameweeks/1").to route_to("gameweeks#show", :id => "1")
    end
  end
end
