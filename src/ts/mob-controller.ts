import slugify from "slugify";
import * as store from "./store";
import {Mob} from "./model";
import {List} from "immutable";
import {Request, Response} from "express";


export function urlJoin(req: Request, res: Response) {
    join(req.params.name);
    res.render("index");
}

export function apiJoin(req: Request, res: Response) {
    res.json({name: join(req.body.name)});
}

function join(rawName: string) {
    let name = slugify(rawName);
    store.getMob(name).onError(_ => store.update(name, new Mob(name, List())));
    return name;
}
