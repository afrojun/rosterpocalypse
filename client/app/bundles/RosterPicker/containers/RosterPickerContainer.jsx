import React, { PropTypes } from 'react';
import ReactOnRails from 'react-on-rails';
import PlayerList from '../components/PlayerList';
import PlayersTable from '../components/PlayersTable';
import rp from 'request-promise-native';

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
    console.log("componentWillMount")
    this.fetchData();
  }

  addToRoster(playerId) {
    console.log(playerId);

    if(this.state.roster.players.length < 5) {
      let player = this.state.players.find(player => {
        return player.id === playerId
      });
      let rosterPlayers = this.state.roster.players.concat([player]);

      let newRoster = Object.assign({}, this.state.roster, {players: rosterPlayers});
      this.setState({roster: newRoster});
    } else {
      console.log("Only 5 players are allowed in a roster!");
      this.setState({notification: <span className="text-danger">Only 5 players are allowed in a roster!</span>})
    }
  }

  removeFromRoster(playerId) {
    console.log(playerId);

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
    console.log("submit roster: " + this.state.roster);

    var options = {
      method: 'PUT',
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
    console.log("render");
    console.log(this.state);
    return (
      <div className="form roster-form">
        <h1 className="form-heading">
          Editing Roster
        </h1>
        <h3 className="form-heading">
          {this.state.roster.name} contains {this.state.roster.players.length} players with a total Cost of {this.totalCost()}
        </h3>
        <PlayersTable
          imageClass="fa-minus-square text-danger"
          players={this.state.roster.players}
          onClick={this.removeFromRoster}
          showRosterAction={this.showRosterActionForRosterPlayers} />

        <input type="submit" value="Update Roster" className="btn btn-primary" onClick={this.submitRoster} />
        {"  "}
        {this.state.notification}

        <h3 className="form-heading">Add Players:</h3>
        <PlayersTable
          imageClass="fa-plus-square text-success"
          players={this.state.players}
          onClick={this.addToRoster}
          showRosterAction={this.showRosterActionForAllPlayers} />

      </div>
    );
  }
}

export default RosterPickerContainer;