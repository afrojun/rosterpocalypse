import React, { PropTypes } from 'react';

const RosterChangeImage = (props) => {
  return (
    <i
      key={props.id}
      className={"roster-change fa " + props.imageClass}
      onClick={props.onClick.bind(this, props.id)}>
    </i>
  );
};

RosterChangeImage.propTypes = {
  id: PropTypes.number.isRequired,
  imageClass: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired
};

export default RosterChangeImage;
