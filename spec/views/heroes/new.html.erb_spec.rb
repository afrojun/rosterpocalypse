require 'rails_helper'

RSpec.describe "heroes/new", type: :view do
  before(:each) do
    assign(:hero, Hero.new(
      :name => "MyString",
      :internal_name => "MyString",
      :classification => "MyString"
    ))
  end

  it "renders new hero form" do
    render

    assert_select "form[action=?][method=?]", heroes_path, "post" do

      assert_select "input#hero_name[name=?]", "hero[name]"

      assert_select "input#hero_internal_name[name=?]", "hero[internal_name]"

      assert_select "input#hero_classification[name=?]", "hero[classification]"
    end
  end
end
