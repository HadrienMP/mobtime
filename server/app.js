const express = require('express')
const app = require('express')();
// const http = require('http').Server(app);
// const io = require('socket.io')(http);
const path = require('path');
const fs = require('fs');

const history = {}

// io.on('connection', (socket) => {
//     socket.on('join', room => {
//         socket.join(room);
//         socket.emit('history', history[room] ? history[room] : []);
//     });
//     socket.on('message', (room, message) => {
//         historize(room, message);
//         io.in(room).emit('message', message);
//     });
//     socket.on('disconnect', () => console.log('user disconnected'));
// });

function historize(room, message) {
    let roomHistory = history[room] || [];
    roomHistory.push(message);
    history[room] = roomHistory;
}

const port = process.env.PORT || 3000

let publicDirPath = path.join(__dirname + "/../", 'public');
console.log(publicDirPath);
console.log(path.join(path.dirname(__dirname), 'public'));
ls(publicDirPath);
app.use(express.static(publicDirPath))
    .get('*', (req, res) => {
        res.sendFile(path.join(path.dirname(__dirname), 'public', "index.html"))
    })
    .listen(port, () => {
        console.log(`Live at http://0.0.0.0:${port}`)
    });

function ls(dir) {
    // list all files in the directory
    try {
        const files = fs.readdirSync(dir);

        // files object contains all files names
        // log them on console
        files.forEach(file => {
            console.log(file);
        });

    } catch (err) {
        console.log(err);
    }
}

