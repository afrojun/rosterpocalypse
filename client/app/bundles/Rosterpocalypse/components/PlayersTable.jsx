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
    <Table {...props.tableOpts} >
      <Thead>
        <Th column="rosterAction" className="col-sm-1">.</Th>
        <Th column="name" className="col-sm-3">Name</Th>
        <Th column="role" className="col-sm-3">Role</Th>
        <Th column="team" className="col-sm-3">Team</Th>
        <Th column="cost" className="col-sm-2">Cost</Th>
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
            <Td column="name" className="col-sm-3"><a href={player.url}>{player.name}</a></Td>
            <Td column="role" className="col-sm-3">{player.role}</Td>
            <Td column="team" className="col-sm-3">{player.team && player.team.name}</Td>
            <Td column="cost" className="col-sm-2">{player.cost}</Td>
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
  showRosterAction: PropTypes.func.isRequired
};

export default PlayersTable;
