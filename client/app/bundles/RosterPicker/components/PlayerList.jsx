import React from 'react';

const PlayerList = (props) => {
  return (
    <ul>
      {
        props.players.map(player => (
          <li key={player.id}>
            <a href={player.url}>{player.name}</a>
          </li>
      ))}
    </ul>
  );
};

export default PlayerList;