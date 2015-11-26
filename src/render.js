import {React, createElement} from 'react';
import {render} from 'react-dom';
import Root from './containers/root';
import './app.scss';

export default class App {
  constructor() {
    render(createElement(Root, {}), document.body);
  }
}

global.App = new App();
