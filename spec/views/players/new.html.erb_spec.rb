require 'rails_helper'

RSpec.describe "players/new", type: :view do
  before(:each) do
    assign(:player, Player.new(
      :name => "MyString",
      :role => "MyString",
      :country => "MyString",
      :region => "MyString",
      :cost => 1
    ))
  end

  it "renders new player form" do
    render

    assert_select "form[action=?][method=?]", players_path, "post" do

      assert_select "input#player_name[name=?]", "player[name]"

      assert_select "input#player_role[name=?]", "player[role]"

      assert_select "input#player_country[name=?]", "player[country]"

      assert_select "input#player_region[name=?]", "player[region]"

      assert_select "input#player_cost[name=?]", "player[cost]"
    end
  end
end
