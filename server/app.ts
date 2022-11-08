import express from 'express';
const app = express();
import http from 'http';
const server = http.createServer(app);
import socket from 'socket.io';
const io = new socket.Server(server);
import path from 'path';

const history: Record<string, unknown[]> = {}

io.on('connection', (socket) => {
    socket.on('join', (room: string) => {
        socket.join(room);
        socket.emit('history', history[room] ? history[room] : []);
    });
    socket.on('message', (room: string, message: unknown) => {
        historize(room, message);
        io.in(room).emit('message', message);
    });
    socket.on('sync', (room: string, message: { recipient: string }) => {
        let channel = socket.to(room);
        if (message.recipient)
            channel = io.to(message.recipient);
        channel.emit('sync', message);
    });
});

function historize(room: string, message: unknown) {
    let roomHistory = history[room] || [];
    roomHistory.push(message);
    history[room] = roomHistory;
}

let publicDirPath = path.join(__dirname + "/../", 'public');
app.use(express.static(publicDirPath));
app.get('/', (req, res) => {
    res.sendFile(path.join(publicDirPath, "index.html"))
}).get('/mob/:mob', (req, res) => {
    res.sendFile(path.join(publicDirPath, "index.html"))
})

const port = process.env.PORT || 3000
server.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`)
});
