// Webpack
import '../../resources/defaults.json';

import {mkdirp, readFileSync, writeFileSync} from 'fs.extra';
import {spawn} from 'child_process';
import {resolve, join} from 'path';
import {app} from 'electron';

function defaultDatabaseDirectory() {
  const dbDir = join(app.getPath('userData'), 'db');
  mkdirp(dbDir);

  return dbDir;
}

function defaultLogDirectory() {
  const logDir = join(app.getPath('userData'), 'log');
  mkdirp(logDir);

  return join(logDir, 'mongodb.log');
}

export default class MongoDB {
  constructor() {
    this.loadSettings();
  }

  loadSettings() {
    const defaultsPath = resolve(app.getAppPath(), 'defaults.json');
    const settingsPath = resolve(app.getPath('userData'), 'settings.json');
    let defaultSettings;
    let userSettings;

    try {
      defaultSettings = JSON.parse(readFileSync(defaultsPath));
    } catch (e) {
      defaultSettings = {}; // Probably incorrect...
    }

    try {
      const data = readFileSync(settingsPath, 'utf8');
      userSettings = JSON.parse(data);
    } catch (e) {
      userSettings = Object.assign({}, defaultSettings);
    }

    // Runtime settings
    userSettings.databasePath = defaultDatabaseDirectory();
    userSettings.logPath = defaultLogDirectory();

    writeFileSync(settingsPath, JSON.stringify(userSettings));

    this.settings = userSettings;
  }

  startServer() {
    this.spawnProcess(this.settings.databasePath, this.settings.logPath);
  }

  stopServer() {
    this.haltProcess();
  }

  spawnProcess(databasePath, logPath) {
    // lockfile check
    const mongod = this.mongodPath();

    const args = [
      `--dbpath=${databasePath}`,
      `--logpath=${logPath}`,
      `--port=${this.settings.port}`,
      `--storageEngine=${this.settings.currentStorageEngine}`,
      `--logappend`,
    ];

    this.process = spawn(mongod, args);

    // Register child process events
    this.process.stdout.on('data', this.onMongodOutput);
    this.process.stderr.on('data', this.onMongodError);
    this.process.on('close', this.onMongodExit);
  }

  haltProcess() {
    this.process.kill();
  }

  onMongodOutput(data) {
    console.log('stdout: ' + data);
  }

  onMongodError(data) {
    console.log('stdout: ' + data);
  }

  onMongodExit(code) {
    console.log('mongod exited with code ' + code);
  }

  mongodPath() {
    const binPath = resolve(app.getAppPath(), 'bin');
    return join(binPath, 'mongod');
  }
}
