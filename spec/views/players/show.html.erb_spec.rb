require 'rails_helper'

RSpec.describe "players/show", type: :view do
  before(:each) do
    @player = assign(:player, Player.create!(
      :name => "Name",
      :role => "Role",
      :country => "Country",
      :region => "Region",
      :cost => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Role/)
    expect(rendered).to match(/Country/)
    expect(rendered).to match(/Region/)
    expect(rendered).to match(/2/)
  end
end
