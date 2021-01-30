import {Mob, MobberId} from "../model";

export enum MobCommand {
    UPDATE,
    DELETE
}

export function deleteMobber(id: MobberId, mob: Mob): { cmd: MobCommand, mob: Mob } {
    let updated = mob.deleteMobber(id);
    return {
        cmd: updated.mobbers.size === 0
            ? MobCommand.DELETE
            : MobCommand.UPDATE,
        mob: updated
    }
}