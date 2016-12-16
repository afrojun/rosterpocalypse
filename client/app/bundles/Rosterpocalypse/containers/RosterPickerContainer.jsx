import React, { PropTypes } from "react";
import ReactOnRails from "react-on-rails";
import PlayersTable from "../components/PlayersTable";
import rp from "request-promise-native";

class RosterPickerContainer extends React.Component {
  static propTypes = {
    rosterPath: PropTypes.string.isRequired,
    playersPath: PropTypes.string.isRequired
  };

  constructor(props, _railsContext) {
    super(props);
    this.state = {
      roster: {
        players: []
      },
      players: [],
      notification: ""
    };

    this.fetchRoster = this.fetchRoster.bind(this);
    this.fetchPlayers = this.fetchPlayers.bind(this);
    this.fetchData = this.fetchData.bind(this);
    this.addToRoster = this.addToRoster.bind(this);
    this.removeFromRoster = this.removeFromRoster.bind(this);
    this.totalCost = this.totalCost.bind(this);
    this.submitRoster = this.submitRoster.bind(this);
    this.showRosterActionForAllPlayers = this.showRosterActionForAllPlayers.bind(this);
  }

  componentWillMount() {
    this.fetchData();
  }

  componentDidMount() {
    $("tbody.reactable-pagination tr td").addClass("custom-pagination");
  }

  addToRoster(playerId) {
    if(this.state.roster.players.length < RosterPickerContainer.MAX_PLAYERS_IN_ROSTER) {
      let player = this.state.players.find(player => {
        return player.id === playerId
      });
      let rosterPlayers = this.state.roster.players.concat([player]);

      let newRoster = Object.assign({}, this.state.roster, {players: rosterPlayers});
      this.setState({roster: newRoster});
    } else {
      this.setState({notification: <span className="text-danger">Only {RosterPickerContainer.MAX_PLAYERS_IN_ROSTER} players are allowed in a roster!</span>})
    }
  }

  removeFromRoster(playerId) {
    // Remove the player from the roster
    let rosterPlayers = this.state.roster.players.filter(player => {
      return player.id !== playerId
    });

    let newRoster = Object.assign({}, this.state.roster, {players: rosterPlayers});
    this.setState({roster: newRoster});
    this.setState({notification: ""})
  }

  fetchData() {
    this.fetchRoster();
    this.fetchPlayers();
  }

  fetchPlayers() {
    return rp(this.props.playersPath + ".json").
              then(playersData => {
                this.setState({players: JSON.parse(playersData)});
              });
  }

  fetchRoster() {
    return rp(this.props.rosterPath + ".json").
              then(rosterData => {
                this.setState({roster: JSON.parse(rosterData)});
              });
  }

  totalCost() {
    return this.state.roster.players.reduce((cost, player) => {
      return cost + player.cost;
    }, 0);
  }

  submitRoster() {
    var options = {
      method: "PUT",
      uri: this.props.rosterPath + ".json",
      body: {
        roster: {
          players: this.state.roster.players.map(player => { return player.id; })
        },
        authenticity_token: ReactOnRails.authenticityToken()
      },
      json: true // Automatically stringifies the body to JSON
    };

    rp(options)
      .then(parsedBody => {
        this.setState({notification: <span className="text-success">Roster updated successfully!</span>})
      })
      .catch(err => {
        this.setState({notification: <span className="text-danger">Error while updating the roster: {err}</span>})
      });
  }

  showRosterActionForAllPlayers(playerId) {
    let player = this.state.roster.players.find(player => {
      return player.id === playerId;
    });
    return player ? false : true;
  }

  showRosterActionForRosterPlayers(playerId) {
    return true;
  }

  render() {
    let playersTableOpts = {
      id: "playersTable",
      className: "table table-striped table-hover table-sm",
      filterable: ["name", "role", "team"],
      noDataText: "No matching players found.",
      itemsPerPage: 10,
      pageButtonLimit: 5,
      previousPageLabel: "<",
      nextPageLabel: ">",
      sortable: ["cost"]
    }
    let rosterTableOpts = {
      id: "rosterTable",
      className: "table table-striped table-hover table-sm",
      noDataText: "No players in roster."
    }

    return (
      <div className="form roster-form">
        <h1 className="form-heading">
          Editing Roster
        </h1>
        <h3 className="form-heading">
          {this.state.roster.name} contains {this.state.roster.players.length} players with a total Cost of {this.totalCost()}
        </h3>
        <PlayersTable
          tableOpts={rosterTableOpts}
          imageClass="fa-minus-square text-danger"
          players={this.state.roster.players}
          onClick={this.removeFromRoster}
          showRosterAction={this.showRosterActionForRosterPlayers} />

        <input type="submit" value="Update Roster" className="btn btn-primary" onClick={this.submitRoster} />
        {"  "}
        {this.state.notification}

        <h3 className="form-heading">Add Players:</h3>
        <PlayersTable
          tableOpts={playersTableOpts}
          imageClass="fa-plus-square text-success"
          players={this.state.players}
          onClick={this.addToRoster}
          showRosterAction={this.showRosterActionForAllPlayers} />

      </div>
    );
  }
}

RosterPickerContainer.MAX_PLAYERS_IN_ROSTER = 5;

export default RosterPickerContainer;