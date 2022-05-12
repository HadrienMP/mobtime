'use strict';
import '../sass/main.scss';
import * as tooltips from "./tooltips";
import * as sockets from "./sockets";
import * as sound from "./sound";
const Elm = require('../elm/Main.elm').Elm;

const app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags: JSON.parse(window.localStorage.getItem("preferences")) || { volume: 30 }
});

tooltips.setup();

let alarm = sound.load('/sound/silence.mp3');
alarm.play();

const socket = sockets.setup(app);

// -----------------------------------------
// Commands
// -----------------------------------------
app.ports.commands.subscribe(command => {
    switch (command.name) {
        case "Join":
            socket.emit('join', command.value);
            break;
        case "SoundAlarm":
            alarm.play();
            break;
        case "SetAlarm":
            alarm = sound.load(
                "/sound/" + command.value,
                () => app.ports.events.send({ name: "AlarmEnded", value: "" }));
            break;
        case "StopAlarm":
            alarm.stop();
            break;
        case 'CopyInPasteBin':
            if (navigator.clipboard) {
                navigator.clipboard
                    .writeText(command.value)
                    .finally(() => app.ports.events.send({ name: 'Copied', value: "" }))
            } else {
                command.value.select();
                document.execCommand('copy');
                app.ports.events.send({ name: 'Copied', value: "" })
            }
            break;
        case 'ChangeVolume':
            window.localStorage.setItem("preferences", JSON.stringify({ volume: parseInt(command.value) }));
            sound.volume(command.value);
            break;
        case 'GetSocketId':
            // If there is no socket id, it means we are still connecting and so the event will be sent when the connection is established
            if (socket.id)
                app.ports.events.send({ name: "GotSocketId", value: socket.id });
            break;
        case 'TestTheSound':
            sound.play("/sound/hello.mp3");
            break;
        case 'ChangeTitle':
            document.title = command.value;
            break;
    }
});
