import React, { PropTypes } from 'react';
import RosterChangeImage from './RosterChangeImage';
import Reactable from 'reactable';

const PlayersTable = (props) => {
  let Table = Reactable.Table,
      Thead = Reactable.Thead,
      Th = Reactable.Th,
      Tr = Reactable.Tr,
      Td = Reactable.Td;

  return (
    <Table {...props.tableOpts} hideFilterInput >
      <Thead>
        <Th column="rosterAction" className="col-sm-1">.</Th>
        <Th column="name" className="col-sm-3">Name</Th>
        <Th column="role" className="col-sm-3">Role</Th>
        <Th column="team" className="col-sm-3">Team</Th>
        <Th column="value" className="col-sm-2">Value</Th>
      </Thead>
      {
        props.players.map(player => (
          <Tr key={player.id}>
            <Td column="rosterAction" className="col-sm-1">
              {
                props.showRosterAction(player.id) ?
                  <RosterChangeImage
                    id={player.id}
                    imageClass={props.imageClass}
                    onClick={props.onClick}
                  />
                  : ""
              }

            </Td>
            <Td column="name" value={player.name} className="col-sm-3"><a href={player.url}>{player.name}</a></Td>
            <Td column="role" value={player.role} className="col-sm-3">
              <button className="btn btn-link table-filter-link" value={player.role} onClick={props.updateFilter}>{player.role}</button>
            </Td>
            <Td column="team" value={player.team && player.team.name} className="col-sm-3">
              <button className="btn btn-link table-filter-link" value={player.team && player.team.name} onClick={props.updateFilter}>{player.team && player.team.name}</button>
            </Td>
            <Td column="value" className="col-sm-2">{player.value}</Td>
          </Tr>
      ))}
    </Table>
  );
};

PlayersTable.propTypes = {
  tableOpts: PropTypes.object.isRequired,
  players: PropTypes.array.isRequired,
  imageClass: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  showRosterAction: PropTypes.func.isRequired,
  updateFilter: PropTypes.func.isRequired
};

export default PlayersTable;
