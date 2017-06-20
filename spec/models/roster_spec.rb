require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:region) { "EU" }
  let(:start_date) { Time.parse("2017-01-20") }
  let(:end_date) { Time.parse("2017-02-20") }
  let(:tournament) { FactoryGirl.create :tournament, region: region, start_date: start_date, end_date: end_date }
  let(:manager) { FactoryGirl.create :manager }
  let(:league) { FactoryGirl.create :public_league, tournament: tournament }
  let(:roster) { FactoryGirl.create :roster, tournament: tournament, manager: manager }

  before :each do
    allow(Time).to receive(:now).and_return(Time.parse "2017-02-01")
  end

  context "#create" do
    it "creates rosters with a valid region" do
      expect(roster).to be_persisted
    end

    it "creates gameweek_rosters for all gameweeks in the tournament" do
      expect(roster.gameweek_rosters.count).to eq 6
    end
  end

  context "validations" do
    context "region must be one of the pre-defined regions" do
      it "fails to create rosters with an invalid region" do
        expect { FactoryGirl.create :roster, tournament: nil }.to raise_error ActiveRecord::StatementInvalid
      end
    end

    context "#validate_one_roster_per_league" do
      it "fails to join a league when another exists for that league" do
        roster.add_to league
        expect(league.rosters).to include(roster)
        manager.rosters = [roster]
        another_roster = FactoryGirl.create :roster, tournament: tournament, manager: manager
        another_roster.add_to league
        expect(league.rosters).not_to include(another_roster)
      end
    end

  end

  context "#available_transfers" do
    it "returns the number of available transfers from one league" do
      roster.add_to league
      expect(roster.available_transfers).to eq 1
    end

    it "returns the max number of available transfers across multiple leagues" do
      league2 = FactoryGirl.create :private_league, tournament: tournament

      roster.add_to league
      roster.add_to league2
      roster.current_gameweek_roster.update_attribute :available_transfers, 5
      expect(roster.available_transfers).to eq 5
    end

    it "deducts completed transfers from the original number" do
      roster.add_to league
      expect(roster.available_transfers).to eq 1
      FactoryGirl.create :transfer, gameweek_roster: roster.current_gameweek_roster
      expect(roster.available_transfers).to eq 0
    end
  end

  context "#update_including_players" do
    let(:active_team) { FactoryGirl.create :team, active: true }
    let(:inactive_team) { FactoryGirl.create :team, active: false }
    let(:player1) { FactoryGirl.create :player, team: active_team }
    let(:player2) { FactoryGirl.create :player, team: active_team }
    let(:player3) { FactoryGirl.create :player, team: active_team }
    let(:sub_player) { FactoryGirl.create :player, team: active_team }

    let(:support_player) { FactoryGirl.create :player, role: "Support", team: active_team }
    let(:warrior_player) { FactoryGirl.create :player, role: "Warrior", team: active_team }
    let(:expensive_player) { FactoryGirl.create :player, value: Player::MAX_VALUE, team: active_team }
    let(:cheap_player) { FactoryGirl.create :player, value: Player::MIN_VALUE, team: active_team }
    let(:inactive_player) { FactoryGirl.create :player, team: inactive_team }

    let(:players) { [player1, player2, player3] }
    let(:player_ids) { players.map(&:id) }

    context "roster name" do
      it "updates the name" do
        expect(roster.update_including_players(name: "foo-roster")).to eq true
        roster.reload
        expect(roster.name).to eq "foo-roster"
      end

      it "rejects invalid updates" do
        expect(roster.update_including_players(name: nil)).to eq false
      end
    end

    context "updating players in roster" do
      context "without associated league" do
        it "updates the associated players" do
          players.push(warrior_player, support_player)
          expect(roster.update_including_players(players: player_ids)).to eq true
          expect(roster.players).to contain_exactly *players
        end

        it "overwrites existing associated players" do
          players.push(warrior_player, support_player)
          expect(roster.update_including_players(players: player_ids)).to eq true
          expect(roster.players).to contain_exactly *players

          players.shift
          players << cheap_player
          players.each do |player|
            FactoryGirl.create :gameweek_player, gameweek: roster.current_gameweek, player: player
          end
          expect(roster.update_including_players(players: players.map(&:id))).to eq true
          expect(roster.players).to include cheap_player
        end
      end

      context "with associated league" do
        before :each do
          roster.add_to league
        end

        it "allows free updates to empty rosters" do
          players.push(warrior_player, support_player)
          expect(roster.update_including_players(players: player_ids)).to eq true
          expect(roster.players).to contain_exactly *players
        end

        it "restricts updates once the roster has been created" do
          players.push(warrior_player, support_player)
          roster.update_including_players(players: player_ids)
          original_players = players.dup

          players.shift(2)
          players.push sub_player, cheap_player
          new_player_ids = players.map(&:id)
          expect(roster.update_including_players(players: new_player_ids)).to be false
          expect(roster.players).to contain_exactly *original_players
          expect(roster.errors.messages).to include(roster: ["has 1 transfer available in this window"])
        end



        context "#validate_player_roles" do
          it "requires at least 1 support player and 1 warrior player" do
            players.push sub_player, cheap_player
            expect(roster.update_including_players(players: player_ids)).to eq false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["needs 1 warrior player", "needs 1 support player"])
          end

          it "requires at least 1 support player" do
            players.push sub_player, warrior_player
            expect(roster.update_including_players(players: player_ids)).to eq false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["needs 1 support player"])
          end

          it "requires at least 1 warrior player" do
            players.delete_at(3)
            players.push sub_player, support_player
            expect(roster.update_including_players(players: player_ids)).to eq false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["needs 1 warrior player"])
          end
        end

        context "#validate_roster_size" do
          it "rejects updates with more than 5 players" do
            players.push cheap_player, sub_player, warrior_player
            expect(roster.update_including_players(players: player_ids)).to be false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["must contain 5 players"])
          end

          it "rejects updates with less than 5 players" do
            expect(roster.update_including_players(players: player_ids)).to be false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["must contain 5 players"])
          end

          it "treats non-existent players as missing" do
            player1 = FactoryGirl.create :player
            player_ids << 9999 << 10001
            expect(roster.update_including_players(players: player_ids)).to eq false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["must contain 5 players"])
          end
        end

        context "#validate_player_value" do
          it "rejects updates with players with a value of more than 500 in total" do
            players.shift
            players.push support_player, warrior_player, expensive_player
            expect(roster.update_including_players(players: player_ids)).to be false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["may have a maximum total player value of 500.0"])
          end
        end

        context "#validate_teams_active" do
          it "rejects updates that include players on inactive teams" do
            players.shift
            players.push support_player, warrior_player, inactive_player
            expect(roster.update_including_players(players: player_ids)).to be false
            expect(roster.players).to eq []
            expect(roster.errors.messages).to include(roster: ["may not include players from inactive teams"])
          end
        end

        context "#validate_transfers_count" do
          it "validates that the number of players being added and removed are the same" do
            expect(roster).to receive(:allow_free_transfers?).twice.and_return(false)
            players.push support_player, warrior_player
            expect(roster.update_including_players(players: players.map(&:id))).to be false
            expect(roster.players).to eq []
            expect(roster.errors.messages[:roster].first).to include("transfers must maintain the roster size")
          end

          it "rejects updates that make more than the allowed number of transfers" do
            players.push(warrior_player, support_player)
            roster.update_including_players(players: player_ids)
            original_players = players.dup

            expect(roster).to receive(:allow_free_transfers?).and_return(true, false, false)
            expect(roster).to receive(:available_transfers).and_return(1)
            players.shift(2)
            players.push sub_player, cheap_player
            new_player_ids = players.map(&:id)

            expect(roster.update_including_players(players: new_player_ids)).to be false
            expect(roster.players).to contain_exactly *original_players
            expect(roster.errors.messages).to include(roster: ["has 1 transfer available in this window"])
          end
        end

        context "#allow_free_transfers?" do
          context "no players in roster" do
            it "returns true" do
              expect(roster.allow_free_transfers?).to eq true
            end
          end

          context "with players in roster" do
            before :each do
              players.push(warrior_player, support_player)
              roster.update_including_players(players: player_ids)
            end

            it "allows free transfers before the tournament starts" do
              allow(Time).to receive(:now).and_return(Time.parse "2017-01-01")
              expect(roster.allow_free_transfers?).to eq true
            end

            it "allows free transfers before the roster lock date in the first tournament gameweek" do
              allow(Time).to receive(:now).and_return(Time.parse "2017-01-17")
              expect(roster.allow_free_transfers?).to eq true
            end
          end
        end

        context "#roster_unlocked?" do
          it "rejects the update if the roster is locked" do
            players.push(warrior_player, support_player)
            roster.update_including_players(players: player_ids)
            original_players = players.dup

            allow(roster).to receive(:allow_free_transfers?).and_return(true, false)
            expect(roster).to receive(:roster_lock_in_place?).and_return(true)
            expect(roster).to receive(:available_transfers).and_return(1)
            players.shift(1)
            players.push cheap_player

            expect(roster.update_including_players(players: players.map(&:id))).to be false
            expect(roster.players).to contain_exactly *original_players
            expect(roster.errors.messages).to include(roster: ["is currently locked until the end of the Gameweek"])
          end
        end
      end
    end
  end
end
