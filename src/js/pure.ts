'use strict';
import '../sass/main.scss';
import * as tooltips from "./tooltips";
import * as p2p from "./p2p";
import * as sound from "./sound";
const Elm = require('../elm/Main.elm').Elm;

const rawPreferences = window.localStorage.getItem("preferences");
const app = Elm.Main.init({
    node: document.getElementById('elm'),
    flags: rawPreferences ? JSON.parse(rawPreferences) : { volume: 30 }
});

tooltips.setup();

let alarm = sound.load('/sound/silence.mp3');
alarm.play();

const tokiNanpa = p2p.setup(app);

// -----------------------------------------
// Commands
// -----------------------------------------
app.ports.commands.subscribe((command: { name: string, value: any }) => {
    switch (command.name) {
        case "Join":
            tokiNanpa.join(command.value);
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
                if (fallbackCopyTextToClipboard(command.value))
                    app.ports.events.send({ name: 'Copied', value: "" });
                else {
                    alert('wut')
                }
            }
            break;
        case 'ChangeVolume':
            window.localStorage.setItem("preferences", JSON.stringify({ volume: parseInt(command.value) }));
            sound.volume(command.value);
            break;
        case 'TestTheSound':
            sound.play("/sound/hello.mp3");
            break;
        case 'ChangeTitle':
            document.title = command.value;
            break;
    }
});

function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        return document.execCommand('copy');
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
        return false;
    } finally {
        document.body.removeChild(textArea);
    }
}