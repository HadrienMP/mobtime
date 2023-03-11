import { Howl, Howler } from 'howler';

export const setup = (app) => {
    let alarm = load('silence.mp3');

    function load(music) {
        Howler.stop();
        return new Howl({
            src: ['/sound/' + music],
            onend: () => app.ports.alarmFinished.send(''),
            onplay: () => app.ports.alarmPlaying.send(''),
        });
    }

    app.ports.alarmLoad.subscribe((music) => {
        alarm = load(music);
    });
    app.ports.alarmPlay.subscribe(() => alarm.play());
    app.ports.alarmStop.subscribe(() => alarm.stop());
    app.ports.alarmChangeVolume.subscribe((volume) =>
        Howler.volume(volume / 100.0)
    );
    app.ports.alarmTestVolume.subscribe(() => {
        alarm = load('hello.mp3');
        alarm.play();
    });
};
