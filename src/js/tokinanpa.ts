import { io, Socket } from "socket.io-client";

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
    onMessage?: ((message: InboundMessage) => void);
    onJoined?: (message: InboundMessage) => void;
    onLeft?: (message: InboundMessage) => void;
    onDirectMessage?: (message: InboundDM) => void;
};

export class TokiNanpa {
    private socket: Socket;

    constructor(props: {
        onConnect?: (peerId: string) => void;
        onDisconnect?: () => void;
    }) {
        const socket = io("https://toki-nanpa.onrender.com");
        this.socket = socket;
        this.socket.on('connect', () => {
            if (props.onConnect)
                props.onConnect(this.socket.id);
            else
                console.warn('unhandled connection event')
        });

        this.socket.on('disconnect', () => {
            if (props.onDisconnect)
                props.onDisconnect;
            else
                console.warn('unhandled disconnection event')
        });
    }

    subscribe = (subscriptions: Subscriptions) => {
        this.socket.on('message', msg => {
            const { room, type, data, from: peer } = msg;
            if (type === 'message' && subscriptions.onMessage) {
                if (data !== 'Hello') {
                    console.debug("#️⃣ ⬅️ message", data);
                    subscriptions.onMessage({ room, data, from: peer })
                }
            }
            else if (type === 'joined' && subscriptions.onJoined) {
                console.debug("#️⃣ 👋 joined", peer);
                subscriptions.onJoined({ room, data, from: peer })
            }
            else if (type === 'left' && subscriptions.onLeft) {
                console.debug("#️⃣ 👋 left", peer);
                subscriptions.onLeft({ room, data, from: peer })
            } else {
                console.error('unhandled peer event: ' + JSON.stringify(msg))
            }
        });
        this.socket.on('direct-message', msg => {
            const dm: InboundDM = msg;
            console.debug("#️⃣ ⬅️ DM", dm);
            if (subscriptions.onDirectMessage)
                subscriptions.onDirectMessage(dm);
            else
                console.warn('unhandled direct message')
        });
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