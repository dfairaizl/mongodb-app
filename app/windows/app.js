import {resolve} from 'path';
import {BrowserWindow, ipcMain} from 'electron';
import MongoDB from '../server/mongodb';

// App Globals
let mainWindow = null;

const APP_URL = 'file://' + __dirname + '/index.html';

export default class AppWindow {
  constructor(options) {
    const defaults = {
      width: 300,
      height: 325,
      title: 'MongoDB.app',
      resizable: false,
      fullscreen: false,
      titleBarStyle: 'hidden-inset',
      icon: resolve(__dirname, 'resources', 'MongoDB-App.png'),
    };

    const windowOptions = Object.assign({}, defaults, options);

    mainWindow = new BrowserWindow(windowOptions);

    this.registerEvents();

    this.mongodb = new MongoDB();
  }

  registerEvents() {
    // Bindings
    this.onWindowClosed = this.onWindowClosed.bind(this);
    this.onStartServer = this.onStartServer.bind(this);

    // Window Listeners
    mainWindow.on('closed', this.onWindowClosed);

    // IPC Listeners
    ipcMain.on('start-server', this.onStartServer);
  }

  loadApp() {
    mainWindow.loadURL(APP_URL);
  }

  onWindowClosed() {
    mainWindow = null;
  }

  onStartServer() {
    console.log('main - starting mongod server');
    this.mongodb.startServer();
  }
}
