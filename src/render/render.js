import {React, createElement} from 'react';
import Root from './containers/root';

export default class App {
  constructor() {
    React.render(createElement(Root, {}), document.body);
  }
}
