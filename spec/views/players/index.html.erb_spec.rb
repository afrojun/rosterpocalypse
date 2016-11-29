require 'rails_helper'

RSpec.describe "players/index", type: :view do
  before(:each) do
    assign(:players, [
      Player.create!(
        :name => "Name1",
        :role => "Role",
        :country => "Country",
        :region => "Region",
        :cost => 2
      ),
      Player.create!(
        :name => "Name2",
        :role => "Role",
        :country => "Country",
        :region => "Region",
        :cost => 2
      )
    ])
  end

  it "renders a list of players" do
    render
    assert_select "tr>td", :text => "Name1".to_s, :count => 1
    assert_select "tr>td", :text => "Name2".to_s, :count => 1
    assert_select "tr>td", :text => "Role".to_s, :count => 2
    assert_select "tr>td", :text => "Country".to_s, :count => 2
    assert_select "tr>td", :text => "Region".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
