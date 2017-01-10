import React, { PropTypes } from 'react';

const RosterSidebar = (props) => {
  return (
    <div className="well">
      <div className="sidebar-table">
        <h4>
          Points
        </h4>
        <table>
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

      <div className="sidebar-table">
        <h4 className="sidebar-table-heading">
          League Rankings
        </h4>
        <table>
          <tbody>
            {
              props.roster.leagues.map(league => (
                <tr key={league.name}>
                  <td className="sidebar-table-label">{league.name}</td>
                  <td className="sidebar-table-value">{league.roster_rank}/{league.roster_count}</td>
                </tr>
              ))
            }
          </tbody>
        </table>
      </div>

      <div className="sidebar-table">
        <h4>
          Transfers
        </h4>
        <table>
          <tbody>
            <tr>
              <td className="sidebar-table-label">Transfers available</td>
              <td className="sidebar-table-value">{props.remainingTransfersCount()}
              </td>
            </tr>
          </tbody>
        </table>

        <h5 className="sidebar-table-subheading">
          Recent Transfers
        </h5>
        <table>
          <tbody>
            {
              props.roster.transfers.map(transfer => (
                <tr key={transfer.id}>
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

      <div className="sidebar-table">
        <h4>
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
  remainingTransfersCount: PropTypes.func.isRequired
};

export default RosterSidebar;