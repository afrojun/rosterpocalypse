require 'rails_helper'

RSpec.describe Roster, type: :model do
  let(:region) { "EU" }
  let(:start_date) { Time.now.utc - 1.month }
  let(:end_date) { Time.now.utc + 1.month }
  let(:tournament) { FactoryGirl.create :tournament, region: region, start_date: start_date, end_date: end_date }
  let(:league) { FactoryGirl.create :public_league, tournament: tournament }
  let(:roster) { FactoryGirl.create :roster, region: region }

  context "validations" do
    context "region must be one of the pre-defined regions" do
      it "creates rosters with a valid region" do
        na_roster = FactoryGirl.create :roster, region: "NA"
        expect(na_roster).to be_persisted
      end

      it "fails to create rosters with an invalid region" do
        expect { FactoryGirl.create :roster, region: "Foo" }.to raise_error ActiveRecord::RecordInvalid
      end
    end

    context "#validate_one_roster_per_region" do
      let(:manager) { FactoryGirl.create :manager }

      it "fails to create the roster when another exists for that region" do
        success = FactoryGirl.create :roster, region: "NA", manager: manager
        expect(success).to be_persisted
        manager.rosters = [success]
        expect { FactoryGirl.create :roster, region: "NA", manager: manager }.to raise_error ActiveRecord::RecordInvalid
      end

      it "fails to update the roster when another exists for that region" do
        success = FactoryGirl.create :roster, region: "NA", manager: manager
        expect(success).to be_persisted
        manager.rosters = [success]
        failure = FactoryGirl.create :roster, region: "EU", manager: manager
        expect(failure).to be_persisted
        manager.reload
        manager.rosters << failure
        expect { failure.update_attributes!(region: "NA") }.to raise_error ActiveRecord::RecordInvalid
        failure.reload
        expect(failure.region).to eq "EU"
      end
    end

  end

  context "#available_transfers" do
    let(:start_date) { Time.now.utc - 1.month }
    let(:end_date) { Time.now.utc + 1.month }
    let(:tournament) { FactoryGirl.create :tournament, region: region, start_date: start_date, end_date: end_date }
    let(:league) { FactoryGirl.create :public_league, tournament: tournament }

    it "returns the number of available transfers from one league" do
      roster.add_to league
      expect(roster.available_transfers).to eq 1
    end

    it "returns the max number of available transfers across multiple leagues" do
      tournament2 = FactoryGirl.create :tournament, region: region, start_date: start_date + 1.week, end_date: end_date - 1.week
      league2 = FactoryGirl.create :private_league, tournament: tournament2

      roster.add_to league
      roster.add_to league2
      gameweek_roster = roster.gameweek_rosters.where(gameweek: tournament2.current_gameweek).first
      gameweek_roster.update_attribute :available_transfers, 5
      expect(roster.available_transfers).to eq 5
    end

    it "deducts completed transfers from the original number" do
      roster.add_to league
      expect(roster.available_transfers).to eq 1
      FactoryGirl.create :transfer, gameweek_roster: roster.current_gameweek_rosters.first
      expect(roster.available_transfers).to eq 0
    end
  end

  context "#update_including_players" do
    let(:player1) { FactoryGirl.create :player }
    let(:player2) { FactoryGirl.create :player }
    let(:player3) { FactoryGirl.create :player }
    let(:sub_player) { FactoryGirl.create :player }

    let(:support_player) { FactoryGirl.create :player, role: "Support" }
    let(:warrior_player) { FactoryGirl.create :player, role: "Warrior" }
    let(:expensive_player) { FactoryGirl.create :player, value: Player::MAX_VALUE }
    let(:cheap_player) { FactoryGirl.create :player, value: Player::MIN_VALUE }

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
          expect(roster.players).to eq players
        end

        it "overwrites existing associated players" do
          players.push(warrior_player, support_player)
          expect(roster.update_including_players(players: player_ids)).to eq true
          expect(roster.players.to_a).to eq players

          players.shift
          players << cheap_player
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
          expect(roster.players).to eq players
        end

        it "restricts updates once the roster has been created" do
          players.push(warrior_player, support_player)
          roster.update_including_players(players: player_ids)
          original_players = players.dup

          players.shift(2)
          players.push sub_player, cheap_player
          new_player_ids = players.map(&:id)
          expect(roster.update_including_players(players: new_player_ids)).to be false
          expect(roster.players.to_a).to eq original_players
          expect(roster.errors.messages).to include(roster: ["has 1 transfer available in this window"])
        end
      end


      context "#validate_player_roles" do
        it "requires at least 1 support player and 1 warrior player" do
          players.push sub_player, cheap_player
          expect(roster.update_including_players(players: player_ids)).to eq false
          expect(roster.players).to eq []
          expect(roster.errors.messages).to include(roster: ["needs to include at least one dedicated Support player", "needs to include at least one dedicated Warrior player"])
        end

        it "requires at least 1 support player" do
          players.push sub_player, warrior_player
          expect(roster.update_including_players(players: player_ids)).to eq false
          expect(roster.players).to eq []
          expect(roster.errors.messages).to include(roster: ["needs to include at least one dedicated Support player"])
        end

        it "requires at least 1 warrior player" do
          players.delete_at(3)
          players.push sub_player, support_player
          expect(roster.update_including_players(players: player_ids)).to eq false
          expect(roster.players).to eq []
          expect(roster.errors.messages).to include(roster: ["needs to include at least one dedicated Warrior player"])
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
          expect(roster.errors.messages).to include(roster: ["may have a maximum total player value of #{Roster::MAX_TOTAL_VALUE}"])
        end
      end

      context "#validate_transfers_count" do
        it "validates that the number of players being added and removed are the same" do
          expect(roster).to receive(:allow_free_transfers?).and_return(false)
          players.push support_player, warrior_player
          expect(roster.update_including_players(players: players.map(&:id))).to be false
          expect(roster.players).to eq []
          expect(roster.errors.messages[:roster].first).to include("transfers must maintain the roster size")
        end

        it "rejects updates that make more than the allowed number of transfers" do
          players.push(warrior_player, support_player)
          roster.update_including_players(players: player_ids)
          original_players = players.dup

          expect(roster).to receive(:allow_free_transfers?).and_return(true, false)
          expect(roster).to receive(:available_transfers).and_return(1)
          players.shift(2)
          players.push sub_player, cheap_player
          new_player_ids = players.map(&:id)

          expect(roster.update_including_players(players: new_player_ids)).to be false
          expect(roster.players.to_a).to eq original_players
          expect(roster.errors.messages).to include(roster: ["has 1 transfer available in this window"])
        end
      end

      context "#roster_unlocked?" do
        it "rejects the update if the roster is locked" do
          players.push(warrior_player, support_player)
          roster.update_including_players(players: player_ids)
          original_players = players.dup

          allow(roster).to receive(:allow_free_transfers?).and_return(true, false)
          expect(roster).to receive(:any_roster_lock_in_place?).and_return(true)
          expect(roster).to receive(:available_transfers).and_return(1)
          players.shift(1)
          players.push cheap_player

          expect(roster.update_including_players(players: players.map(&:id))).to be false
          expect(roster.players).to eq original_players
          expect(roster.errors.messages).to include(roster: ["is currently locked until the end of the Gameweek"])
        end
      end
    end
  end
end
