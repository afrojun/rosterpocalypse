import React, { PropTypes } from 'react';

const PlayerList = (props) => {
  return (
    <table className="table table-striped table-hover table-sm">
      <thead>
        <tr>
          <th className="col-sm-1">.</th>
          <th className="col-sm-4">Name</th>
          <th className="col-sm-4">Team</th>
          <th className="col-sm-3">Cost</th>
        </tr>
      </thead>
      <tbody>
        {
          props.players.map(player => (
            <tr key={player.id}>
              <td className="col-sm-1">
                {
                  props.showRosterAction(player.id) &&
                  <RosterChangeImage
                    id={player.id}
                    imageClass={props.imageClass}
                    onClick={props.onClick}
                  />
                }

              </td>
              <td className="col-sm-4"><a href={player.url}>{player.name}</a></td>
              <td className="col-sm-4">{player.team && player.team.name}</td>
              <td className="col-sm-3">{player.cost}</td>
            </tr>
        ))}
      </tbody>
    </table>
  );
};

export default PlayerList;

const RosterChangeImage = (props) => {
  return (
    <i
      key={props.id}
      className={"roster-change fa " + props.imageClass}
      onClick={props.onClick.bind(this, props.id)}>
    </i>
  );
};
