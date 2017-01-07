FactoryGirl.define do
  sequence(:tournament_name) { |n| "Tournament#{n}" }

  factory :tournament do
    name { generate :tournament_name }
    region { Tournament::REGIONS.sample }
    cycle_hours 24
    start_date "2016-12-15 00:00:00"
    end_date "2016-12-30 23:59:59"
    slug "mystring"
  end
end
