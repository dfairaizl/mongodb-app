module.exports = {
  entry: {
    main: './main.js',
    render: './renderer.js',
  },
  output: {
    path: './dist',
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
          presets: ['react', 'es2015', 'stage-2'],
        },
      },
      {
        test: /\.json$/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.html$/,
        loader: 'file?name=[name].[ext]',
      },
      {
        test: /\.png$/,
        loader: 'file?name=resources/[name].[ext]',
      },
      {
        test: /\.scss$/,
        loaders: ['style', 'css', 'sass'],
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
    'child_process',
    'fs',
    'graceful-fs',
    'app',
    'browser-window',
    'crash-reporter',
    'electron',
  ],
};
