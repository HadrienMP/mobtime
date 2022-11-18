import { io } from "socket.io-client";

export function setup(app) {
    const socket = io();

    app.ports.socketJoin.subscribe(room => {
        socket.emit('join', room);
    })
    app.ports.sendEvent.subscribe(event => {
        socket.emit('message', event.mob, event);
    });
    socket.on('message', data => {
        return app.ports.receiveOne.send(data);
    });
    socket.on('history', data => {
        app.ports.receiveHistory.send(data);
    });

    socket.on('connect', () => app.ports.socketConnected.send(socket.id));

    socket.on("disconnect", (reason) => {
        app.ports.socketDisconnected.send(Date.now());
        if (reason === "io server disconnect") {
            socket.connect();
        }
    });

    app.ports.clockSyncOutMessage.subscribe(message => {
        socket.emit("sync", message.mob, message);
    });
    socket.on("sync", data => {
        return app.ports.clockSyncInMessage.send(data);
    });
    return socket;
}
