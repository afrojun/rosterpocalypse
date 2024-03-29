require 'rails_helper'

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

RSpec.describe GameweeksController, type: :controller do
  login_user

  let(:tournament) { FactoryBot.create :tournament, region: 'EU', start_date: Time.now.utc - 1.hour, end_date: Time.now.utc + 1.hour }
  let(:gameweek) { FactoryBot.create :gameweek, tournament: tournament }
  let(:league) { FactoryBot.create(:private_league, name: 'HGC EU 2017 - Phase 2', tournament: tournament) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # GameweeksController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all tournaments as @tournaments' do
      tournament
      get :index, params: {}, session: valid_session
      expect(assigns(:tournaments)).to eq([tournament])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested gameweek as @gameweek' do
      gameweek
      league
      get :show, params: { id: gameweek.to_param }, session: valid_session
      expect(assigns(:gameweek)).to eq(gameweek)
    end
  end
end
