import './package.json';

// Electron
import app from 'app';
import BrowserWindow from 'browser-window';
import crashReporter from 'crash-reporter';

crashReporter.start();

// Electron Globals
let mainWindow = null;

// App Globals
const APP_URL = 'file://' + __dirname + '/app/index.html';

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
      width: 400,
      height: 400,
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
