require 'rails_helper'

RSpec.describe Tournament, type: :model do
  let(:date) { "2017-01-05" }
  let(:region) { "EU" }
  let(:tournament) { FactoryGirl.create :tournament, region: region, start_date: start_date, end_date: end_date }

  shared_examples_for "a tournament" do
    describe "<<" do
      context "#create_gameweeks" do
        it "creates a pre-gameweek and one gameweek for every week of the tournament" do
          expect(tournament.gameweeks.map(&:name)).to eq ["Gameweek 0", "Gameweek 1"]
          expect(tournament.gameweeks.map(&:start_date)).to eq [start_date.beginning_of_week.advance(weeks: -1) + 12.hours, start_date.beginning_of_week + 12.hours]
        end

        it "has no roster_lock_date for the first gameweek" do
          expect(tournament.gameweeks.first.roster_lock_date).to eq nil
        end
      end

      context "#current_gameweek" do
        let(:date) { Time.now.strftime "%Y-%m-%d" }
        it "returns the current gameweek" do
          expect(tournament.current_gameweek).to eq tournament.gameweeks.last
        end
      end

      context "sets the roster lock time for regions" do
        context "CN" do
          let(:region) { "CN" }
          it "Asia/Shanghai timezone" do
            expect(tournament.gameweeks.last.roster_lock_date).to eq Time.parse("2017-01-06 04:00:00 UTC")
          end
        end

        context "EU" do
          let(:region) { "EU" }
          it "UTC" do
            expect(tournament.gameweeks.last.roster_lock_date).to eq Time.parse("2017-01-06 12:00:00 UTC")
          end
        end

        context "KR" do
          let(:region) { "KR" }
          it "Asia/Seoul timezone" do
            expect(tournament.gameweeks.last.roster_lock_date).to eq Time.parse("2017-01-06 03:00:00 UTC")
          end
        end

        context "NA" do
          let(:region) { "NA" }
          it "America/Los_Angeles timezone" do
            expect(tournament.gameweeks.last.roster_lock_date).to eq Time.parse("2017-01-06 20:00:00 UTC")
          end
        end

        context "Global" do
          let(:region) { "Global" }
          it "UTC" do
            expect(tournament.gameweeks.last.roster_lock_date).to eq Time.parse("2017-01-06 12:00:00 UTC")
          end
        end
      end

    end
  end

  context "start_date is at the beginning of the week" do
    let(:start_date) { Time.parse(date).utc.beginning_of_week }
    let(:end_date) { Time.parse(date).utc.end_of_week }

    it_should_behave_like "a tournament"
  end

  context "start_date is in the middle of the week" do
    let(:start_date) { Time.parse(date).utc }
    let(:end_date) { Time.parse(date).utc.end_of_week }

    it_should_behave_like "a tournament"
  end

  context "start_date is at the end of the week" do
    let(:start_date) { Time.parse(date).utc.end_of_week - 1.hour }
    let(:end_date) { Time.parse(date).utc.end_of_week }

    it_should_behave_like "a tournament"
  end

end
