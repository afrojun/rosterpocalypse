FactoryBot.define do
  factory :match do
    team_1 { create :team }
    team_2 { create :team }
    gameweek { create :gameweek, start_date: '2017-01-17 02:45:11', end_date: '2017-01-19 02:45:11' }
    stage
    best_of { 1 }
    start_date { '2017-01-18 02:45:11' }
  end
end
