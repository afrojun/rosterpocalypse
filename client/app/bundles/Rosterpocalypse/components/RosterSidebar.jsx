import React, { PropTypes } from 'react';

const RosterSidebar = (props) => {
  return (
    <div className="well">

      <div className="sidebar-div">
        <h4 className="sidebar-heading">
          {props.roster.name}
        </h4>
        <div>
          <p className="sidebar-subheading">
            {props.roster.tournament.name}
          </p>
          <a href={props.rosterPath}>Status</a>
          {"  |  "}
          <a href={props.rosterPath + "/manage"}>Manage</a>
        </div>
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
          League Rankings
        </h4>

        {
          props.roster.public_leagues[0] &&
            <div>
              <h5 className="sidebar-subheading">
                Public Leagues
              </h5>

              <table className="sidebar-table">
                <tbody>
                  {
                    props.roster.public_leagues.map(league => (
                      <tr key={league.name}>
                        <td className="sidebar-table-label"><a href={league.url}>{league.name}</a></td>
                        <td className="sidebar-table-value">{league.roster_rank}/{league.roster_count}</td>
                      </tr>
                    ))
                  }
                </tbody>
              </table>
            </div>
        }

        {
          props.roster.private_leagues[0] &&
            <div>
              <h5 className="sidebar-subheading">
                Private Leagues
              </h5>

              <table className="sidebar-table">
                <tbody>
                  {
                    props.roster.private_leagues.map(league => (
                      <tr key={league.name}>
                        <td className="sidebar-table-label"><a href={league.url}>{league.name}</a></td>
                        <td className="sidebar-table-value">{league.roster_rank}/{league.roster_count}</td>
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
          Fixtures
        </h4>
        <p>
          Coming soon!
        </p>
      </div>
    </div>
  );
};

RosterSidebar.propTypes = {
  roster: PropTypes.object.isRequired,
  rosterPath: PropTypes.string.isRequired,
  remainingTransfersCount: PropTypes.func.isRequired
};

export default RosterSidebar;
