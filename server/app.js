const express = require('express');
const app = require('express')();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
const path = require('path');

const history = {};

io.on('connection', (socket) => {
    socket.on('join', (room) => {
        socket.join(room);
        socket.emit('history', history[room] ? history[room] : []);
    });
    socket.on('message', (room, message) => {
        historize(room, message);
        io.in(room).emit('message', message);
    });
    socket.on('sync', (room, message) => {
        let channel = socket.to(room);
        if (message.recipient) channel = io.to(message.recipient);
        channel.emit('sync', message);
    });
});

function historize(room, message) {
    let roomHistory = history[room] || [];
    roomHistory.push(message);
    history[room] = roomHistory;
}

let publicDirPath = path.join(__dirname + '/../', 'dist');
app.use(express.static(publicDirPath));
app.get('/', (_, res) => {
    res.sendFile(path.join(publicDirPath, 'index.html'));
})
    .get('/mob/:mob', (_, res) => {
        res.sendFile(path.join(publicDirPath, 'index.html'));
    })
    .get('/mob/:mob/*', (_, res) => {
        res.sendFile(path.join(publicDirPath, 'index.html'));
    })
    .get('/me', (_, res) => {
        res.sendFile(path.join(publicDirPath, 'index.html'));
    });

const port = process.env.PORT || 3000;
server.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`);
});
