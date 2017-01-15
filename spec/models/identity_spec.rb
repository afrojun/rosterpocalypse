require "rails_helper"
require "ostruct"

shared_examples_for "an Identity" do
  describe "<<" do
    it "creates a new Identity" do
      response = Identity.find_for_oauth auth
      expect(response.class).to eq(Identity)
    end

    it "finds an existing Identity" do
      response = Identity.find_for_oauth auth
    end

    it "sets nickname correctly" do
      expect(Identity.find_for_oauth(auth).nickname).to eq expected_nickname
    end
  end
end

RSpec.describe Identity, type: :model do
  context "#find_for_oauth" do
    context "reddit" do
      let(:auth) {
        OpenStruct.new(
          provider: "reddit",
          uid: "123fgh",
          info: OpenStruct.new(name: "rosterpocalypse"),
          credentials: OpenStruct.new(expires: true, expires_at: 1484498817, token: "T__8aisys_8AdnSias7_lo")
        )
      }
      let(:expected_nickname) { "rosterpocalypse" }

      it_behaves_like "an Identity"
    end

    context "facebook" do
      let(:auth) {
        OpenStruct.new(
          provider: "facebook",
          uid: "1231245",
          info: OpenStruct.new(
            name: "Rosterpocalypse",
            email: "rosterpocalypse@fb.com",
            image: "http://graph.facebook.com/v2.6/90876/picture"
          ),
          credentials: OpenStruct.new(expires: true, expires_at: 1484498817, token: "XnrZCBJEmb78ZChTO4u60QxDQbi4CgGMB")
        )
      }
      let(:expected_nickname) { "Rosterpocalypse" }

      it_behaves_like "an Identity"
    end

    context "google" do
      let(:auth) {
        OpenStruct.new(
          provider: "google_oauth2",
          uid: "11137893404",
          info: OpenStruct.new(
            email: "rosterpocalypse@google.com",
            first_name: "Rosterpocalypse",
            last_name: "Esports",
            image: "https://lh5.googleusercontent.com/-OIUYTE-6I//photo.jpg",
            name: "Rosterpocalypse Esports",
            urls: OpenStruct.new(Google: "https://plus.google.com/9876352")
          ),
          credentials: OpenStruct.new(expires: true, expires_at: 1489641616, refresh_token: "1/NH7GFD489", token: "ya29.98q7UI")
        )
      }
      let(:expected_nickname) { "Rosterpocalypse" }

      it_behaves_like "an Identity"
    end

    context "twitter" do
      let(:auth) {
        OpenStruct.new(
          provider: "twitter",
          uid: "182923769823",
          info: OpenStruct.new(
            name: "Rosterpocalypse",
            description: "",
            email: "rosterpocalypse@foobar.com",
            image: "http://abs.twimg.com/idsneuybdf.png",
            location: "",
            nickname: "rosterpocalypse",
            urls: OpenStruct.new(Twitter: "", Website: "")),
          credentials: OpenStruct.new(secret: "JBEUI8rsuyahdf87ehUId", token: "98749er4058-siufh89dhfe8H")
        )
      }
      let(:expected_nickname) { "rosterpocalypse" }

      it_behaves_like "an Identity"
    end

    context "bnet" do
      let(:auth) {
        OpenStruct.new(
          provider: "bnet",
          uid: "12546374",
          info: OpenStruct.new(id: "12546374", battletag: "Rosterpocalypse#12345"),
          credentials: OpenStruct.new(expires: true, expires_at: 1487073964, token: "sdjsid8s9dhuysd")
        )
      }
      let(:expected_nickname) { "Rosterpocalypse.12345" }

      it_behaves_like "an Identity"
    end
  end
end
