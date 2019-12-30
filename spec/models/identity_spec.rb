require 'rails_helper'
require 'ostruct'

shared_examples_for 'an Identity' do
  describe '<<' do
    it 'builds a new Identity' do
      response = Identity.find_or_initialize_for_oauth auth
      expect(response.class).to eq(Identity)
      expect(response).not_to be_persisted
    end

    it 'finds an existing Identity' do
      expect(Identity.count).to eq 0
      new_id = Identity.find_or_initialize_for_oauth auth
      user = create :user
      new_id.update(user: user)
      expect(Identity.count).to eq 1

      prev_id = Identity.find_or_initialize_for_oauth auth
      expect(Identity.count).to eq 1
      expect(prev_id).to eq new_id
    end

    it 'sets nickname correctly' do
      expect(Identity.find_or_initialize_for_oauth(auth).nickname).to eq expected_nickname
    end
  end
end

RSpec.describe Identity, type: :model do
  context '#find_or_initialize_for_oauth' do
    context 'reddit' do
      let(:auth) do
        OpenStruct.new(
          provider: 'reddit',
          uid: '123fgh',
          info: OpenStruct.new(name: 'rosterpocalypse'),
          credentials: OpenStruct.new(expires: true, expires_at: 1_484_498_817, token: 'T__8aisys_8AdnSias7_lo')
        )
      end
      let(:expected_nickname) { 'rosterpocalypse' }

      it_behaves_like 'an Identity'
    end

    context 'facebook' do
      let(:auth) do
        OpenStruct.new(
          provider: 'facebook',
          uid: '1231245',
          info: OpenStruct.new(
            name: 'Rosterpocalypse',
            email: 'rosterpocalypse@fb.com',
            image: 'http://graph.facebook.com/v2.6/90876/picture'
          ),
          credentials: OpenStruct.new(expires: true, expires_at: 1_484_498_817, token: 'XnrZCBJEmb78ZChTO4u60QxDQbi4CgGMB')
        )
      end
      let(:expected_nickname) { 'rosterpocalypse' }

      it_behaves_like 'an Identity'
    end

    context 'google' do
      let(:auth) do
        OpenStruct.new(
          provider: 'google_oauth2',
          uid: '11137893404',
          info: OpenStruct.new(
            email: 'rosterpocalypse@google.com',
            first_name: 'Rosterpocalypse',
            last_name: 'Esports',
            image: 'https://lh5.googleusercontent.com/-OIUYTE-6I//photo.jpg',
            name: 'Rosterpocalypse Esports',
            urls: OpenStruct.new(Google: 'https://plus.google.com/9876352')
          ),
          credentials: OpenStruct.new(expires: true, expires_at: 1_489_641_616, refresh_token: '1/NH7GFD489', token: 'ya29.98q7UI')
        )
      end
      let(:expected_nickname) { 'rosterpocalypse' }

      it_behaves_like 'an Identity'
    end

    context 'twitter' do
      let(:auth) do
        OpenStruct.new(
          provider: 'twitter',
          uid: '182923769823',
          info: OpenStruct.new(
            name: 'Rosterpocalypse',
            description: '',
            email: 'rosterpocalypse@foobar.com',
            image: 'http://abs.twimg.com/idsneuybdf.png',
            location: '',
            nickname: 'rosterpocalypse',
            urls: OpenStruct.new(Twitter: '', Website: '')
          ),
          credentials: OpenStruct.new(secret: 'JBEUI8rsuyahdf87ehUId', token: '98749er4058-siufh89dhfe8H')
        )
      end
      let(:expected_nickname) { 'rosterpocalypse' }

      it_behaves_like 'an Identity'
    end

    context 'bnet' do
      let(:auth) do
        OpenStruct.new(
          provider: 'bnet',
          uid: '12546374',
          info: OpenStruct.new(id: '12546374', battletag: 'Rosterpocalypse#12345'),
          credentials: OpenStruct.new(expires: true, expires_at: 1_487_073_964, token: 'sdjsid8s9dhuysd')
        )
      end
      let(:expected_nickname) { 'Rosterpocalypse.12345' }

      it_behaves_like 'an Identity'
    end
  end
end
