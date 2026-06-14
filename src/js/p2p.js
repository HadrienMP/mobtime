import * as Y from 'yjs';
import { openInTab } from './jsonTab';
import { WebsocketProvider } from 'y-websocket';

export const setup = (app, room) => {
    let currentRoom = null;
    let ydoc = null;
    let provider = null;
    let messages = null;
    let context = null;

    const join = (room) => {
        ydoc?.destroy();
        provider?.destroy();

        currentRoom = room;
        ydoc = new Y.Doc();
        messages = ydoc.getArray('messages');
        context = ydoc.getMap('context');
        provider = new WebsocketProvider(
            'wss://y-websocket-server-axbe.onrender.com',
            `mobtime-${room}`,
            ydoc,
        );
        provider.on('status', (event) => {
            app.ports.socketStatusChange.send(event.status);
        });
        messages.observe((event) => {
            const changes = event.changes.delta
                .filter((it) => !!it.insert)
                .flatMap((it) => it.insert);

            if (changes.length === 1) {
                app.ports.receiveOne.send(changes[0]);
            } else {
                app.ports.receiveHistory.send(changes);
            }
        });
    };
    if (room) join(room);
    app.ports.socketJoin.subscribe(join);

    app.ports.sendEvent.subscribe((event) => {
        messages.push([event]);
        context.set('lastUpdate', new Date().getTime());
    });

    app.ports.displayLogs.subscribe(() => openInTab(messages));
};
