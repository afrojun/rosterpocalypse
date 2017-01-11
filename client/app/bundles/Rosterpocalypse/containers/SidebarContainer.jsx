import React, { PropTypes } from "react";
import ReactOnRails from "react-on-rails";
import RosterSidebar from "../components/RosterSidebar";
import rp from "request-promise-native";
import moment from "moment";

class RosterPickerContainer extends React.Component {
  static propTypes = {
    rosterPath: PropTypes.string.isRequired,
    rosterDetailsPath: PropTypes.string.isRequired,
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
      }
    };

    this.fetchRoster = this.fetchRoster.bind(this);
    this.colourText = this.colourText.bind(this);
    this.remainingTransfersCount = this.remainingTransfersCount.bind(this);
  }

  componentWillMount() {
    this.fetchRoster();
  }

  fetchRoster() {
    return rp(this.props.rosterDetailsPath + ".json").
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

  remainingTransfersCount() {
    if(this.state.roster.free_transfer_mode) {
      return this.colourText("\u221e", "green");
    } else {
      let remaining_transfers = this.state.roster.current_gameweek.remaining_transfers;
      return(remaining_transfers == 0 ? this.colourText("0", "red") : remaining_transfers);
    }
  }

  render() {
    return (
      <div>
        <RosterSidebar
          roster={this.state.roster}
          remainingTransfersCount={this.remainingTransfersCount}
          rosterPath={this.props.rosterPath} />
      </div>
    );
  }
}

export default RosterPickerContainer;