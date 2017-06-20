require 'rails_helper'

RSpec.describe PrivateLeaguesController, type: :controller do
  login_user

  # This should return the minimal set of attributes required to create a valid
  # League. As you add validations to League, be sure to
  # adjust the attributes here as well.
  let(:now) { Time.now.utc }
  let(:tournament) { FactoryGirl.create :tournament, start_date:  now - 1.day, end_date: now + 1.day }
  let(:manager) { FactoryGirl.create :manager, user: subject.current_user }
  let(:league) { FactoryGirl.create :private_league, valid_attributes.merge(manager: manager) }

  let(:valid_attributes) {
    {
      name: "Big League",
      tournament_id: tournament.id,
      role_stat_modifiers: League::DEFAULT_ROLE_STAT_MODIFIERS,
      required_player_roles: League::DEFAULT_REQUIRED_PLAYER_ROLES
    }
  }

  let(:invalid_attributes) {
    {
      name: "a",
      tournament_id: tournament.id
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LeaguesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all private leagues as @private_leagues" do
      league
      get :index, params: {}, session: valid_session
      expect(assigns(:private_leagues)).to eq([league])
    end
  end

  describe "GET #show" do
    it "assigns the requested league as @league" do
      get :show, params: {id: league.to_param}, session: valid_session
      expect(assigns(:league)).to eq(league)
    end
  end

  describe "GET #new" do
    it "assigns a new league as @league" do
      get :new, params: {}, session: valid_session
      expect(assigns(:league)).to be_a_new(PrivateLeague)
    end
  end

  describe "GET #edit" do
    it "assigns the requested league as @league" do
      get :edit, params: {id: league.to_param}, session: valid_session
      expect(assigns(:league)).to eq(league)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new League" do
        expect {
          post :create, params: {private_league: valid_attributes}, session: valid_session
        }.to change(PrivateLeague, :count).by(1)
      end

      it "assigns a newly created league as @league" do
        post :create, params: {private_league: valid_attributes}, session: valid_session
        expect(assigns(:league)).to be_a(PrivateLeague)
        expect(assigns(:league)).to be_persisted
      end

      it "redirects to the created league" do
        post :create, params: {private_league: valid_attributes}, session: valid_session
        expect(response).to redirect_to(PrivateLeague.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved league as @league" do
        post :create, params: {private_league: invalid_attributes}, session: valid_session
        expect(assigns(:league)).to be_a_new(PrivateLeague)
      end

      it "re-renders the 'new' template" do
        post :create, params: {private_league: invalid_attributes}, session: valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested league" do
        put :update, params: {id: league.to_param, private_league: new_attributes}, session: valid_session
        league.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested league as @league" do
        put :update, params: {id: league.to_param, private_league: valid_attributes}, session: valid_session
        expect(assigns(:league)).to eq(league)
      end

      it "redirects to the league" do
        put :update, params: {id: league.to_param, private_league: valid_attributes}, session: valid_session
        expect(response).to redirect_to(league)
      end
    end

    context "with invalid params" do
      it "assigns the league as @league" do
        put :update, params: {id: league.to_param, private_league: invalid_attributes}, session: valid_session
        expect(assigns(:league)).to eq(league)
      end

      it "re-renders the 'edit' template" do
        put :update, params: {id: league.to_param, private_league: invalid_attributes}, session: valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested league" do
      league
      expect {
        delete :destroy, params: {id: league.to_param}, session: valid_session
      }.to change(League, :count).by(-1)
    end

    it "redirects to the leagues list" do
      delete :destroy, params: {id: league.to_param}, session: valid_session
      expect(response).to redirect_to(leagues_url)
    end
  end

end
