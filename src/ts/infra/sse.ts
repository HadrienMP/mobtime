import {Request, Response} from "express";
import * as bus from "./bus";

let clients: Client[] = [];

class Client {
    id: string;
    response: Response
    constructor(id: string, response: Response) {
        this.id = id;
        this.response = response;
    }
}

export function init(req: Request, res: Response) {
    const headers = {
        'Content-Type': 'text/event-stream',
        'Connection': 'keep-alive',
        'Cache-Control': 'no-cache'
    };
    res.writeHead(200, headers);

    setInterval(() => res.write("event: ping\ndata: stay alive\n\n"), 10000);

    const newClient = new Client("a", res);
    clients.push(newClient);

    req.on('close', () => {
        console.log(`Sse client left: ${newClient.id}`);
        clients = clients.filter(c => c.id !== newClient.id);
        bus.publish("citizenLeft", newClient.id);
    });
}

export function send(data: any, event: string = "") {
    let eventSse = event ? `event: ${event}\n` : ``;
    let chunk = `${eventSse}data: ${JSON.stringify(data)}\n\n`;
    console.log(`SSE -> ${chunk.replace(/\n/g, "")}`);
    clients.forEach(client => client.response.write(chunk));
}