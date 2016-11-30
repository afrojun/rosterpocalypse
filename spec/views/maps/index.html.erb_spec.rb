require 'rails_helper'

RSpec.describe "maps/index", type: :view do
  before(:each) do
    assign(:maps, [
      Map.create!(
        :name => "Name"
      ),
      Map.create!(
        :name => "Name"
      )
    ])
  end

  it "renders a list of maps" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
