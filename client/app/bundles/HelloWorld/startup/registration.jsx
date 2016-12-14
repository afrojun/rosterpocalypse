import ReactOnRails from 'react-on-rails';

import HelloWorld from '../components/HelloWorld';
import RosterPicker from '../components/RosterPicker';

// This is how react_on_rails can see the classes in the browser.
ReactOnRails.register({
  HelloWorld,
  RosterPicker,
});
