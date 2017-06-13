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
    rosterDetailsPath: PropTypes.string.isRequired,
    playersPath: PropTypes.string.isRequired,
    rosterRegion: PropTypes.string.isRequired,
    maxPlayersInRoster: PropTypes.number.isRequired,
    maxRosterValue: PropTypes.number.isRequired,
    showPrivateLeagues: PropTypes.bool.isRequired
  };

  constructor(props, _railsContext) {
    super(props);
    this.state = {
      roster: {
        current_gameweek: {},
        previous_gameweek: {},
        tournament: {},
        league: {},
        players: [],
        transfers: [],
        matches: []
      },
      players: [],
      notification: "",
      filter: "",
      playersPerPage: 10,
      totalValue: 0
    };

    this.fetchRoster = this.fetchRoster.bind(this);
    this.fetchPlayers = this.fetchPlayers.bind(this);
    this.fetchData = this.fetchData.bind(this);
    this.addToRoster = this.addToRoster.bind(this);
    this.removeFromRoster = this.removeFromRoster.bind(this);
    this.updateRosterState = this.updateRosterState.bind(this);
    this.updateRosterValue = this.updateRosterValue.bind(this);
    this.colourText = this.colourText.bind(this);
    this.formattedTotalValue = this.formattedTotalValue.bind(this);
    this.rosterLockStatus = this.rosterLockStatus.bind(this);
    this.remainingTransfersCount = this.remainingTransfersCount.bind(this);
    this.submitRoster = this.submitRoster.bind(this);
    this.showRosterActionForAllPlayers = this.showRosterActionForAllPlayers.bind(this);
    this.showRosterActionForRosterPlayers = this.showRosterActionForRosterPlayers.bind(this);
    this.updateFilter = this.updateFilter.bind(this);
    this.setTableRowClass = this.setTableRowClass.bind(this);
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

  setTableRowClass(value) {
    let remainingValue = this.props.maxRosterValue - this.state.totalValue;
    return (value > remainingValue ? "team-red" : "");
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

      this.updateRosterState({players: rosterPlayers});
    } else {
      this.setState({notification: <span className="text-danger">Error: Rosters may have a maximum of {this.props.maxPlayersInRoster} players</span>});
    }
  }

  removeFromRoster(playerId) {
    // Remove the player from the roster
    let rosterPlayers = this.state.roster.players.filter(player => {
      return player.id !== playerId
    });

    this.updateRosterState({players: rosterPlayers});
    this.setState({notification: ""})
  }

  updateRosterState(object) {
    let newRoster = Object.assign({}, this.state.roster, object, {dirty: true});
    this.setState(
      {roster: newRoster},
      () => {
        this.updateRosterValue();
      });
  }

  updateRosterValue() {
    let total = this.state.roster.players.reduce((value, player) => {
                  return value + player.value;
                }, 0);
    let roundedTotal = Math.round(total * 100)/100;
    this.setState({totalValue: roundedTotal});
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
    return rp(this.props.rosterDetailsPath + ".json").
              then(rosterData => {
                this.setState(
                  {roster: JSON.parse(rosterData)},
                  () => {
                    this.updateRosterValue();
                  });
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

  formattedTotalValue() {
    let colour = (this.state.totalValue > this.props.maxRosterValue ? "red" : "");
    return(this.colourText(this.state.totalValue + "/" + this.props.maxRosterValue, colour));
  }

  rosterLockStatus() {
    let dateFormat = "hA on ddd, MMM D Y"
    let timeNow = moment();
    let rosterLockDate = moment(this.state.roster.current_gameweek.roster_lock_date);
    let nextKeyDate = moment(this.state.roster.next_key_date);
    let text = "";
    let colour = "";

    if(this.state.roster.free_transfer_mode) {
      if(this.state.roster.full) {
        text = "Unlimited roster changes allowed until " + nextKeyDate.format(dateFormat);
        colour = "green";
      } else {
        text = "Select " + this.props.maxPlayersInRoster + " players for your roster";
        colour = "blue";
      }
    } else {
      if(this.state.roster.unlocked) {
        text = "Roster will lock " + rosterLockDate.fromNow() + " at " + rosterLockDate.format(dateFormat);
      } else {
        text = "LOCKED until " + nextKeyDate.format(dateFormat);
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
      .then(rosterDetails => {
        this.setState({roster: rosterDetails});
        this.setState({notification: <span className="text-success">Roster updated successfully!</span>});
      })
      .catch(err => {
        if(err.response.statusCode == 422){
          this.setState({notification: <span className="text-danger">Error: {err.error}</span>});
        } else {
          this.setState({notification: <span className="text-danger">Error: Server Error</span>});
        }
      });
  }

  showRosterActionForAllPlayers(playerId) {
    if(this.state.roster.allow_updates) {
      let player = this.state.roster.players.find(player => {
        return player.id === playerId;
      });
      return player ? false : true;
    }
    return false;
  }

  showRosterActionForRosterPlayers(playerId) {
    return this.state.roster.allow_updates ? true : false;
  }

  render() {
    let playersTableOpts = {
      id: "playersTable",
      className: "table table-hover table-sm",
      filterable: ["name", "role", "team"],
      noDataText: "No matching players found.",
      itemsPerPage: this.state.playersPerPage,
      pageButtonLimit: 5,
      previousPageLabel: "<",
      nextPageLabel: ">",
      sortable: ["name", "value", "role", "team"],
      filterBy: this.state.filter
    }
    let rosterTableOpts = {
      id: "rosterTable",
      className: "table table-hover table-sm",
      noDataText: "No players in roster."
    }

    return (
      <div>
        <div className="form roster-form col-xs-10">
          <h2 className="form-heading">
            Manage Your Roster
          </h2>
          <p>
            Total value: <b>{this.formattedTotalValue()} ({Math.round((this.props.maxRosterValue - this.state.totalValue)*100)/100} remaining)</b>
            <br/>
            <b>{this.state.roster.current_gameweek.roster_lock_date && this.rosterLockStatus()}</b>
            <br/>
            <button type="button" className="btn btn-secondary" data-toggle="modal" data-target={"#rulesModal" + this.state.roster.league.id}>
              View League Rules
            </button>
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
            setTableRowClass={this.setTableRowClass}
            updateFilter={this.updateFilter} />

          <input type="submit" value="Update Roster" className="btn btn-primary" onClick={this.submitRoster} />
          <span className="roster-pick-notification">{this.state.notification}</span>

        </div>

        <div className="roster-sidebar col-xs-2">
          <RosterSidebar
            roster={this.state.roster}
            remainingTransfersCount={this.remainingTransfersCount}
            rosterPath={this.props.rosterPath}
            showPrivateLeagues={this.props.showPrivateLeagues} />
        </div>
      </div>
    );
  }
}

export default RosterPickerContainer;