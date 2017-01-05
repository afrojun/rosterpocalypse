FactoryGirl.define do
  sequence(:tournament_name) { |n| "Tournament#{n}" }

  factory :tournament do
    name { generate :tournament_name }
    region { Tournament::REGIONS.sample }
    cycle_hours 1
    start_date "2016-12-30 14:32:41"
    end_date "2016-12-30 14:32:41"
    slug "mystring"
  end
end
