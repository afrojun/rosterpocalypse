require 'rails_helper'

RSpec.describe RostersController, type: :controller do
  login_user

  # This should return the minimal set of attributes required to create a valid
  # Roster. As you add validations to Roster, be sure to
  # adjust the attributes here as well.
  let(:now) { Time.now.utc }
  let(:tournament) { FactoryGirl.create :tournament, start_date: now - 1.day, end_date: now + 1.day }
  let(:valid_attributes) do
    {
      name: 'AwesomeRoster',
      tournament: tournament
    }
  end

  let(:invalid_attributes) do
    {
      name: 'Bad',
      tournament: tournament
    }
  end

  let(:manager) { FactoryGirl.create :manager, user: subject.current_user }
  let(:roster) { FactoryGirl.create :roster, valid_attributes.merge(manager: manager) }
  let(:league) { FactoryGirl.create :private_league, tournament: tournament }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RostersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before :each do
    roster.add_to league
  end

  describe 'GET #index' do
    it "assigns user's rosters as @my_rosters" do
      roster
      get :index, params: {}, session: valid_session
      expect(assigns(:my_rosters)).to eq([roster])
    end

    it "assigns user's leagues as @my_leagues" do
      league
      get :index, params: {}, session: valid_session
      expect(assigns(:my_leagues)).to eq([league])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested roster as @roster' do
      get :show, params: { id: roster.id }, session: valid_session
      expect(assigns(:roster)).to eq(roster)
    end
  end

  describe 'GET #manage' do
    it 'assigns the requested roster as @roster' do
      get :manage, params: { id: roster.id }, session: valid_session
      expect(assigns(:roster)).to eq(roster)
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) do
        {
          name: 'MehRoster'
        }
      end

      it 'updates the requested roster' do
        put :update, params: { id: roster.id, roster: new_attributes }, session: valid_session
        roster.reload
        expect(roster.name).to eq 'MehRoster'
      end

      it 'assigns the requested roster as @roster' do
        put :update, params: { id: roster.id, roster: valid_attributes }, session: valid_session
        expect(assigns(:roster)).to eq(roster)
      end

      it 'redirects to the roster' do
        put :update, params: { id: roster.id, roster: valid_attributes }, session: valid_session
        expect(response).to redirect_to(roster)
      end
    end

    context 'with invalid params' do
      it 'does not update the roster' do
        put :update, params: { id: roster.id, roster: invalid_attributes }, session: valid_session
        roster.reload
        expect(roster.name).to eq 'AwesomeRoster'
      end

      it 'assigns the roster as @roster' do
        put :update, params: { id: roster.id, roster: invalid_attributes }, session: valid_session
        expect(assigns(:roster)).to eq(roster)
      end

      it "re-renders the 'manage' template" do
        put :update, params: { id: roster.id, roster: invalid_attributes }, session: valid_session
        expect(response).to render_template('manage')
      end
    end

    context 'for a roster that does not belong to the user' do
      let(:other_user) { FactoryGirl.create :user }
      let(:other_manager) { FactoryGirl.create :manager, user: other_user }
      let(:other_roster) { FactoryGirl.create :roster, manager: other_manager }

      it 'denies access' do
        put :update, params: { id: other_roster.id, roster: valid_attributes }, session: valid_session
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq "You don't have permission to take this action."
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested roster' do
      roster
      expect do
        delete :destroy, params: { id: roster.id }, session: valid_session
      end.to change(Roster, :count).by(-1)
    end

    it 'redirects to the rosters list' do
      delete :destroy, params: { id: roster.id }, session: valid_session
      expect(response).to redirect_to(rosters_url)
    end
  end
end
