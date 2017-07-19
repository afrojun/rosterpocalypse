FactoryGirl.define do
  sequence(:gameweek_name) { |n| "Gameweek #{n}" }

  factory :gameweek do
    name { generate :gameweek_name }
    tournament
    start_date '2017-01-02 00:00:00'
    end_date '2017-01-08 23:59:59'
  end
end
