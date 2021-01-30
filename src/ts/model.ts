import {List} from "immutable";

export type MobberId = String;

export class Mobber {
    readonly id: MobberId
    readonly name: String

    constructor(id: MobberId, name: String) {
        this.id = id;
        this.name = name;
    }

    withName(name: String) {
        return new Mobber(this.id, name)
    }

    public toString = (): string => {
        return `Mobber (id: ${this.id}, name: ${this.name})`;
    }
}

export type Mobbers = List<Mobber>
export type MobName = String;

export class Mob {
    readonly name: MobName
    readonly mobbers: Mobbers

    constructor(name: MobName, mobbers: Mobbers) {
        this.name = name;
        this.mobbers = mobbers;
    }

    addMobber(mobber: Mobber) {
        return this.withMobbers(this.mobbers.push(mobber));
    }
    updateMobber(mobber: Mobber) {
        return this.withMobbers(
            this.mobbers.map(m => m.id === mobber.id ? mobber : m)
        );
    }

    deleteMobber(id: MobberId) {
        return this.withMobbers(this.mobbers.filter(mobber => mobber.id !== id));
    }
    withMobbers(mobbers: Mobbers): Mob {
        return new Mob(this.name, mobbers)
    }

    public toString = (): string => {
        return `Mob (name: ${this.name}, mobbers: ${this.mobbers})`;
    }
}
