import React, { PropTypes } from 'react';

const TableFilter = (props) => {
  return (
    <div className="table-filter btn-group">
      <input className="table-filter-input" type="text" placeholder="Filter by Name, Role or Team" value={props.filter} onChange={props.updateFilter} />
      <span className="fa fa-times-circle clear-filter" onClick={props.clearFilter}></span>
    </div>
  );
};

TableFilter.propTypes = {
  filter: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
  clearFilter: PropTypes.func.isRequired
};

export default TableFilter;
