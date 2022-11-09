import { TokiNanpa } from './tokinanpa';
import { RommHistories } from './history';


export function setup(app: { ports: any }): TokiNanpa {
    const history = new RommHistories();
    const tokiNanpa = new TokiNanpa({
        onConnect: peerId => app.ports.events.send({ name: "GotSocketId", value: peerId }),
        onDisconnect: () => app.ports.events.send({ name: "SocketDisconnected", value: "" }),
    });
    tokiNanpa.subscribe({
        onMessage: msg => {
            const { type, value } = msg.data;
            if (type === 'sync') {
                app.ports.clockSyncInMessage.send(value)
            }
            else {
                history.add(msg.room, msg.data);
                app.ports.receiveOne.send(msg.data);
            }
        },
        onJoined: ({ from, room }) => {
            if (from !== tokiNanpa.peerId()) {
                const toSend = history.of(room).events();
                console.log(`📜➡️ send history`, toSend)
                tokiNanpa.directMessage({
                    to: from, data: {
                        type: 'history',
                        value: {
                            room,
                            history: toSend
                        }
                    }
                });
            }
        },
        onDirectMessage: msg => {
            const { type, value } = msg.data;
            if (type === 'history') {
                history.elect(
                    value.room,
                    value.history,
                    elected => app.ports.receiveHistory.send(elected.events())
                );
            }
        }
    });

    app.ports.sendEvent.subscribe((event: { mob: string }) => {
        tokiNanpa.broadcast({ room: event.mob, data: event });
    });

    app.ports.clockSyncOutMessage.subscribe((message: { mob: string }) => {
        tokiNanpa.broadcast({ room: message.mob, data: { type: 'sync', value: message } });
    });

    return tokiNanpa;
}