import {resolve} from 'path';
import gulp from 'gulp';
import gutil from 'gulp-util';
import runElectron from 'gulp-run-electron';
import webpack from 'webpack';

gulp.task('default', () => {
  gulp.src('./app')
      .pipe(runElectron());
});

gulp.task('build', ['copy:package', 'copy:static', 'bundle']);

gulp.task('copy:package', () => {
  gulp.src([
    './package.json',
  ], {
    base: '.',
  })
  .pipe(gulp.dest('./app'));
});

gulp.task('copy:static', () => {
  gulp.src([
    './src/static/index.html',
  ], {
    base: './src/static',
  })
  .pipe(gulp.dest('./app'));
});

gulp.task('bundle', (done) => {
  webpack({
    entry: {
      main: './src/main/main.js',
      render: './src/render/render.js',
    },
    output: {
      path: './app/scripts',
      filename: '[name].js',
    },
    module: {
      loaders: [
        {
          test: /\.js$/,
          loader: 'babel-loader',
          include: [
            resolve(__dirname, 'src'),
          ],
          exclude: /(node_modules|bower_components)/,
          query: {
            presets: ['es2015', 'react'],
          },
        },
      ],
    },
    resolve: {
      extensions: ['', '.js'],
    },
    externals: [
      (() => {
        const IGNORE = [
          // Electron
          'crash-reporter',
          'app',
          'browser-window',
        ];
        return (context, request, callback) => {
          if (IGNORE.indexOf(request) >= 0) {
            return callback(null, `require('${request}')`);
          }
          return callback();
        };
      })(),
    ],
  }, (err, stats) => {
    if (err) {
      throw new gutil.PluginError('webpack', err);
    }

    gutil.log('[webpack]', stats.toString({
      chunkModules: false,
    }));

    done();
  });
});
