require 'rails_helper'

RSpec.describe "games/index", type: :view do
  before(:each) do
    assign(:games, [
      Game.create!(
        :map => "Map",
        :duration_s => 2,
        :game_hash => "Game Hash"
      ),
      Game.create!(
        :map => "Map",
        :duration_s => 2,
        :game_hash => "Game Hash"
      )
    ])
  end

  it "renders a list of games" do
    render
    assert_select "tr>td", :text => "Map".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Game Hash".to_s, :count => 2
  end
end
