require 'rails_helper'

RSpec.describe "heroes/index", type: :view do
  before(:each) do
    assign(:heroes, [
      Hero.create!(
        :name => "Name",
        :internal_name => "Internal Name",
        :classification => "Classification"
      ),
      Hero.create!(
        :name => "Name",
        :internal_name => "Internal Name",
        :classification => "Classification"
      )
    ])
  end

  it "renders a list of heroes" do
    render
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Internal Name".to_s, :count => 2
    assert_select "tr>td", :text => "Classification".to_s, :count => 2
  end
end
