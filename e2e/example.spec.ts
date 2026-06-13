import { v4 as uuid } from 'uuid';
import { AppHome, MobHome } from './POMs.ts';
import { test, expect } from '@playwright/test';

const testMobId = `test-${uuid()}`;

// TODO: Quand on lance un tour ca le lance chez tout le monde
// TODO: Quand le tour se termine ca joue un son de la playlist selectionnee, le meme chez tout le monde
// TODO: On peut ajouter des gens
// TODO: Quand un tour se finit, la liste des personne tourne, les roles sont reassignes
// TODO: Chaque personne se voit affecter un role
// TODO: Quand on shuffle les mobbers, c'est le meme ordre chez tout le monde
// TODO: Quand on change les roles dans les settings ca change chez tout le monde
// TODO: Quand on change la duree d'un tour ca change chez tout le monde
test('has title', async ({ page }) => {
    const mobHome = new MobHome(page, testMobId);
    const profile = await mobHome.goto();
    await profile.expectPageTitle();
    await profile.gotoMobHome();
    await mobHome.expectTitlePage();
});

test('test', async ({ page }) => {
    const appHome = new AppHome(page);
    await appHome.goto();
    await appHome.fillMobName();
    const mobHome = await appHome.createMob();

    await mobHome.expectTitlePage();

    const mobberSettings = await mobHome.gotoMobberSettings();
    await mobberSettings.expectTitlePage();
    const players = ['First', 'Second', 'Third', 'Fourth'];
    for (let player of players) {
        await mobberSettings.addMobber(player);
    }
    await mobberSettings.goBackHome();

    await mobHome.expectPlayersInOrder(players);

    const settings = await mobHome.gotoSettings();
    await settings.toggleExtremeMode();
    await settings.setTurnLength(1);
    await settings.goBackHome();

    const startTurnButton = mobHome.getStartTurnButton();
    await expect(startTurnButton).toHaveText(/00:01/);
    await startTurnButton.click();

    await mobHome.stopMusic();
    await mobHome.expectOvertime();

    await expect(startTurnButton).not.toBeVisible();

    mobHome.stopTurn();
    await expect(startTurnButton).toBeVisible();

    await mobHome.expectPlayersInOrder(['Second', 'Third', 'Fourth', 'First']);
});
