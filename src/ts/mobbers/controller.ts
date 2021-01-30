import express, {Request, Response} from "express";
import * as bus from "../infra/bus";
import * as store from "../store";
import {Mob, Mobber} from "../model";
import {handle} from "../lib/error-management";
import {deleteMobber, MobCommand} from "./domain";

export const router = express.Router({strict: true});

export const add = (req: Request, res: Response) => {
    let mobName = req.params.mob;
    let mobber = parseMobber(req);

    store.getMob(mobName)
        .map(mob => mob.addMobber(mobber))
        .onSuccess(mob => {
            store.update(mobName, mob);
            bus.publishFront("mobberAdded", mobberEvent(mob, mobber));
            res.status(201).end();
        })
        .onError(error => handle(error, res))

};

export const update = (req: Request, res: Response) => {
    let mobName = req.params.mob;
    let mobber = parseMobber(req);

    store.getMob(mobName)
        .map(mob => mob.updateMobber(mobber))
        .onSuccess(mob => {
            store.update(mobName, mob);
            bus.publishFront("mobberUpdated", mobberEvent(mob, mobber));
            res.status(200).end();
        })
        .onError(error => handle(error, res))
};

export const leave = (req: Request, res: Response) => {
    let mobName = req.params.mob;
    let id = req.params.id;

    store.getMob(mobName)
        .map(mob => deleteMobber(id, mob))
        .onSuccess(result => {
            if (result.cmd == MobCommand.DELETE)
                store.remove(mobName)
            else
                store.update(mobName, result.mob);
            bus.publishFront("mobberLeft", mobberEvent(result.mob, new Mobber(id, "NoName")))
            res.status(204).end();
        })
        .onError(error => handle(error, res))
};

const parseMobber = (req: Request) => new Mobber(req.body.id, req.body.name);

const mobberEvent = (mob: Mob, mobber: Mobber) => ({
    mobber: mobber,
    mobbers: mob.mobbers
});