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

RSpec.describe HeroesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Hero. As you add validations to Hero, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      name: "SuperHero",
      internal_name: "SuperHero",
      classification: "Warrior"
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      internal_name: nil,
      classification: nil
    }
  end

  let(:new_attributes) do
    {
      name: "EvilHero",
      internal_name: "EvilHero",
      classification: "Assassin"
    }
  end

  def assert_update_successful hero
    expect(hero.name).to eq "EvilHero"
    expect(hero.internal_name).to eq "EvilHero"
    expect(hero.classification).to eq "Assassin"
  end

  context "a normal user" do
    it_should_behave_like "a normal user", Hero, :hero
  end

  context "an admin user" do
    it_should_behave_like "an admin user", Hero, :hero
  end
end
