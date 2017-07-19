require 'rails_helper'

shared_examples_for "an admin user" do |model_class, model_symbol|
  describe "<<" do
    login_admin

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # GamesController. Be sure to keep this updated too.
    let(:valid_session) { {} }

    describe "GET #index" do
      it "assigns all #{model_symbol.to_s.pluralize} as @#{model_symbol.to_s.pluralize}" do
        model = model_class.create! valid_attributes
        get :index, params: {}, session: valid_session
        expect(assigns(model_symbol.to_s.pluralize.to_sym)).to eq([model])
      end
    end

    describe "GET #show" do
      it "assigns the requested #{model_symbol} as @#{model_symbol}" do
        model = model_class.create! valid_attributes
        get :show, params: { id: model.to_param }, session: valid_session
        expect(assigns(model_symbol)).to eq(model)
      end
    end

    describe "GET #new" do
      it "assigns a new #{model_symbol} as @#{model_symbol}" do
        get :new, params: {}, session: valid_session
        expect(assigns(model_symbol)).to be_a_new(model_class)
      end
    end

    describe "GET #edit" do
      it "assigns the requested #{model_symbol} as @#{model_symbol}" do
        model = model_class.create! valid_attributes
        get :edit, params: { id: model.to_param }, session: valid_session
        expect(assigns(model_symbol)).to eq(model)
      end
    end

    describe "POST #create" do
      context "with valid params" do
        it "creates a new #{model_class}" do
          expect do
            post :create, params: { model_symbol => valid_attributes }, session: valid_session
          end.to change(model_class, :count).by(1)
        end

        it "assigns a newly created #{model_symbol} as @#{model_symbol}" do
          post :create, params: { model_symbol => valid_attributes }, session: valid_session
          expect(assigns(model_symbol)).to be_a(model_class)
          expect(assigns(model_symbol)).to be_persisted
        end

        it "redirects to the created #{model_symbol}" do
          post :create, params: { model_symbol => valid_attributes }, session: valid_session
          expect(response).to redirect_to(model_class.last)
        end
      end

      context "with invalid params" do
        it "assigns a newly created but unsaved #{model_symbol} as @#{model_symbol}" do
          post :create, params: { model_symbol => invalid_attributes }, session: valid_session
          expect(assigns(model_symbol)).to be_a_new(model_class)
        end

        it "re-renders the 'new' template" do
          post :create, params: { model_symbol => invalid_attributes }, session: valid_session
          expect(response).to render_template("new")
        end
      end
    end

    describe "PUT #update" do
      context "with valid params" do
        it "updates the requested #{model_symbol}" do
          model = model_class.create! valid_attributes
          put :update, params: { id: model.to_param, model_symbol => new_attributes }, session: valid_session
          model.reload
          assert_update_successful model
        end

        it "assigns the requested #{model_symbol} as @#{model_symbol}" do
          model = model_class.create! valid_attributes
          put :update, params: { id: model.to_param, model_symbol => valid_attributes }, session: valid_session
          expect(assigns(model_symbol)).to eq(model)
        end

        it "redirects to the #{model_symbol}" do
          model = model_class.create! valid_attributes
          put :update, params: { id: model.to_param, model_symbol => valid_attributes }, session: valid_session
          expect(response).to redirect_to(model)
        end
      end

      context "with invalid params" do
        it "assigns the #{model_symbol} as @#{model_symbol}" do
          model = model_class.create! valid_attributes
          put :update, params: { id: model.to_param, model_symbol => invalid_attributes }, session: valid_session
          expect(assigns(model_symbol)).to eq(model)
        end

        it "re-renders the 'edit' template" do
          model = model_class.create! valid_attributes
          put :update, params: { id: model.to_param, model_symbol => invalid_attributes }, session: valid_session
          expect(response).to render_template("edit")
        end
      end
    end

    describe "DELETE #destroy" do
      it "destroys the requested #{model_symbol}" do
        model = model_class.create! valid_attributes
        expect do
          delete :destroy, params: { id: model.to_param }, session: valid_session
        end.to change(model_class, :count).by(-1)
      end

      it "redirects to the #{model_symbol.to_s.pluralize} list" do
        model = model_class.create! valid_attributes
        delete :destroy, params: { id: model.to_param }, session: valid_session
        expect(response).to redirect_to(send("#{model_symbol.to_s.pluralize}_url".to_sym))
      end
    end
  end
end
