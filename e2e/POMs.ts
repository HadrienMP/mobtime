import { expect, type Page } from '@playwright/test';
import { v4 as uuid } from 'uuid';

const roles = ['Driver', 'Navigator', 'Next Navigator'];

export class MobHome {
    readonly page: Page;
    readonly mobId: string;

    constructor(page: Page, mobId: string) {
        this.page = page;
        this.mobId = mobId;
    }

    async goto() {
        await this.page.goto(`http://localhost:3000/mob/${this.mobId}`);
        return new Profile(this.page, this.mobId);
    }

    async expectTitlePage() {
        await expect(this.page).toHaveTitle(`${this.mobId} | Mob Time`);
    }

    async gotoMobberSettings() {
        await this.page.getByRole('button', { name: 'Add' }).click();
        return new MobberSettings(this.page, this.mobId);
    }
    async gotoSettings() {
        await this.page.getByRole('link', { name: 'Settings' }).click();
        return new Settings(this.page, this.mobId);
    }

    async expectPlayersInOrder(playersInOrder: string[]) {
        for (let i in playersInOrder) {
            const player = playersInOrder[i];
            const role = roles[i] ?? '';
            await expect(this.page.getByText(`${role}${player}`)).toBeVisible();
        }
    }
    getStartTurnButton() {
        return this.page.getByRole('button', { name: 'Start a turn' });
    }

    async stopMusic() {
        await this.page.getByRole('button', { name: 'Stop music' }).click();
    }

    async expectOvertime() {
        await expect(this.page.getByText('Overtime')).toBeVisible();
    }

    async stopTurn() {
        await this.page.getByRole('button', { name: 'Stop' }).first().click();
    }

    async shuffleMobbers() {
        await this.page.getByRole('button', { name: 'Shuffle' }).click();
    }

    async getTeamText() {
        return await this.page.getByText('TeamDriver').allInnerTexts();
    }
}

export class Profile {
    readonly page: Page;
    readonly mobId: string;

    constructor(page: Page, mobId: string) {
        this.page = page;
        this.mobId = mobId;
    }

    async expectPageTitle() {
        await expect(this.page).toHaveTitle(
            `Profile | ${this.mobId} | Mob Time`,
        );
    }

    async gotoMobHome() {
        await this.page.getByRole('button', { name: 'Join' }).click();
        return new MobHome(this.page, this.mobId);
    }
}

export class Settings {
    readonly page: Page;
    readonly mobId: string;

    constructor(page: Page, mobId: string) {
        this.page = page;
        this.mobId = mobId;
    }

    async toggleExtremeMode() {
        await this.page.getByRole('button', { name: 'Extreme Mode' }).click();
    }
    async setTurnLength(value: number) {
        await this.page
            .getByRole('slider', { name: 'Turn' })
            .fill(value.toString());
    }
    async goBackHome() {
        await this.page.getByRole('button', { name: 'Back' }).click();
        return new MobHome(this.page, this.mobId);
    }
}

export class MobberSettings {
    readonly page: Page;
    readonly mobId: string;

    constructor(page: Page, mobId: string) {
        this.page = page;
        this.mobId = mobId;
    }

    async expectTitlePage() {
        await expect(this.page).toHaveTitle(
            `Mobbers | ${this.mobId} | Mob Time`,
        );
    }

    async goBackHome() {
        await this.page.getByRole('button', { name: 'Back' }).click();
        return new MobHome(this.page, this.mobId);
    }

    async addMobber(name: string) {
        await this.page.getByRole('textbox', { name: 'Name' }).fill(name);
        await this.page.getByRole('button', { name: 'Add' }).click();
    }
}

export class AppHome {
    readonly page: Page;
    readonly testMobId = `test-${uuid()}`;

    constructor(page: Page) {
        this.page = page;
    }

    async goto() {
        await this.page.goto('http://localhost:3000/');
    }

    async fillMobName() {
        await this.page
            .getByRole('textbox', { name: 'Name' })
            .fill(this.testMobId);
    }
    async createMob() {
        await this.page.getByRole('button', { name: 'Create' }).click();
        return new MobHome(this.page, this.testMobId);
    }
}
