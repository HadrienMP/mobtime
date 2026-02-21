import { Howl, Howler } from 'howler';

export const setup = (app) => {
    let alarm = load('/sound/silence.mp3');
    const silence = load('/sound/silence.mp3');

    function load(music) {
        Howler.stop();
        return new Howl({
            src: [music],
            onend: () => app.ports.alarmFinished.send(''),
            onplay: () => app.ports.alarmPlaying.send(''),
        });
    }

    app.ports.checkSound.subscribe(() => silence.play());

    app.ports.alarmLoad.subscribe((music) => {
        alarm = load(music);
    });
    app.ports.alarmPlay.subscribe(() => alarm.play());
    app.ports.alarmStop.subscribe(() => alarm.stop());
    app.ports.alarmChangeVolume.subscribe((volume) =>
        Howler.volume(volume / 100.0)
    );
    app.ports.alarmTestVolume.subscribe(() => load('/sound/hello.mp3').play());
};
