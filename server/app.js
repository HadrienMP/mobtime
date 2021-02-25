const express = require('express')
const path = require('path');
const app = express()
const port = process.env.PORT | 3000

app.use(express.static(path.join(path.dirname(__dirname), 'public')));

app.get('*', (req, res) => {
    res.sendFile(path.join(path.dirname(__dirname), 'public', "index.html"))
})

const https = require('https');
https.createServer(require('https-local').options(), app).listen(3000, () => {
    console.log(`Live at https://0.0.0.0:${port}`)
})

