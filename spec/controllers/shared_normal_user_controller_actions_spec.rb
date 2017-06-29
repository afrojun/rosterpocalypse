require 'rails_helper'

shared_examples_for "a normal user" do |model_class, model_symbol|
  describe "<<" do
    login_user

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # GamesController. Be sure to keep this updated too.
    let(:valid_session) { {} }

    def check_access_denied
      expect(response).to redirect_to root_path
      expect(flash[:alert]).to eq "You don't have permission to take this action."
    end

    describe "GET #index" do
      it "assigns all #{model_symbol.to_s.pluralize} as @#{model_symbol.to_s.pluralize}" do
        get :index, params: {}, session: valid_session
        check_access_denied
      end
    end

    describe "GET #show" do
      it "assigns the requested #{model_symbol} as @#{model_symbol}" do
        model = model_class.create! valid_attributes
        get :show, params: {id: model.to_param}, session: valid_session
        check_access_denied
      end
    end

    describe "GET #new" do
      it "denies access" do
        get :new, params: {}, session: valid_session
        check_access_denied
      end
    end

    describe "GET #edit" do
      it "denies access" do
        model = model_class.create! valid_attributes
        get :edit, params: {id: model.to_param}, session: valid_session
        check_access_denied
      end
    end

    describe "POST #create" do
      it "denies access" do
        post :create, params: {model_symbol => valid_attributes}, session: valid_session
        check_access_denied
      end
    end

    describe "PUT #update" do
      it "denies access" do
        model = model_class.create! valid_attributes
        put :update, params: {id: model.to_param, model_symbol => valid_attributes}, session: valid_session
        check_access_denied
      end
    end

    describe "DELETE #destroy" do
      it "denies access" do
        model = model_class.create! valid_attributes
        delete :destroy, params: {id: model.to_param}, session: valid_session
        check_access_denied
      end
    end

  end
end