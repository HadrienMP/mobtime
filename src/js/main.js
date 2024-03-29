'use strict';
import '../sass/main.scss';
import * as tooltips from './tooltips';
import * as sockets from './sockets';
import * as alarm from './alarm';
import * as copy from './copy';
import { Elm } from '../elm/Main.elm';

const app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags: JSON.parse(window.localStorage.getItem('preferences')) || {
        volume: 30,
    },
});

copy.setup(app);
tooltips.setup();
alarm.setup(app);

if (process.env.TALK_MODE === 'p2p') {
    // The dynamic import implies that we might miss the join message
    let room = null;
    app.ports.socketJoin.subscribe((it) => {
        room = it;
    });
    // Without a dynamic import somethings breaks in server mode
    import('./p2p').then((p2p) => p2p.setup(app, room));
} else {
    const socket = sockets.setup(app);
    app.ports.commands.subscribe((command) => {
        switch (command.name) {
            case 'GetSocketId':
                // If there is no socket id, it means we are still connecting and so the event will be sent when the connection is established
                if (socket.id)
                    app.ports.events.send({
                        name: 'GotSocketId',
                        value: socket.id,
                    });
                break;
        }
    });
}

// -----------------------------------------
// Commands
// -----------------------------------------
app.ports.commands.subscribe((command) => {
    switch (command.name) {
        case 'ChangeTitle':
            document.title = command.value;
            break;
    }
});

app.ports.savePreferences.subscribe((preferences) =>
    window.localStorage.setItem('preferences', JSON.stringify(preferences))
);
