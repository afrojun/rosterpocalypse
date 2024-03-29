import React, { PropTypes } from 'react';

const RosterSidebar = (props) => {
  return (
    <div className="well">

      <div className="sidebar-div">
        <h4 className="sidebar-heading">
          Roster
        </h4>

        <span className="sidebar-subheading">League Ranking:</span>
        <table className="sidebar-table">
          <tbody>
            {
              <tr key={props.roster.league.name}>
                <td className="sidebar-table-label"><a href={props.roster.league.url}>{props.roster.league.name}</a></td>
                <td className="sidebar-table-value">{props.roster.league.roster_rank}/{props.roster.league.roster_count}</td>
              </tr>
            }
          </tbody>
        </table>

        <span className="sidebar-subheading">Tournament:</span>
        <p>
          {props.roster.tournament.name}
        </p>

        {
          props.showManageRoster &&
            <p>
              <a href={props.rosterPath}>Status</a>
              {"  |  "}
              <a href={props.rosterPath + "/manage"}>Manage</a>
            </p>
        }
      </div>

      <div className="sidebar-div">
        <h4 className="sidebar-heading">
          Points
        </h4>
        <table className="sidebar-table">
          <tbody>
            <tr>
              <td className="sidebar-table-label">Overall</td>
              <td className="sidebar-table-value">{props.roster.score}</td>
            </tr>
            <tr>
              <td className="sidebar-table-label">{props.roster.previous_gameweek.name}</td>
              <td className="sidebar-table-value">{props.roster.previous_gameweek.points_string}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="sidebar-div">
        <h4 className="sidebar-heading">
          Transfers
        </h4>
        <table className="sidebar-table">
          <tbody>
            <tr>
              <td className="sidebar-table-label">Transfers available</td>
              <td className="sidebar-table-value">{props.remainingTransfersCount()}
              </td>
            </tr>
          </tbody>
        </table>

        {
          props.roster.transfers[0] &&
            <div>
              <h5 className="sidebar-subheading">
                Recent Transfers
              </h5>
              <table className="sidebar-table">
                <tbody>
                  {
                    props.roster.transfers.map(transfer => (
                      <tr key={transfer.gameweek_roster_id + "_" + transfer.player_in_id + "_" + transfer.player_out_id}>
                        <td className="sidebar-transfers-players">
                          {transfer.player_in.name} <i className="fa fa-caret-up text-success"></i>
                          <i className="fa fa-caret-down text-danger"></i> {transfer.player_out.name}
                        </td>
                      </tr>
                    ))
                  }
                </tbody>

              </table>
            </div>
        }
      </div>

      <div className="sidebar-div">
        <h4 className="sidebar-heading">
          Matches
        </h4>
        {
          props.roster.matches[0] &&
            <div>
              <table className="sidebar-table">
                <tbody>
                  {
                    props.roster.matches.map(match => (
                      <tr key={match.id}>
                        <td>{moment(match.start_date).format("dd")}</td>
                        <td>{moment(match.start_date).format("HH:mm")}</td>
                        <td className="sidebar-table-value sidebar-match-team1">{match.team_1.short_name}</td>
                        <td><img src={match.team_1.logo} title={match.team_1.name} width="16" height="16"/></td>
                        <td className="sidebar-table-value sidebar-match-vs">vs</td>
                        <td><img src={match.team_2.logo} title={match.team_2.name} width="16" height="16"/></td>
                        <td className="sidebar-table-value">{match.team_2.short_name}</td>
                      </tr>
                    ))
                  }
                </tbody>

              </table>
            </div>
        }
        <small>(Times in local timezone)</small>
      </div>
    </div>
  );
};

RosterSidebar.propTypes = {
  roster: PropTypes.object.isRequired,
  rosterPath: PropTypes.string.isRequired,
  remainingTransfersCount: PropTypes.func.isRequired,
  showManageRoster: PropTypes.bool.isRequired
};

export default RosterSidebar;
