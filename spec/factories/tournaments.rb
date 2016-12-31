FactoryGirl.define do
  factory :tournament do
    name "MyString"
    region { Tournament::REGIONS.sample }
    cycle_hours 1
    start_date "2016-12-30 14:32:41"
    end_date "2016-12-30 14:32:41"
    slug "mystring"
  end
end
