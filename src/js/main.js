'use strict';
import '../sass/main.scss';
import * as tooltips from './tooltips';
import * as sockets from './sockets';
import * as p2p from './p2p';
import * as sound from './sound';
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

let alarm = sound.load('/sound/silence.mp3');
alarm.play();

const talkMode = process.env.TALK_MODE;
if (talkMode === 'p2p') {
    p2p.setup(app);
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
        case 'SoundAlarm':
            alarm.play();
            break;
        case 'SetAlarm':
            alarm = sound.load('/sound/' + command.value, () =>
                app.ports.events.send({ name: 'AlarmEnded', value: '' })
            );
            break;
        case 'StopAlarm':
            alarm.stop();
            break;
        case 'ChangeVolume':
            window.localStorage.setItem(
                'preferences',
                JSON.stringify({ volume: parseInt(command.value) })
            );
            sound.volume(command.value);
            break;
        case 'ChangeTitle':
            document.title = command.value;
            break;
    }
});

app.ports.savePreferences.subscribe((preferences) =>
    window.localStorage.setItem('preferences', JSON.stringify(preferences))
);

app.ports.changeVolume.subscribe(sound.volume);
app.ports.testVolume.subscribe(() => sound.play('/sound/hello.mp3'));
testSound();
const soundOnInterval = setInterval(testSound(), 100);

function testSound() {
    return sound.play('/sound/silence.mp3', {
        onError: console.debug,
        onSuccess: () => {
            app.ports.soundOn.send('');
            clearInterval(soundOnInterval);
        },
    });
}
