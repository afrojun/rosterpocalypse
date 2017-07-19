require 'rails_helper'
require 'controllers/shared_normal_user_controller_actions_spec'
require 'controllers/shared_admin_user_controller_actions_spec'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe GamesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Game. As you add validations to Game, be sure to
  # adjust the attributes here as well.
  let(:map) { FactoryGirl.create(:map) }
  let(:valid_attributes) do
    {
      map_id: map.id,
      start_date: Time.now.utc.to_datetime,
      duration_s: 1000,
      game_hash: "abcde"
    }
  end

  let(:invalid_attributes) do
    {
      map_id: FactoryGirl.create(:map).id,
      start_date: Time.now.utc.to_datetime,
      duration_s: 1000,
      game_hash: nil
    }
  end

  let(:new_map) { FactoryGirl.create(:map) }
  let(:new_attributes) do
    {
      map_id: new_map.id,
      start_date: Time.now.utc.to_datetime,
      duration_s: 650,
      game_hash: "12345"
    }
  end

  def assert_update_successful game
    expect(game.map.name).to eq new_map.name
    expect(game.duration_s).to eq 650
    expect(game.game_hash).to eq "12345"
  end

  context "a normal user" do
    it_should_behave_like "a normal user", Game, :game
  end

  context "an admin user" do
    it_should_behave_like "an admin user", Game, :game
  end
end
