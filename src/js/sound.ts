import {Howl, Howler} from 'howler';

export const load = (sound: string, onend = () => {}) => new Howl({
    src: [sound],
    onend: onend,
});
export const volume = (value: string) => Howler.volume(parseInt(value) / 100.0);

export const play = (sound: string) => {
    Howler.stop();
    new Howl({
        src: [sound],
        onplayerror: console.error,
    }).play();
}
