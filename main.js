import './package.json';
import './src/static/index.html';
import './src/resources/MongoDB-App.png';
import './src/resources/MongoDB-App@2x.png';

import {resolve} from 'path';

// Electron
import app from 'app';
import BrowserWindow from 'browser-window';
import crashReporter from 'crash-reporter';

crashReporter.start();

// Electron Globals
let mainWindow = null;

// App Globals
const APP_URL = 'file://' + __dirname + '/index.html';

export default class MongoDB {
  constructor() {
    this.onReady = this.onReady.bind(this);
    this.onWindowAllClosed = this.onWindowAllClosed.bind(this);

    // register electron listeners
    app.on('ready', this.onReady);
    app.on('window-all-closed', this.onWindowAllClosed);
  }

  onReady() {
    const opts = {
      width: 300,
      height: 325,
      title: 'MongoDB.app',
      resizable: false,
      fullscreen: false,
      titleBarStyle: 'hidden-inset',
      icon: resolve(__dirname, 'resources', 'MongoDB-App.png'),
    };

    mainWindow = new BrowserWindow(opts);
    mainWindow.loadURL(APP_URL);

    mainWindow.webContents.openDevTools();

    mainWindow.on('closed', () => {
      mainWindow = null;
    });
  }

  onWindowAllClosed() {
    if (process.platform !== 'darwin') {
      app.quit();
    }
  }
}

global.MongoDB = new MongoDB();
