var path = require('path');
var webpack = require('webpack');

module.exports = {
  // the base path which will be used to resolve entry points
  context: __dirname,

  // the main entry point for our application's frontend JS
  entry: {
    client: 'webpack-dev-server/client?http://localhost:8080',
    // bundle the client for webpack-dev-server
    // and connect to the provided endpoint

    hot: 'webpack/hot/only-dev-server',
    // bundle the client for hot reloading
    // only- means to only hot reload for successful updates

    application: './app/frontend/javascripts/entry.js'
  },

  devtool: 'cheap-module-source-map',

  plugins: [
    new webpack.LoaderOptionsPlugin({
      debug: true
    }),

    new webpack.HotModuleReplacementPlugin(),
    // enable HMR globally

    new webpack.NamedModulesPlugin(),
    // prints more readable module names in the browser console on HMR updates

    new webpack.NoEmitOnErrorsPlugin(),
    // do not emit compiled assets that include errors
  ],

  devServer: {
    host: 'localhost',
    historyApiFallback: true,
    // respond to 404s with index.html
    headers: { 'Access-Control-Allow-Origin': '*'  },

    contentBase: path.join(__dirname, 'app', 'assets', 'javascripts'),

    hot: true,
    // enable HMR on the server
  },

  output:  {
    // this is our app/assets/javascripts directory, which is part of the Sprockets pipeline
    path: path.join(__dirname, 'app', 'assets', 'javascripts'),
    // the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js
    filename: '[name].js',
    sourceMapFilename: "[file].map",
    // if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles
    publicPath: 'http://localhost:8080/assets/javascripts',
  },

  module: {
    loaders: [
      {
        test: /.jsx?$/,
        loader: 'babel-loader',
        exclude: /node_modules/,
        query: {
          presets: ['es2015', 'react'],
        }
      }
    ]
  },

};

