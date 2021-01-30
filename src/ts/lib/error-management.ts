import {Response} from "express";
import exp from "constants";

export function send(res: Response, error: JsonError) {
    res.status(error.status).json(error).end();
}

export class JsonError {
    readonly status: number;
    readonly reason: string;

    constructor(status: number, reason: string) {
        this.status = status;
        this.reason = reason;
    }
}

export enum ErrorType {
    User,
    Dev
}

export class ImprovedError {
    readonly type: ErrorType;
    readonly msg: ErrorMsg;

    constructor(type: ErrorType, msg: ErrorMsg) {
        this.type = type;
        this.msg = msg;
    }
}

export function userError(msg: string) {
    return new ImprovedError(ErrorType.User, msg);
}

export type ErrorMsg = string;



export function handle(error: ImprovedError, res: Response) {
    switch (error.type) {
        case ErrorType.Dev:
            console.error(error.msg)
            send(res, devError());
            break;
        case ErrorType.User:
            send(res, clientError(error.msg));
            break;
    }
}

export const clientError = (error: ErrorMsg) => new JsonError(400, error);
export function devError(): JsonError {
    return new JsonError(500, "Sorry something wrong happened on the server, the dev team has been notified and will work on fixing the issue.");
}