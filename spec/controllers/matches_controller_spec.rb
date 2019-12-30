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

RSpec.describe MatchesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Match. As you add validations to Match, be sure to
  # adjust the attributes here as well.
  let(:team_1) { FactoryBot.create :team }
  let(:team_2) { FactoryBot.create :team }
  let(:gameweek) { FactoryBot.create :gameweek }
  let(:stage) { FactoryBot.create :stage }

  let(:valid_attributes) do
    {
      team_1_id: team_1.id,
      team_2_id: team_2.id,
      start_date: '2017-01-06 21:00:00',
      best_of: 3,
      gameweek_id: gameweek.id,
      stage_id: stage.id
    }
  end

  let(:invalid_attributes) do
    {
      team_1_id: team_1.id,
      team_2_id: team_2.id,
      start_date: '2017-01-18 21:00:00',
      best_of: 3,
      gameweek_id: gameweek.id,
      stage_id: stage.id
    }
  end

  let(:new_team) { FactoryBot.create :team }
  let(:new_attributes) do
    {
      team_1_id: new_team.id,
      team_2_id: team_2.id,
      start_date: '2017-01-06 21:00:00',
      best_of: 5,
      gameweek_id: gameweek.id,
      stage_id: stage.id
    }
  end

  def assert_update_successful(match)
    expect(match.best_of).to eq 5
    expect(match.team_1).to eq new_team
  end

  context 'a normal user' do
    it_should_behave_like 'a normal user', Match, :match
  end

  context 'an admin user' do
    it_should_behave_like 'an admin user', Match, :match
  end
end
