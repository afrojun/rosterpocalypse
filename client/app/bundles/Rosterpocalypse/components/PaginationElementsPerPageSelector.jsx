import React, { PropTypes } from 'react';

const PaginationElementsPerPageSelector = (props) => {
  return (
    <div className="pagination-page-selector">
      <select name="Page size" onChange={props.changePlayersPerPage}>
        <option value="10">10</option>
        <option value="25">25</option>
        <option value="50">50</option>
        <option value="100">100</option>
      </select>
    </div>
  );
};

PaginationElementsPerPageSelector.propTypes = {
  changePlayersPerPage: PropTypes.func.isRequired
};

export default PaginationElementsPerPageSelector;

