import { io } from 'socket.io-client';
import { debounce } from './debounce';
import { openInTab } from './jsonTab';

export function setup(app) {
    const socket = io();
    const history = [];

    app.ports.socketJoin.subscribe((room) => {
        debounce(
            () => {
                socket.emit('join', room);
            },
            'join',
            500
        )();
    });
    app.ports.sendEvent.subscribe((event) => {
        socket.emit('message', event.mob, event);
    });
    socket.on('message', (data) => {
        history.push(data);
        return app.ports.receiveOne.send(data);
    });
    socket.on('history', (data) => {
        history.push(...data);
        app.ports.receiveHistory.send(data);
    });

    socket.on('connect', () => app.ports.socketConnected.send(socket.id));

    socket.on('disconnect', (reason) => {
        app.ports.socketDisconnected.send(Date.now());
        if (reason === 'io server disconnect') {
            socket.connect();
        }
    });

    app.ports.displayLogs.subscribe(() => openInTab(history));

    return socket;
}
