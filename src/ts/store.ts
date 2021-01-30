import {Map} from "immutable";
import {Mob, MobName} from "./model";
import {result, Result} from "./lib/Result";
import {ImprovedError, userError} from "./lib/error-management";

type Mobs = Map<MobName, Mob>
export let mobs: Mobs = Map()
export const get = () => mobs;
export const update = (mobName: MobName, mob: Mob) => mobs = mobs.set(mobName, mob);
export const remove = (mobName: MobName) => mobs = mobs.remove(mobName);

export function getMob(mobName: MobName): Result<Mob, ImprovedError> {
    return result(mobs.get(mobName), userError(`No mob is named ${mobName}`));
}
