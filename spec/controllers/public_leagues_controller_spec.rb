require 'rails_helper'

RSpec.describe PublicLeaguesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # League. As you add validations to League, be sure to
  # adjust the attributes here as well.
  let(:now) { Time.now.utc }
  let(:tournament) { FactoryBot.create :tournament, start_date:  now - 1.day, end_date: now + 1.day }
  let(:manager) { FactoryBot.create :manager, user: subject.current_user }
  let(:league) { FactoryBot.create :public_league, valid_attributes.merge(manager: manager) }

  let(:valid_attributes) do
    {
      name: 'Big League',
      tournament_id: tournament.id,
      role_stat_modifiers: League::DEFAULT_ROLE_STAT_MODIFIERS,
      required_player_roles: League::DEFAULT_REQUIRED_PLAYER_ROLES
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      tournament_id: tournament.id
    }
  end

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LeaguesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  context 'as a normal user' do
    login_user

    def check_access_denied
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to eq "You don't have permission to take this action."
    end

    describe 'GET #index' do
      it 'assigns all public leagues as @public_leagues' do
        league
        get :index, params: {}, session: valid_session
        expect(assigns(:public_leagues)).to eq([league])
      end
    end

    describe 'GET #show' do
      it 'assigns the requested league as @league' do
        get :show, params: { id: league.to_param }, session: valid_session
        expect(assigns(:league)).to eq(league)
      end
    end

    describe 'GET #new' do
      it 'denies access' do
        get :new, params: {}, session: valid_session
        check_access_denied
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested league as @league' do
        get :edit, params: { id: league.to_param }, session: valid_session
        check_access_denied
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'assigns a newly created league as @league' do
          post :create, params: { public_league: valid_attributes }, session: valid_session
          check_access_denied
        end
      end
    end

    describe 'PUT #update' do
      it 'updates the requested league' do
        put :update, params: { id: league.to_param, public_league: valid_attributes }, session: valid_session
        check_access_denied
      end
    end

    describe 'DELETE #destroy' do
      it 'redirects to the leagues list' do
        delete :destroy, params: { id: league.to_param }, session: valid_session
        check_access_denied
      end
    end
  end

  context 'as an admin user' do
    login_admin

    describe 'GET #index' do
      it 'assigns all public leagues as @public_leagues' do
        league
        get :index, params: {}, session: valid_session
        expect(assigns(:public_leagues)).to eq([league])
      end
    end

    describe 'GET #show' do
      it 'assigns the requested league as @league' do
        get :show, params: { id: league.to_param }, session: valid_session
        expect(assigns(:league)).to eq(league)
      end
    end

    describe 'GET #new' do
      it 'assigns a new league as @league' do
        get :new, params: {}, session: valid_session
        expect(assigns(:league)).to be_a_new(PublicLeague)
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested league as @league' do
        get :edit, params: { id: league.to_param }, session: valid_session
        expect(assigns(:league)).to eq(league)
      end
    end

    describe 'POST #create' do
      context 'with valid params' do
        it 'creates a new League' do
          expect do
            post :create, params: { public_league: valid_attributes }, session: valid_session
          end.to change(PublicLeague, :count).by(1)
        end

        it 'assigns a newly created league as @league' do
          post :create, params: { public_league: valid_attributes }, session: valid_session
          expect(assigns(:league)).to be_a(PublicLeague)
          expect(assigns(:league)).to be_persisted
        end

        it 'redirects to the created league' do
          post :create, params: { public_league: valid_attributes }, session: valid_session
          expect(response).to redirect_to(PublicLeague.last)
        end
      end

      context 'with invalid params' do
        it 'assigns a newly created but unsaved league as @league' do
          post :create, params: { public_league: invalid_attributes }, session: valid_session
          expect(assigns(:league)).to be_a_new(PublicLeague)
        end

        it "re-renders the 'new' template" do
          post :create, params: { public_league: invalid_attributes }, session: valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT #update' do
      context 'with valid params' do
        let(:new_attributes) do
          skip('Add a hash of attributes valid for your model')
        end

        it 'updates the requested league' do
          put :update, params: { id: league.to_param, public_league: new_attributes }, session: valid_session
          league.reload
          skip('Add assertions for updated state')
        end

        it 'assigns the requested league as @league' do
          put :update, params: { id: league.to_param, public_league: valid_attributes }, session: valid_session
          expect(assigns(:league)).to eq(league)
        end

        it 'redirects to the league' do
          put :update, params: { id: league.to_param, public_league: valid_attributes }, session: valid_session
          expect(response).to redirect_to(league)
        end
      end

      context 'with invalid params' do
        it 'assigns the league as @league' do
          put :update, params: { id: league.to_param, public_league: invalid_attributes }, session: valid_session
          expect(assigns(:league)).to eq(league)
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: league.to_param, public_league: invalid_attributes }, session: valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested league' do
        league
        expect do
          delete :destroy, params: { id: league.to_param }, session: valid_session
        end.to change(League, :count).by(-1)
      end

      it 'redirects to the leagues list' do
        delete :destroy, params: { id: league.to_param }, session: valid_session
        expect(response).to redirect_to(leagues_url)
      end
    end
  end
end
