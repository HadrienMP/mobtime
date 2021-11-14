module.exports = {
    entry: './src/js/pure.js',
    output: {
        filename: "bundle.js",
        path: __dirname + '/public/js',
    },
    module: {
        rules: [
            {
                test: /\.elm$/,
                exclude: [/elm-stuff/, /node_modules/],
                use: {
                    loader: 'elm-webpack-loader',
                    options: {}
                }
            },
            {
                test: /\.s[ac]ss$/i,
                use: [
                    "style-loader",
                    "css-loader",
                    "sass-loader",
                ],
            },
            {
                test: /\.css$/,
                use: ['style-loader', 'css-loader']
            }
        ]
    }
};
