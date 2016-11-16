require 'rails_helper'

RSpec.describe "games/show", type: :view do
  before(:each) do
    @game = assign(:game, Game.create!(
      :map => "Map",
      :duration_s => 2,
      :game_hash => "Game Hash"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Map/)
    expect(rendered).to match(/2/)
    expect(rendered).to match(/Game Hash/)
  end
end
