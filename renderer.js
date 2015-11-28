import React from 'react';
import {render} from 'react-dom';
import App from './app/containers/App';
import {Provider} from 'react-redux';
import configureStore from './app/store/configureStore';

const initialState = {
  server: {
    status: 'stopped',
    databasePath: '/',
    logPath: '/',
    port: '27017',
    storageEngine: 'wiredTiger',
  },
};

const store = configureStore(initialState);

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
