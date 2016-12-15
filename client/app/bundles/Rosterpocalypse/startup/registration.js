import ReactOnRails from 'react-on-rails';
import RosterPickerContainer from '../containers/RosterPickerContainer';

ReactOnRails.setOptions({
  traceTurbolinks: true,
});

// This is how react_on_rails can see the classes in the browser.
ReactOnRails.register({
  RosterPickerContainer,
});