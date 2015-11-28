// Webpack
import '../../resources/defaults.json';

import {readFileSync, writeFileSync} from 'fs';
import {sync as mkdirp} from 'mkdirp';
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
}
