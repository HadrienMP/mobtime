import { io } from "socket.io-client";

type InboundMessage = {
    room: string;
    data: any;
    from: string;
};

type InboundDM = {
    to: string;
    data: any;
    from: string;
};

type OutboundDm = {
    to: string;
    data: unknown;
};

export type Subscriptions = {
    onMessage: ((message: InboundMessage) => void);
    onJoined: (message: InboundMessage) => void;
    onLeft: (message: InboundMessage) => void;
    onDirectMessage: (message: InboundDM) => void;
    onConnect: (peerId: string) => void;
    onDisconnect: () => void;
};

export const noSubscriptions: Subscriptions = {
    onMessage: _ => { },
    onJoined: _ => { },
    onLeft: _ => { },
    onDirectMessage: _ => { },
    onConnect: () => { },
    onDisconnect: () => { },
}

export class TokiNanpa {
    private socket = io("https://toki-nanpa.onrender.com");

    subscribe = (props: Subscriptions) => {
        this.socket.on('message', msg => {
            const { room, type, data, from: peer } = msg;
            switch (type) {
                case 'message':
                    if (data !== 'Hello') {
                        console.debug("#️⃣ ⬅️ message", data);
                        props.onMessage({ room, data, from: peer })
                    }
                    break;
                case 'joined':
                    console.debug("#️⃣ 👋 joined", peer);
                    props.onJoined({ room, data, from: peer })
                    break;
                case 'left':
                    console.debug("#️⃣ 👋 left", peer);
                    props.onLeft({ room, data, from: peer })
                    break;
                default:
                    console.error('unknown peer event: ' + JSON.stringify(msg))
                    break;
            }
        });
        this.socket.on('direct-message', msg => {
            const dm: InboundDM = msg;
            console.debug("#️⃣ ⬅️ DM", dm);
            props.onDirectMessage(dm);
        });

        this.socket.on('connect', () => props.onConnect(this.socket.id));
        this.socket.on('disconnect', props.onDisconnect);
    }

    broadcast = (message: { room: string, data: unknown }) => {
        console.debug("#️⃣ message ➡️", message.data);
        this.socket.emit('message', message);
    }

    directMessage = (message: OutboundDm) => {
        console.debug('DM ➡️', message);
        this.socket.emit('direct-message', message);
    }
    join = (room: string) => this.broadcast({ room, data: "Hello" });

    peerId = () => this.socket.id;
}