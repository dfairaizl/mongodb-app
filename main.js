import './package.json';
import './src/static/index.html';
import './src/resources/MongoDB-App.png';
import './src/resources/MongoDB-App@2x.png';

import {resolve} from 'path';

// Electron
import {app, BrowserWindow, crashReporter, ipcMain} from 'electron';

crashReporter.start();

// Electron Globals
let mainWindow = null;

// App Globals
const APP_URL = 'file://' + __dirname + '/index.html';

export default class MongoDB {
  constructor() {
    this.onReady = this.onReady.bind(this);
    this.onWindowAllClosed = this.onWindowAllClosed.bind(this);
    this.onStartServer = this.onStartServer.bind(this);

    // register electron listeners
    app.on('ready', this.onReady);
    app.on('window-all-closed', this.onWindowAllClosed);

    ipcMain.on('start-server', this.onStartServer);
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

  onStartServer(event, arg) {
    console.log('main - starting mongod server');
  }
}

global.MongoDBMain = new MongoDB();
