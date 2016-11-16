require 'rails_helper'

RSpec.describe "games/new", type: :view do
  before(:each) do
    assign(:game, Game.new(
      :map => "MyString",
      :duration_s => 1,
      :game_hash => "MyString"
    ))
  end

  it "renders new game form" do
    render

    assert_select "form[action=?][method=?]", games_path, "post" do

      assert_select "input#game_map[name=?]", "game[map]"

      assert_select "input#game_duration_s[name=?]", "game[duration_s]"

      assert_select "input#game_game_hash[name=?]", "game[game_hash]"
    end
  end
end
