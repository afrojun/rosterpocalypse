import React, { PropTypes } from "react";
import ReactOnRails from "react-on-rails";
import PlayersTable from "../components/PlayersTable";
import TableFilter from "../components/TableFilter";
import RosterSidebar from "../components/RosterSidebar";
import PaginationElementsPerPageSelector from "../components/PaginationElementsPerPageSelector";
import rp from "request-promise-native";
import moment from "moment";

class RosterPickerContainer extends React.Component {
  static propTypes = {
    rosterPath: PropTypes.string.isRequired,
    manageRosterPath: PropTypes.string.isRequired,
    playersPath: PropTypes.string.isRequired,
    rosterRegion: PropTypes.string.isRequired,
    maxPlayersInRoster: PropTypes.number.isRequired,
    maxRosterValue: PropTypes.number.isRequired
  };

  constructor(props, _railsContext) {
    super(props);
    this.state = {
      roster: {
        current_gameweek: {},
        previous_gameweek: {},
        tournament: {},
        players: [],
        public_leagues: [],
        private_leagues: [],
        transfers: []
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
    this.colourText = this.colourText.bind(this);
    this.totalValue = this.totalValue.bind(this);
    this.rosterLockDate = this.rosterLockDate.bind(this);
    this.remainingTransfersCount = this.remainingTransfersCount.bind(this);
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
    if(this.state.roster.players.length < this.props.maxPlayersInRoster) {
      let player = this.state.players.find(player => {
        return player.id === playerId
      });
      let rosterPlayers = this.state.roster.players.concat([player]);

      let newRoster = Object.assign({}, this.state.roster, {players: rosterPlayers});
      this.setState({roster: newRoster});
    } else {
      this.setState({notification: <span className="text-danger">Error: Rosters may have a maximum of {this.props.maxPlayersInRoster} players</span>});
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
    return rp(this.props.playersPath + ".json?active=true&region=" + this.props.rosterRegion).
              then(playersData => {
                this.setState({players: JSON.parse(playersData)});
              });
  }

  fetchRoster() {
    return rp(this.props.manageRosterPath + ".json").
              then(rosterData => {
                this.setState({roster: JSON.parse(rosterData)});
              });
  }

  colourText(text, colour) {
    let className = "";

    switch(colour) {
      case "red":
        className = "text-danger";
        break;
      case "blue":
        className = "text-info";
        break;
      case "green":
        className = "text-success";
        break;
      default:
        className = "";
    }
    return(<span className={className}>{text}</span>);
  }

  totalValue() {
    let total = this.state.roster.players.reduce((value, player) => {
              return value + player.value;
            }, 0);
    let colour = (total > this.props.maxRosterValue ? "red" : "");
    return(this.colourText(total, colour));
  }

  rosterLockDate() {
    let timeNow = moment().valueOf();
    let rosterLock = moment(this.state.roster.current_gameweek.roster_lock_date).valueOf();
    let text = "";
    let colour = "";
    if(this.state.roster.free_transfer_mode) {
      text = "Free transfer mode!";
      colour = "green";
    } else {
      if(timeNow < rosterLock) {
        text = moment(rosterLock).fromNow();
      } else {
        text = "LOCKED!"
        colour = "red";
      }
    }

    return(this.colourText(text, colour));
  }

  remainingTransfersCount() {
    if(this.state.roster.free_transfer_mode) {
      return this.colourText("\u221e", "green");
    } else {
      let remaining_transfers = this.state.roster.current_gameweek.remaining_transfers;
      return(remaining_transfers == 0 ? this.colourText("0", "red") : remaining_transfers);
    }
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

    // Refresh the roster data after updating
    this.fetchRoster();
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
      sortable: ["value"],
      filterBy: this.state.filter
    }
    let rosterTableOpts = {
      id: "rosterTable",
      className: "table table-striped table-hover table-sm",
      noDataText: "No players in roster."
    }

    return (
      <div>
        <div className="form roster-form col-xs-10">
          <h2 className="form-heading">
            {this.state.roster.name}
          </h2>
          <p>
            Total value: <b>{this.totalValue()}</b>
            <br/>
            Roster lock: <b>{this.rosterLockDate()}</b>
          </p>
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
        <div className="roster-sidebar col-xs-2">
          <RosterSidebar
            roster={this.state.roster}
            remainingTransfersCount={this.remainingTransfersCount}
            rosterPath={this.props.rosterPath} />
        </div>
      </div>
    );
  }
}

export default RosterPickerContainer;