const express = require('express')
const app = require('express')();
const http = require('http').Server(app);
const io = require('socket.io')(http);
const path = require('path');


io.on('connection', (socket) => {
    console.log('a user connected');
    socket.on('join', room => {
        console.log(`Someone joined the ${room} room`);
        return socket.join(room);
    });
    socket.on('message', (room, message) => socket.to(room).emit('message', message));
    socket.on('disconnect', () => console.log('user disconnected'));
});

app.use(express.static(path.join(path.dirname(__dirname), 'public')));

app.get('*', (req, res) => {
    res.sendFile(path.join(path.dirname(__dirname), 'public', "index.html"))
})

const port = process.env.PORT | 3000

http.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`)
})

