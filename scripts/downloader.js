import MongoDownloader from '../app/utils/mongo-downloader';

const version = '3.0.7';

const downloader = new MongoDownloader(version);
downloader.run().then(() => console.log('Download Complete'));
