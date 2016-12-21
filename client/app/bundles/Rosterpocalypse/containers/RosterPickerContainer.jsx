import React, { PropTypes } from "react";
import ReactOnRails from "react-on-rails";
import PlayersTable from "../components/PlayersTable";
import TableFilter from "../components/TableFilter";
import PaginationElementsPerPageSelector from "../components/PaginationElementsPerPageSelector";
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
      notification: "",
      filter: "",
      playersPerPage: 10
    };

    this.fetchRoster = this.fetchRoster.bind(this);
    this.fetchPlayers = this.fetchPlayers.bind(this);
    this.fetchData = this.fetchData.bind(this);
    this.addToRoster = this.addToRoster.bind(this);
    this.removeFromRoster = this.removeFromRoster.bind(this);
    this.totalCost = this.totalCost.bind(this);
    this.submitRoster = this.submitRoster.bind(this);
    this.showRosterActionForAllPlayers = this.showRosterActionForAllPlayers.bind(this);
    this.updateFilter = this.updateFilter.bind(this);
    this.clearFilter = this.clearFilter.bind(this);
    this.changePlayersPerPage = this.changePlayersPerPage.bind(this);
  }

  componentWillMount() {
    this.fetchData();
  }

  componentDidMount() {
    $("tbody.reactable-pagination tr td").addClass("custom-pagination");
  }

  updateFilter(event) {
    event.preventDefault();
    this.setState({filter: event.target.value});
  }

  clearFilter() {
    this.setState({filter: ""});
  }

  changePlayersPerPage(event) {
    this.setState({playersPerPage: event.target.value});
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
      this.setState({notification: <span className="text-danger">Error: Rosters may have a maximum of {RosterPickerContainer.MAX_PLAYERS_IN_ROSTER} players</span>});
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
    let total = this.state.roster.players.reduce((cost, player) => {
              return cost + player.cost;
            }, 0);
    let className = "";
    if(total > RosterPickerContainer.MAX_ROSTER_COST) {
      className = "text-danger"
    }
    return(<span className={className}>{total}</span>);
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
        this.setState({notification: <span className="text-success">Roster updated successfully!</span>});
      })
      .catch(err => {
        console.log(err);
        this.setState({notification: <span className="text-danger">Error: {err.error}</span>});
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
      itemsPerPage: this.state.playersPerPage,
      pageButtonLimit: 5,
      previousPageLabel: "<",
      nextPageLabel: ">",
      sortable: ["cost"],
      filterBy: this.state.filter
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
          {this.state.roster.name} contains {this.state.roster.players.length} players with a total cost of {this.totalCost()}
        </h3>
        <PlayersTable
          tableOpts={rosterTableOpts}
          imageClass="fa-minus-square text-danger"
          players={this.state.roster.players}
          onClick={this.removeFromRoster}
          showRosterAction={this.showRosterActionForRosterPlayers}
          updateFilter={this.updateFilter} />

        <TableFilter
          filter={this.state.filter}
          updateFilter={this.updateFilter}
          clearFilter={this.clearFilter} />

        <PaginationElementsPerPageSelector
          changePlayersPerPage={this.changePlayersPerPage} />

        <PlayersTable
          tableOpts={playersTableOpts}
          imageClass="fa-plus-square text-success"
          players={this.state.players}
          onClick={this.addToRoster}
          showRosterAction={this.showRosterActionForAllPlayers}
          updateFilter={this.updateFilter} />

        <input type="submit" value="Update Roster" className="btn btn-primary" onClick={this.submitRoster} />
        <span className="roster-pick-notification">{this.state.notification}</span>

      </div>
    );
  }
}

RosterPickerContainer.MAX_PLAYERS_IN_ROSTER = 5;
RosterPickerContainer.MAX_ROSTER_COST = 500;

export default RosterPickerContainer;