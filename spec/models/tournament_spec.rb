require 'rails_helper'

RSpec.describe Tournament, type: :model do
  let(:date) { "2017-01-05" }
  let(:region) { "EU" }
  let(:tournament) { FactoryGirl.create :tournament, region: region, start_date: start_date, end_date: end_date }

  shared_examples_for "a tournament" do
    describe "<<" do
      context "#create_gameweeks" do
        it "creates one gameweek for every week of the tournament" do
          expect(tournament.gameweeks.map(&:name)).to eq ["Gameweek 1", "Gameweek 2"]
          expect(tournament.gameweeks.map(&:start_date)).to eq [start_date.beginning_of_week + 12.hours, start_date.beginning_of_week.advance(weeks: 1) + 12.hours]
        end
      end

      context "#current_gameweek" do
        it "returns the current gameweek" do
          allow(Time).to receive(:now).and_return(Time.parse(date))
          expect(tournament.current_gameweek).to eq tournament.gameweeks.first
        end
      end

      context "sets the roster lock time for regions" do
        context "CN" do
          let(:region) { "CN" }
          it "Asia/Shanghai timezone" do
            expect(tournament.gameweeks.first.roster_lock_date).to eq Time.parse("2017-01-06 04:00:00 UTC")
          end
        end

        context "EU" do
          let(:region) { "EU" }
          it "UTC" do
            expect(tournament.gameweeks.first.roster_lock_date).to eq Time.parse("2017-01-06 12:00:00 UTC")
          end
        end

        context "KR" do
          let(:region) { "KR" }
          it "Asia/Seoul timezone" do
            expect(tournament.gameweeks.first.roster_lock_date).to eq Time.parse("2017-01-06 03:00:00 UTC")
          end
        end

        context "NA" do
          let(:region) { "NA" }
          it "America/Los_Angeles timezone" do
            expect(tournament.gameweeks.first.roster_lock_date).to eq Time.parse("2017-01-06 20:00:00 UTC")
          end
        end

        context "Global" do
          let(:region) { "Global" }
          it "UTC" do
            expect(tournament.gameweeks.first.roster_lock_date).to eq Time.parse("2017-01-06 12:00:00 UTC")
          end
        end
      end

      context "change start_date and/or end_date" do
        context "should add new gameweeks" do
          it "adds new gameweeks before the first one when the start_date is made earlier" do
            expect(tournament.gameweeks.count).to eq 2
            new_start_date = tournament.start_date - 2.weeks
            tournament.update_attribute(:start_date, new_start_date)
            expect(tournament.gameweeks.count).to eq 4
            expect(tournament.gameweeks.map(&:name)).to eq ["Gameweek 1", "Gameweek 2", "Gameweek 3", "Gameweek 4"]
            expect(tournament.gameweeks.first.start_date). to eq(new_start_date.beginning_of_week + 12.hours)
          end

          it "adds new gameweeks after the last one when the end_date is made later" do
            expect(tournament.gameweeks.count).to eq 2
            new_end_date = tournament.end_date + 2.weeks
            tournament.update_attribute(:end_date, new_end_date)
            expect(tournament.gameweeks.count).to eq 4
            expect(tournament.gameweeks.map(&:name)).to eq ["Gameweek 1", "Gameweek 2", "Gameweek 3", "Gameweek 4"]
            expect(tournament.gameweeks.last.end_date.to_i). to eq((new_end_date.end_of_week  + 12.hours).to_i)
          end

          it "adds new gameweeks when both start and end dates are moved" do
            expect(tournament.gameweeks.count).to eq 2
            new_start_date = tournament.start_date - 2.weeks
            new_end_date = tournament.end_date + 2.weeks
            tournament.update_attributes(start_date: new_start_date, end_date: new_end_date)
            expect(tournament.gameweeks.count).to eq 6
            expect(tournament.gameweeks.map(&:name)).to eq ["Gameweek 1", "Gameweek 2", "Gameweek 3", "Gameweek 4", "Gameweek 5", "Gameweek 6"]
            expect(tournament.gameweeks.first.start_date). to eq(new_start_date.beginning_of_week + 12.hours)
            expect(tournament.gameweeks.last.end_date.to_i). to eq((new_end_date.end_of_week  + 12.hours).to_i)
          end

          it "does not add new gameweeks when the new date is covered by an existing gameweek" do
            expect(tournament.gameweeks.count).to eq 2
            new_start_date = tournament.start_date + 10.minutes
            tournament.update_attribute(:start_date, new_start_date)
            expect(tournament.gameweeks.count).to eq 2
          end
        end

        context "should remove gameweeks" do
          it "removes gameweeks when the tournament has moved away from its date range" do
            expect(tournament.gameweeks.count).to eq 2
            new_start_date = tournament.start_date + 1.week + 12.hours
            tournament.update_attribute(:start_date, new_start_date)
            expect(tournament.gameweeks.count).to eq 1
          end

          it "does not remove gameweeks which have associated resources" do
            expect(tournament.gameweeks.count).to eq 2
            FactoryGirl.create :game, gameweek: tournament.gameweeks.first
            new_start_date = tournament.start_date + 1.week + 12.hours
            tournament.update_attribute(:start_date, new_start_date)
            expect(tournament.gameweeks.count).to eq 2
          end
        end
      end

    end
  end

  context "start_date is at the beginning of the week" do
    let(:start_date) { Time.parse(date).utc.beginning_of_week }
    let(:end_date) { Time.parse(date).utc.end_of_week.advance(weeks: 1) }

    it_should_behave_like "a tournament"
  end

  context "start_date is in the middle of the week" do
    let(:start_date) { Time.parse(date).utc }
    let(:end_date) { Time.parse(date).utc.end_of_week.advance(weeks: 1) }

    it_should_behave_like "a tournament"
  end

  context "start_date is at the end of the week" do
    let(:start_date) { Time.parse(date).utc.end_of_week - 1.hour }
    let(:end_date) { Time.parse(date).utc.end_of_week.advance(weeks: 1) }

    it_should_behave_like "a tournament"
  end

end
