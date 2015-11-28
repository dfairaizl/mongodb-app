// Need to consider platform differences for OSX/Windows/Linux

import {
  createReadStream,
  createWriteStream,
  rmrf,
  mkdirp,
  move as mv,
} from 'fs.extra';
import {createGunzip} from 'zlib';
import {resolve, join} from 'path';
import {Extract as extractTar} from 'tar';
import {each, waterfall} from 'async';
import request from 'request';

function download(callback) {
  const downloadFile = `mongodb-osx-x86_64-${this.version}`;
  const downloadURL = `https://fastdl.mongodb.org/osx/${downloadFile}.tgz`;
  const downloadPath = resolve(__dirname, '..', '..', 'dist', 'tmp');
  const downloadLocation = join(downloadPath, downloadFile) + '.tar';

  mkdirp(downloadPath);

  console.log('downloading ', downloadURL, ' to ', downloadLocation);

  request(downloadURL)
    .pipe(createGunzip())
    .pipe(createWriteStream(downloadLocation))
    .on('close', () => {
      callback(null, downloadLocation, downloadFile);
    })
    .on('error', (err) => {
      callback(err);
    });
}

function extract(archiveFile, filename, callback) {
  console.log('extracting', archiveFile);

  const tarStream = createReadStream(archiveFile);
  const extractPath = resolve(__dirname, '..', '..', 'dist', 'tmp');
  const extractor = extractTar({ path: extractPath })
    .on('error', (err) => callback(err))
    .on('end', () => callback(null, extractPath, filename));

  tarStream
    .on('error', (err) => callback(err))
    .pipe(extractor);
}

function move(filesPath, fileName, callback) {
  // Only move the minimum necessary files so our app stays lean
  const mongoFiles = ['mongod', 'mongo'];
  const sourceFilesPath = resolve(filesPath, fileName, 'bin');
  const destFilesPath = resolve(__dirname, '..', '..', 'dist', 'bin');

  console.log('moving', sourceFilesPath);

  mkdirp(destFilesPath);

  each(mongoFiles, (file, fileCallback) => {
    const source = join(sourceFilesPath, file);
    const dest = join(destFilesPath, file);
    mv(source, dest, (err) => {
      if (err) {
        fileCallback(err);
      } else {
        fileCallback();
      }
    });
  }, (err) => {
    if (err) {
      console.log(err);
    } else {
      callback(null, filesPath);
    }
  });
}

function cleanup(tmpPath, callback) {
  console.log('Cleaning up', tmpPath);
  rmrf(tmpPath, () => callback(null));
}

export default class MongoDownloader {
  constructor(version = '') {
    this.version = version;
  }

  run() {
    const steps = [
      download.bind(this),
      extract.bind(this),
      move.bind(this),
      cleanup.bind(this),
    ];

    return new Promise((resolvep, rejectp) => {
      waterfall(steps, (err, result) => {
        if (err) {
          rejectp(err);
        } else {
          resolvep(result);
        }
      });
    });
  }
}
