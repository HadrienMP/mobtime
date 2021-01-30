import * as sse from './sse';
import events from 'events';

const eventQueue = new events.EventEmitter();

export const init = () => eventQueue.on('send', event => sse.send(event));
export const publishFront = (name: string, data: any) => eventQueue.emit("send", {name: name, data: data});
export const publish = (name: string, data: any) => eventQueue.emit(name, data)
export const on = (event: string | symbol, listener: (...args: any[]) => void) => {
    eventQueue.on(event, listener);
};
