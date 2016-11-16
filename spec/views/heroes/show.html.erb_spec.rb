require 'rails_helper'

RSpec.describe "heroes/show", type: :view do
  before(:each) do
    @hero = assign(:hero, Hero.create!(
      :name => "Name",
      :internal_name => "Internal Name",
      :classification => "Classification"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/Internal Name/)
    expect(rendered).to match(/Classification/)
  end
end
