import {Howl, Howler} from 'howler';

export const load = (sound, onend = () => {}) => new Howl({
    src: [sound],
    onend: onend,
});
export const volume = (value) => Howler.volume(parseInt(value) / 100.0);

export const play = (sound) => {
    Howler.stop();
    new Howl({
        src: [sound],
        onplayerror: console.error,
    }).play();
}
