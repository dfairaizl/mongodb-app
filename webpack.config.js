module.exports = {
  entry: {
    main: './main.js',
    // render: './src/render/render.js',
  },
  output: {
    path: './build',
    filename: '[name].js',
    libraryTarget: 'commonjs2',
  },
  module: {
    loaders: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel',
        query: {
          presets: ['react', 'es2015'],
        },
      },
      {
        test: /\.json$/,
        loader: 'file?name=[name].[ext]',
      },
    ],
  },
  resolve: {
    extensions: ['', '.js', 'json'],
  },
  stats: {
    colors: true,
  },
  node: {
    __filename: false,
    __dirname: false,
  },
  externals: [
    'app',
    'browser-window',
    'crash-reporter',
  ],
};