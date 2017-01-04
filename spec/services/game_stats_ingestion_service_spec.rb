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
      "filename": "../replays/02.12.16_MVP_BLACK_vs_Dignitas_GAME_1_at_Summer_Global_Championship.StormReplay",
      "unique_id": "31af3b750df2b90e51121833672747969fdd3a89c8bfa1303abd6fec9a8c7758"
    }'
  }

  context "#populate_from_json" do
    it "handles null json input" do
      expect { GameStatsIngestionService.populate_from_json nil }.not_to raise_error
    end

    it "populates game details from the JSON" do
      GameStatsIngestionService.populate_from_json game_stats_json
      expect(Game.first.game_hash).to eq "31af3b750df2b90e51121833672747969fdd3a89c8bfa1303abd6fec9a8c7758"
      expect(GameDetail.all.size).to eq 10
      expect(Player.all.map(&:name).sort).to eq ["KyoCha", "Sign", "Rich", "Sake", "merryday", "Bakery", "JayPL", "Snitch", "Athero", "Mene"].sort
      expect(Team.all.map(&:name).sort).to eq ["Dignitas", "MVP BLACK"]
      expect(Map.first.name).to eq "Tomb of the Spider Queen"
    end

    it "assigns team names based on the filename if it cannot be inferred from the prefix" do
      team_names_by_colour = {
        "red" => "",
        "blue" => ""
      }
      expect(GameStatsIngestionService).to receive(:get_team_name_prefix_by_team_colour).and_return(team_names_by_colour)
      GameStatsIngestionService.populate_from_json game_stats_json
      expect(Team.all.map(&:name).sort).to eq ["Dignitas", "MVP BLACK"]
    end

    it "falls back to use the Unknown team if prefix and filename matching fails" do
      team_names_by_colour = {
        "red" => "",
        "blue" => ""
      }
      expect(GameStatsIngestionService).to receive(:get_team_name_prefix_by_team_colour).and_return(team_names_by_colour)
      expect(GameStatsIngestionService).to receive(:get_team_names_by_team_colour_from_filename).and_return(team_names_by_colour)
      GameStatsIngestionService.populate_from_json game_stats_json
      expect(Team.all.map(&:name).sort).to eq ["Unknown"]
    end
  end

  context "#get_team_name_prefix_by_team_colour" do
    it "returns the respective team name prefixes" do
      details = GameStatsIngestionService.send :get_player_details_by_team_colour, game_stats_json["player_details"]
      prefixes = GameStatsIngestionService.send :get_team_name_prefix_by_team_colour, details
      expect(prefixes).to eq({"red" => "MVP", "blue" => "DIG"})
    end
  end

  context "#get_team_names_by_team_colour_from_filename" do
    it "extracts the team names from the filename" do
      team_names_by_colour = GameStatsIngestionService.send :get_team_names_by_team_colour_from_filename, game_stats_json["filename"]
      expect(team_names_by_colour).to eq({"red" => "MVP BLACK", "blue" => "Dignitas"})
    end
  end

  context "#get_player_details_by_team_colour" do
    it "splits player details by team" do
      details = GameStatsIngestionService.send :get_player_details_by_team_colour, game_stats_json["player_details"]
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

  context "#strip_team_name_prefix_from_player_name" do
    it "strips the team name from the player name" do
      expect(GameStatsIngestionService.send :strip_team_name_prefix_from_player_name, "MVP", "MVPSign").to eq "Sign"
    end

    it "does not strip the name if it is not present" do
      expect(GameStatsIngestionService.send :strip_team_name_prefix_from_player_name, "MVP", "DIGBakery").to eq "DIGBakery"
    end

    it "only removes the team name from the beginning of the player name" do
      expect(GameStatsIngestionService.send :strip_team_name_prefix_from_player_name, "MVP", "MVPSignMVP").to eq "SignMVP"
    end

    it "handles empty team names" do
      expect(GameStatsIngestionService.send :strip_team_name_prefix_from_player_name, "", "DIGBakery").to eq "DIGBakery"
    end

    it "handles null team names" do
      expect(GameStatsIngestionService.send :strip_team_name_prefix_from_player_name, nil, "DIGBakery").to eq "DIGBakery"
    end
  end

end