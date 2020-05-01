'use strict';

const CleanWebpackPlugin = require('clean-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const fs = require('fs');
const path = require('path')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const TerserJSPlugin = require('terser-webpack-plugin');
const webpack = require('webpack');

class HTMLScriptTagPlugin {
  constructor(options) {
    this.mode = options.mode,
    this.fileArray = [],
    this.fileName = options.fileName,
    this.scriptTag = '';
  }

  apply(compiler) {
    compiler.hooks.done.tap(this.constructor.name, stats => {
      return new Promise((resolve) => {
        this.scriptTag =  this.mode=='development' ? '<script src="http://localhost:3000/main.js"></script>' : '<script src="/static/main.' + stats.hash + '.js"></script>',

        fs.readFile(this.fileName, {encoding: 'utf-8'}, function(error, fileString) {
          if (error) {
            throw error;
          }
          this.fileArray = fileString.split('\n');

          /* Remove Prod script & link tags */
          this.fileArray.forEach(function(line, idx) {
            if (line.includes('<link rel="stylesheet" href="/static/main') && line.includes('.css">')) {
              this.fileArray.splice(idx, 1)
            } else if (line.includes('<script src="/static/vendors~main.') && line.includes('.js"></script>')) {
              this.fileArray.splice(idx, 1);
            }
          }.bind(this));

          /* Replace/add script tag */
          var lineReplaced = false;
          this.fileArray.forEach(function(line, idx) {
            if (
              line=='<script src="http://localhost:3000/main.js"></script>' ||
              (line.includes('<script src="/static/main') && line.includes('.js'))
            ) {
              this.fileArray[idx] = this.scriptTag;
              lineReplaced = true;
            }
          }.bind(this));
          if (!lineReplaced) {
            this.fileArray.forEach(function(line, idx) {
              if (line=='</body>') {
                this.fileArray[idx] = this.scriptTag + '\n</body>';
              }
            }.bind(this));
          }

          /* Convert this.fileArray back to string format and write result to this.fileName */
          fileString = '';
          this.fileArray.forEach(function(line) {
            fileString += line + '\n';
          });
          fileString = fileString.trim() + '\n';

          /*
            ONLY IF PROD: Replace/add stylesheet link tag
            ELSE Remove if DEV mode
          */
          if (this.mode=='production') {
            this.fileArray = fileString.split('\n');

            this.fileArray.forEach(function(line, idx) {
              if (line=='</head>') {
                this.fileArray[idx] = '<link rel="stylesheet" href="/static/main.' + stats.hash + '.css">\n</head>';
              } else if (line=='</body>') {
                this.fileArray[idx] = '<script src="/static/vendors~main.' + stats.hash + '.js"></script>\n</body>';
              }
            }.bind(this));

            fileString = '';
            this.fileArray.forEach(function(line) {
              fileString += line + '\n';
            });
            fileString = fileString.trim() + '\n';
          }
          /* End PROD case */

          fs.writeFile(this.fileName, fileString, 'utf8', error => {
            if (error) {
              throw error;
              resolve();
            }
          });
        }.bind(this));
      });
    })
  }
}


module.exports = (env, argv) => ({
  entry: {
    main: './src/js/main.js',
  },

  output: {
    filename: argv.mode=='development' ? '[name].js' : '[name].[hash].js',
    path: path.resolve(__dirname, 'dist'),
    publicPath: argv.mode=='development' ? 'http://localhost:3000/' : '/static/'
  },

  devtool: argv.mode=='development' ? 'inline-source-map' : false,

  devServer: argv.mode=='development' ? {
    compress: true,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET'
    },
    port: 3000,
  } : {},

  optimization: argv.mode=='development' ? {} : {
    minimizer: [
      new TerserJSPlugin({}),
      new OptimizeCSSAssetsPlugin({})
    ],
    splitChunks: {
      chunks: 'all'
    }
  },

  plugins: [
    new CleanWebpackPlugin(),

    new MiniCssExtractPlugin(
      {
        filename: argv.mode=='development' ? '[name].css' : '[name].[hash].css'
      }
    ),

    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      'window.jQuery': 'jquery',
      Popper: ['popper.js', 'default']
      // Add other modules to automatically load instead of `import` or `require`
    }),

    new HTMLScriptTagPlugin({mode: argv.mode, fileName: $html_file})
  ],

  module: {
    rules: [
      {
        enforce: 'pre',
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'eslint-loader',
        options: {
          emitError: true,
          emitWarning: true
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        loader: 'babel-loader',
      },

      {
        test: /\.(sa|sc|c)ss$/,
        exclude: /node_modules/,
        use: [
          {
            loader: argv.mode=='development' ? 'style-loader': MiniCssExtractPlugin.loader,
            options: {
              hmr: argv.mode=='development',
            },
          },
          'css-loader', // parses CSS into CommonJS
          {
            loader: 'postcss-loader',
            options: {
              plugins: [
                require('autoprefixer')({
                  overrideBrowserslist: [
                    'defaults',
                    'not IE 11',
                    'not IE_Mob 11',
                    'maintained node versions'
                  ]
                })
              ]
            }
          },
          'sass-loader' // Sass to CSS
        ]
      },

      {
        test: /\.(png|svg|jpg|jpeg|gif)$/,
        use: [
          {
            loader: 'file-loader' // use url-loader if loading via html
          }
        ]
      },

      {
        test: /\.(woff|woff2|eot|ttf|otf)$/,
        use: [
          'file-loader'
        ]
      }
    ]
  }
});
