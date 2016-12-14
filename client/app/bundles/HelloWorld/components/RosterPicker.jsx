import React, { PropTypes } from 'react';

export default class RosterPicker extends React.Component {
  static propTypes = {
    name: PropTypes.string.isRequired,
    players: PropTypes.array.isRequired,
  };

  constructor(props, _railsContext) {
    super(props);
    this.roster = {
      name: this.props.name,
      players: this.props.players,
    };
  }

  render() {
    return (
      <div>
        <h1 className="form-heading">
          Editing Roster: {this.roster.name}
        </h1>
        <h3>
          Players:
        </h3>
        <PlayerList players={this.roster.players} />
      </div>
    );
  }
}

class PlayerList extends React.Component {
  render() {
    return (
      <ul>
        {this.props.players.map(player => (
          <li key={player}>
            <a href="">{player}</a>
          </li>
        ))}
      </ul>
    );
  }
}