const app = require('express')();
const server = require('http').createServer(app);
const io = require('socket.io')(server);
var cors = require('cors');
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

app.use(cors);
app.get('/', (_, res) => res.send('This is the legacy mobtime server'));

const port = process.env.PORT || 3000;
server.listen(port, () => {
    console.log(`Live at http://0.0.0.0:${port}`);
});
