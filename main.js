// Webpack
import './package.json';
import './resources/index.html';
import './resources/MongoDB-App.png';
import './resources/MongoDB-App@2x.png';

// Electron
import {app, crashReporter} from 'electron';

// App
import AppWindow from './app/windows/app';

crashReporter.start();

export default class MongoDBApp {
  constructor() {
    this.onReady = this.onReady.bind(this);
    this.onWindowAllClosed = this.onWindowAllClosed.bind(this);

    // register app listeners
    app.on('ready', this.onReady);
    app.on('window-all-closed', this.onWindowAllClosed);
  }

  onReady() {
    this.appWindow = new AppWindow();
    this.appWindow.loadApp();
  }

  onWindowAllClosed() {
    if (process.platform !== 'darwin') {
      app.quit();
    }
  }
}

global.MongoDBApp = new MongoDBApp();
