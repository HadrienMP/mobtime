import {Request, Response} from "express";
import * as store from "./store";

export const calculate = (req: Request, res: Response) => {
    res.json({
        mobs: store.mobs.size,
        mobbers:
            store.mobs
                .valueSeq()
                .map(value => value.mobbers.size)
                .reduce((reduction, value) => reduction + value, 0)
    });
}