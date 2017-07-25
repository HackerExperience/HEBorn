var path              = require( 'path' );
var webpack           = require( 'webpack' );
var merge             = require( 'webpack-merge' );
var HtmlWebpackPlugin = require( 'html-webpack-plugin' );
var autoprefixer      = require( 'autoprefixer' );
var ExtractTextPlugin = require( 'extract-text-webpack-plugin' );
var CopyWebpackPlugin = require( 'copy-webpack-plugin' );
var entryPath         = path.join( __dirname, 'static/js/index.js' );
var outputPath        = path.join( __dirname, 'build' );

console.log( 'WEBPACK GO!');

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';
var outputFilename = TARGET_ENV === 'production' ? '[name]-[hash].js' : '[name]-dev.js';

// common webpack config
var commonConfig = {

  entry: {
    'app': entryPath
  },

  output: {
    path:       outputPath,
    filename: `js/${outputFilename}`
    // publicPath: '/'
  },

  resolve: {
    extensions: ['', '.js', '.elm', '.css', '.png', '.jpg'],
    alias: {
        leaflet_css: __dirname + "/node_modules/leaflet/dist/leaflet.css",
        leaflet_js: __dirname + "/node_modules/leaflet/dist/leaflet.js"
    }
  },
  module: {
    noParse: /\.elm$/,
    loaders: [
      {
        test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url-loader?limit=10000&mimetype=application/font-woff&publicPath=../&name=fonts/[name].[ext]"
      },
      {
        test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url-loader?limit=10000&mimetype=application/font-woff&publicPath=../&name=fonts/[name].[ext]"
      },
      {
        test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url-loader?limit=10000&mimetype=application/octet-stream&publicPath=../&name=fonts/[name].[ext]"
      },
      {
        test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
        loader: "file?publicPath=../&name=fonts/[name].[ext]"
      },
      {
        test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
        loader: "url-loader?limit=10000&mimetype=image/svg+xml&publicPath=../&name=files/[name].[ext]"
      },
      {
        test: /\.(png|jpg)$/,
        loader: "file-loader?name=images/[name].[ext]"
      },
      {
        test: /\.(css|scss)$/,
        loader: ExtractTextPlugin.extract( 'style-loader', [
          'css-loader',
          'postcss-loader',
        ])
      }
    ]
  },

  plugins: [
    new HtmlWebpackPlugin({
      template: 'build/index.html',
      inject:   'body',
      filename: 'index.html'
    }),
    new webpack.EnvironmentPlugin(
      ["HEBORN_API_HTTP_URL", "HEBORN_API_WEBSOCKET_URL", "HEBORN_VERSION"]
    )
  ],

  postcss: [ autoprefixer( { browsers: ['last 2 versions'] } ) ]

};

// additional webpack settings for local env (when invoked by 'npm start')
if ( TARGET_ENV === 'development' ) {
  console.log( 'Serving locally...');

  module.exports = merge( commonConfig, {

    devServer: {
      historyApiFallback: true,
      contentBase: './build'
    },

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader:  'elm-hot!elm-webpack?verbose=true&warn=true&debug=true'
        }
      ]
    },

    plugins: [
      new ExtractTextPlugin( 'css/[name]-dev.css', { allChunks: true } )
    ]

  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if ( TARGET_ENV === 'production' ) {
  console.log( 'Building for prod...');

  module.exports = merge( commonConfig, {

    module: {
      loaders: [
        {
          test:    /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader:  'elm-webpack'
        }
      ]
    },

    plugins: [
      new CopyWebpackPlugin([
        {
          from: 'static/img/',
          to:   'img/'
        },
        {
          from: 'static/favicon.ico',
          to: 'favicon.ico'
        },
      ]),

      new webpack.optimize.OccurenceOrderPlugin(),

      new ExtractTextPlugin( 'css/[name]-[hash].css', { allChunks: true } ),

      new webpack.optimize.UglifyJsPlugin({
          minimize:   true,
          compressor: { warnings: false }
      })
    ]

  });
}
