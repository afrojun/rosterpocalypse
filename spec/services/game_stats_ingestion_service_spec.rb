require "rails_helper"

describe GameStatsIngestionService do

  let(:game_stats_json) {
    JSON.parse '{
      "duration": 1334,
      "map_name": "Tomb of the Spider Queen",
      "player_details": {
        "5": {
          "hero": "Tychus",
          "Takedowns": 10,
          "Deaths": 2,
          "SoloKill": 5,
          "Assists": 5,
          "result": "win",
          "TimeSpentDead": 40,
          "team": "red",
          "name": "MVPKyoCha"},
        "6": {
          "hero": "Muradin",
          "Takedowns": 10,
          "Deaths": 0,
          "SoloKill": 2,
          "Assists": 8,
          "result": "win",
          "TimeSpentDead": 0,
          "team": "red",
          "name": "MVPSign"},
        "7": {
          "hero": "Tyrael",
          "Takedowns": 9,"Deaths": 2,
          "SoloKill": 1,
          "Assists": 8,
          "result": "win",
          "TimeSpentDead": 42,
          "team": "red",
          "name": "MVPRich"},
        "8": {
          "hero": "Guldan",
          "Takedowns": 11,
          "Deaths": 1,
          "SoloKill": 0,
          "Assists": 11,
          "result": "win",
          "TimeSpentDead": 22,
          "team": "red",
          "name": "MVPSake"},
        "9": {
          "hero": "Auriel",
          "Takedowns": 11,
          "Deaths": 0,
          "SoloKill": 3,
          "Assists": 8,
          "result": "win",
          "TimeSpentDead": 0,
          "team": "red",
          "name": "MVPmerryday"},
        "10": {
          "hero": "Rehgar",
          "Takedowns": 5,
          "Deaths": 0,
          "SoloKill": 2,
          "Assists": 3,
          "result": "loss",
          "TimeSpentDead": 0,
          "team": "blue",
          "name": "DIGBakery"},
        "11": {
          "hero": "Leoric",
          "Takedowns": 3,
          "Deaths": 3,
          "SoloKill": 0,
          "Assists": 3,
          "result": "loss",
          "TimeSpentDead": 155,
          "team": "blue",
          "name": "DIGJayPL"},
        "13": {
          "hero": "Falstad",
          "Takedowns": 3,
          "Deaths": 3,
          "SoloKill": 1,
          "Assists": 2,
          "result": "loss",
          "TimeSpentDead": 113,
          "team": "blue",
          "name": "DIGSnitch"},
        "14": {
          "hero": "Crusader",
          "Takedowns": 5,
          "Deaths": 3,
          "SoloKill": 0,
          "Assists": 5,
          "result": "loss",
          "TimeSpentDead": 125,
          "team": "blue",
          "name": "DIGAthero"},
        "15": {
          "hero": "DemonHunter",
          "Takedowns": 5,
          "Deaths": 2,
          "SoloKill": 2,
          "Assists": 3,
          "result": "loss",
          "TimeSpentDead": 109,
          "team": "blue",
          "name": "DIGMene"
        }
      },
      "start_epoch_time_utc": 1477681743,
      "unique_id": "31af3b750df2b90e51121833672747969fdd3a89c8bfa1303abd6fec9a8c7758"
    }'
  }

  context "#populate_from_json" do

    it "handles null json input" do
      expect { GameStatsIngestionService.populate_from_json nil }.not_to raise_error
    end

    it "populates game data correctly" do
      GameStatsIngestionService.populate_from_json game_stats_json
      expect(Player.all.map(&:name).sort).to eq ["KyoCha", "Sign", "Rich", "Sake", "merryday", "Bakery", "JayPL", "Snitch", "Athero", "Mene"].sort
      expect(Game.first.game_hash).to eq "31af3b750df2b90e51121833672747969fdd3a89c8bfa1303abd6fec9a8c7758"
      expect(PlayerGameDetail.all.size).to eq 10
    end
  end

  context "#get_team_name_prefix_by_team" do

    it "returns the respective team name prefixes" do
      details = GameStatsIngestionService.send :get_player_details_by_team, game_stats_json["player_details"]
      prefixes = GameStatsIngestionService.send :get_team_name_prefix_by_team, details
      expect(prefixes).to eq({"red" => "MVP", "blue" => "DIG"})
    end

  end

  context "#get_player_details_by_team" do

    it "splits player details by team" do
      details = GameStatsIngestionService.send :get_player_details_by_team, game_stats_json["player_details"]
      expect(details.keys).to eq ["red", "blue"]
      expect(details["red"].length).to eq 5
      expect(details["blue"].length).to eq 5
    end

  end

  context "#get_team_name_prefix" do

    it "gets the team name prefix" do
      player_names = ["MVPSign", "MVPKyocha", "MVPRich", "MVPSake", "MVPMerryday"]
      expect(GameStatsIngestionService.send :get_team_name_prefix, player_names).to eq "MVP"
    end

    it "returns an empty string when any name doesn't match" do
      player_names = ["MVPSign", "MVPKyocha", "MVPRich", "Sake", "MVPMerryday"]
      expect(GameStatsIngestionService.send :get_team_name_prefix, player_names).to eq ""
    end

    it "returns the first name if it matches completely" do
      player_names = ["MVPSign", "MVPSigned"]
      expect(GameStatsIngestionService.send :get_team_name_prefix, player_names).to eq "MVPSign"
    end

  end

  context "#strip_team_name_from_player_name" do
    it "Strips the team name from the player name" do
      expect(GameStatsIngestionService.send :strip_team_name_from_player_name, "MVP", "MVPSign").to eq "Sign"
    end

    it "Does not strip the name if it is not present" do
      expect(GameStatsIngestionService.send :strip_team_name_from_player_name, "MVP", "DIGBakery").to eq "DIGBakery"
    end

    it "Only removes the team name from the beginning of the player name" do
      expect(GameStatsIngestionService.send :strip_team_name_from_player_name, "MVP", "MVPSignMVP").to eq "SignMVP"
    end
  end

end