import {io} from "socket.io-client";

export function setup(app) {
    const socket = io();
    app.ports.sendEvent.subscribe(event => {
        socket.emit('message', event.mob, event);
    });
    socket.on('message', data => {
        console.log(data);
        return app.ports.receiveOne.send(data);
    });
    socket.on('history', data => {
        app.ports.receiveHistory.send(data);
    });

    socket.on('connect', () => {
        app.ports.events.send({name: "GotSocketId", value: socket.id});
    });
    socket.on("disconnect", () => {
        app.ports.events.send({name: "SocketDisconnected", value: ""});
    });

    app.ports.clockSyncOutMessage.subscribe(message => {
        console.log("out", message);
        socket.emit("sync", message.mob, message);
    });
    socket.on("sync", data => {
        console.log("in", data);
        return app.ports.clockSyncInMessage.send(data);
    });
    return socket;
}
