FactoryGirl.define do
  sequence(:email) { |n| "account#{n}@email.com" }
  sequence(:username) { |n| "User#{n}" }

  factory :user do
    email { generate :email }
    username { generate :username }
    password 'password'
    password_confirmation 'password'
  end

  factory :form_user do
    email { generate :email }
    username { generate :username }
    password 'password'
    password_confirmation 'password'
  end
end
