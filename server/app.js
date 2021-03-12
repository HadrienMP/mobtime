const express = require('express')
const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);
const path = require('path');
const Elm = require('./elm-server').Elm;

const elmApp = Elm.Server.init();
const history = {}

io.on('connection', (socket) => {
    socket.on('join', room => {
        socket.join(room);
        socket.emit('history', history[room] ? history[room] : []);
    });
    socket.on('message', (room, message) => {
        historize(room, message);
        io.in(room).emit('message', message);
    });
    socket.on('disconnect', () => console.log('user disconnected'));
});

function historize(room, message) {
    let roomHistory = history[room] || [];
    roomHistory.push(message);
    history[room] = roomHistory;
}

app.use(express.static(path.join(path.dirname(__dirname), 'public')));

app.get('*', (req, res) => {
    res.sendFile(path.join(path.dirname(__dirname), 'public', "index.html"))
})

const port = process.env.PORT | 3000

http.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`)
})

