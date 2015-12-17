module.exports = {
    entry: "./web/js/main.js",
    output: {
        path: "./priv/static/js",
        filename: "bundle.js"
    },
    module: {
        loaders: [
            {
                test: /\.js?$/,
                exclude: /(node_modules|bower_components)/,
                loader: 'babel?optional[]=runtime&optional[]=es7.decorators'
            },
            {
                test: /\.js?$/,
                loader: 'exports-loader'
            },
            {
                test: /\.scss$/,
                loaders: ["style", "css", "scss"]
            }
        ]
    },
    devtool: "#cheap-module-eval-source-map"
};
