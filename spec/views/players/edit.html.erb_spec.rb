require 'rails_helper'

RSpec.describe "players/edit", type: :view do
  before(:each) do
    @player = assign(:player, Player.create!(
      :name => "MyString",
      :role => "MyString",
      :country => "MyString",
      :region => "MyString",
      :cost => 1
    ))
  end

  it "renders the edit player form" do
    render

    assert_select "form[action=?][method=?]", player_path(@player), "post" do

      assert_select "input#player_name[name=?]", "player[name]"

      assert_select "input#player_role[name=?]", "player[role]"

      assert_select "input#player_country[name=?]", "player[country]"

      assert_select "input#player_region[name=?]", "player[region]"

      assert_select "input#player_cost[name=?]", "player[cost]"
    end
  end
end
