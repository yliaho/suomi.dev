const path = require("path");
const glob = require("glob");
const HardSourceWebpackPlugin = require("hard-source-webpack-plugin");
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const TerserPlugin = require("terser-webpack-plugin");
const OptimizeCSSAssetsPlugin = require("optimize-css-assets-webpack-plugin");
const CopyWebpackPlugin = require("copy-webpack-plugin");
const PurgecssPlugin = require("purgecss-webpack-plugin");
const globAll = require("glob-all");

// Custom PurgeCSS extractor for Tailwind that allows special characters in
// class names.
// Regex explanation: https://tailwindcss.com/docs/controlling-file-size/#understanding-the-regex
const TailwindExtractor = (content) => {
  return content.match(/[\w-/:]+(?<!:)/g) || [];
};

module.exports = (env, options) => {
  const devMode = options.mode !== "production";

  return {
    optimization: {
      minimizer: [
        new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
        new OptimizeCSSAssetsPlugin({}),
        new PurgecssPlugin({
          whitelist: ["input", "upvote-btn", "upvote-btn[data-liked]", "&::placeholder", "i-am-a-fucking-input-purge-css", "i-am-a-fucking-select-purge-css", "liked"],
          paths: globAll.sync([
            '../lib/suomidev_web/templates/**/*.html.eex',
            '../lib/suomidev_web/views/**/*.ex',
            "../assets/js/**/*.js",
          ]),
          extractors: [
            {
              extractor: TailwindExtractor,
              extensions: ["html", "js", "eex", "ex"],
            },
          ],
        }),
      ],
    },
    entry: {
      app: glob.sync("./vendor/**/*.js").concat(["./js/app.js"])
    },
    output: {
      filename: "[name].js",
      path: path.resolve(__dirname, "../priv/static/js"),
      publicPath: "/js/",
    },
    devtool: devMode ? "eval-cheap-module-source-map" : undefined,
    module: {
      rules: [
        {
          test: /\.js$/,
          exclude: /node_modules/,
          use: {
            loader: "babel-loader",
          },
        },
        // {
        //   test: /\.[s]?css$/,
        //   use: [
        //     MiniCssExtractPlugin.loader,
        //     'css-loader',
        //     'sass-loader',
        //   ],
        // }
        {
          test: /\.css$/,
          use: [
            MiniCssExtractPlugin.loader,
            "css-loader",
            "postcss-loader",
            // 'style-loader',
            // { loader: 'css-loader', options: { importLoaders: 1 } },
            // { loader: 'postcss-loader' }
          ],
        },
      ],
    },
    plugins: [
      new MiniCssExtractPlugin({ filename: "../css/app.css" }),
      new CopyWebpackPlugin([{ from: "static/", to: "../" }]),
    ].concat(devMode ? [new HardSourceWebpackPlugin()] : []),
  };
};
