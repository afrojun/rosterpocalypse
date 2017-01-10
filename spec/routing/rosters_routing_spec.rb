require "rails_helper"

RSpec.describe RostersController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/rosters").to route_to("rosters#index")
    end

    it "routes to #new" do
      expect(:get => "/rosters/new").to route_to("rosters#new")
    end

    it "routes to #show" do
      expect(:get => "/rosters/1").to route_to("rosters#show", :id => "1")
    end

    it "routes to #manage" do
      expect(:get => "/rosters/1/manage").to route_to("rosters#manage", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/rosters").to route_to("rosters#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/rosters/1").to route_to("rosters#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/rosters/1").to route_to("rosters#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/rosters/1").to route_to("rosters#destroy", :id => "1")
    end

  end
end
