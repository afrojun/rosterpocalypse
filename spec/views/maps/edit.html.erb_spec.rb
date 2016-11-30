require 'rails_helper'

RSpec.describe "maps/edit", type: :view do
  before(:each) do
    @map = assign(:map, Map.create!(
      :name => "MyString"
    ))
  end

  it "renders the edit map form" do
    render

    assert_select "form[action=?][method=?]", map_path(@map), "post" do

      assert_select "input#map_name[name=?]", "map[name]"
    end
  end
end
