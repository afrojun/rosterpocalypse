require 'rails_helper'

RSpec.describe "games/edit", type: :view do
  before(:each) do
    @game = assign(:game, Game.create!(
      :map => "MyString",
      :duration_s => 1,
      :game_hash => "MyString"
    ))
  end

  it "renders the edit game form" do
    render

    assert_select "form[action=?][method=?]", game_path(@game), "post" do

      assert_select "input#game_map[name=?]", "game[map]"

      assert_select "input#game_duration_s[name=?]", "game[duration_s]"

      assert_select "input#game_game_hash[name=?]", "game[game_hash]"
    end
  end
end
