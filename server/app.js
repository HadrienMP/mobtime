const express = require('express')
const path = require('path');
const app = express()
const port = 3000

app.use(express.static(path.join(path.dirname(__dirname), 'public')));
app.get('/', (req, res) => {
    res.redirect("index.html")
})

app.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`)
})

