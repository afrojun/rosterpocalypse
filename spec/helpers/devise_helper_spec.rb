require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelper. For example:
#
# describe ApplicationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe DeviseHelper, type: :helper do
  context '#identity_provider_logos' do
    let(:fb_identity) { FactoryBot.create :identity }
    let(:reddit_identity) { FactoryBot.create :identity, provider: 'reddit' }

    it 'generates the HTML for displaying the identity logo' do
      user = FactoryBot.create :user, identities: [fb_identity]
      expect(helper.identity_provider_logos(user)).to eq(
        '<i class="identity-provider-logo fa fa-2x fa-facebook facebook-blue" title="Facebook"></i>'
      )
    end

    it 'generates the HTML for displaying multiple identity logos' do
      user = FactoryBot.create :user, identities: [fb_identity, reddit_identity]
      expect(helper.identity_provider_logos(user)).to eq(
        '<i class="identity-provider-logo fa fa-2x fa-facebook facebook-blue" title="Facebook"></i> <i class="identity-provider-logo fa fa-2x fa-reddit-alien reddit-red" title="Reddit"></i>'
      )
    end
  end
end
