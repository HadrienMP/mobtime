import { Howl, Howler } from 'howler';

export const load = (sound, onend = () => { }) => {
    Howler.stop();
    return new Howl({
        src: [sound],
        onend: onend,
    });
};
export const volume = (value) => Howler.volume(parseInt(value) / 100.0);

export const play = (sound, eventHandlers = { onError: console.error, onSuccess: () => { } }) => {
    Howler.stop();
    new Howl({
        src: [sound],
        onplayerror: eventHandlers.onError,
        onplay: () => eventHandlers.onSuccess()
    }).play();
}
