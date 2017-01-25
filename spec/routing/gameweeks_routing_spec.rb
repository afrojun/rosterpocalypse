require "rails_helper"

RSpec.describe GameweeksController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/gameweeks").to route_to("gameweeks#index")
    end

    it "routes to #new" do
      expect(:get => "/gameweeks/new").to route_to("gameweeks#new")
    end

    it "routes to #show" do
      expect(:get => "/gameweeks/1").to route_to("gameweeks#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/gameweeks/1/edit").to route_to("gameweeks#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/gameweeks").to route_to("gameweeks#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/gameweeks/1").to route_to("gameweeks#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/gameweeks/1").to route_to("gameweeks#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/gameweeks/1").to route_to("gameweeks#destroy", :id => "1")
    end

  end
end
