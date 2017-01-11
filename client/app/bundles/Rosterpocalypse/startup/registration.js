import ReactOnRails from 'react-on-rails';
import RosterPickerContainer from '../containers/RosterPickerContainer';
import SidebarContainer from '../containers/SidebarContainer';

ReactOnRails.setOptions({
  traceTurbolinks: true,
});

// This is how react_on_rails can see the classes in the browser.
ReactOnRails.register({
  SidebarContainer,
  RosterPickerContainer,
});