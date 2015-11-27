import React from 'react';
import {render} from 'react-dom';
import App from './containers/App';
import {Provider} from 'react-redux';
import configureStore from './store/configureStore';
import './app.scss';

const store = configureStore();

export default class MongoDBApp {
  constructor() {
    render(
      <Provider store={store}>
        <App />
      </Provider>,
      document.getElementById('root')
    );
  }
}

global.MongoDBRenderer = new MongoDBApp();
