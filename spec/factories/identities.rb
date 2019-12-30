FactoryBot.define do
  factory :identity do
    user
    provider { 'facebook' }
    accesstoken { 'MyString' }
    refreshtoken { 'MyString' }
    uid { 'MyString' }
    name { 'User Name' }
    email { 'user@mail.com' }
    nickname { 'username' }
    image { 'image_url' }
    phone { '1234456' }
    urls { '' }
  end
end
