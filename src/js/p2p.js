import * as Y from 'yjs';
import { WebrtcProvider } from 'y-webrtc';
import { IndexeddbPersistence } from 'y-indexeddb';

export const setup = (app) => {
    let currentRoom = null;
    let ydoc = null;
    let provider = null;
    let messages = null;
    let context = null;

    app.ports.socketJoin.subscribe((room) => {
        ydoc?.destroy();
        provider?.destroy();

        currentRoom = room;
        ydoc = new Y.Doc();
        messages = ydoc.getArray('messages');
        context = ydoc.getMap('context');
        provider = new WebrtcProvider('mobtime/' + room, ydoc, {
            signaling: ['wss://hadrienmp-signaling-server.onrender.com'],
        });
        const awareness = provider.awareness;

        console.log('I am', awareness.clientID);
        awareness.on('change', (changes) => {
            console.log(
                'peers',
                Array.from(awareness.getStates().keys()).filter(
                    (it) => it !== awareness.clientID
                )
            );
        });
        awareness.setLocalStateField('user', {
            name: Math.round(Math.random() * 10000),
        });
        new IndexeddbPersistence('persistence/' + room, ydoc);

        messages.observe((event) => {
            const changes = event.changes.delta
                .filter((it) => !!it.insert)
                .flatMap((it) => it.insert);
            console.log({ changes });

            if (changes.length === 1) {
                app.ports.receiveOne.send(changes[0]);
            } else {
                app.ports.receiveHistory.send(changes);
            }
        });
    });

    app.ports.sendEvent.subscribe((event) => {
        messages.push([event]);
        context.set('lastUpdate', new Date().getTime());
    });
};
