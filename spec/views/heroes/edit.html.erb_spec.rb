require 'rails_helper'

RSpec.describe "heroes/edit", type: :view do
  before(:each) do
    @hero = assign(:hero, Hero.create!(
      :name => "MyString",
      :internal_name => "MyString",
      :classification => "MyString"
    ))
  end

  it "renders the edit hero form" do
    render

    assert_select "form[action=?][method=?]", hero_path(@hero), "post" do

      assert_select "input#hero_name[name=?]", "hero[name]"

      assert_select "input#hero_internal_name[name=?]", "hero[internal_name]"

      assert_select "input#hero_classification[name=?]", "hero[classification]"
    end
  end
end
