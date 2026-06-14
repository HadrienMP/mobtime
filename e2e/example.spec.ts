import { v4 as uuid } from 'uuid';
import { AppHome, MobHome } from './POMs.ts';
import { test, expect } from '@playwright/test';

// TODO: Quand on lance un tour ca le lance chez tout le monde
// TODO: Quand le tour se termine ca joue un son de la playlist selectionnee, le meme chez tout le monde
// TODO: On peut ajouter des gens
// TODO: Quand un tour se finit, la liste des personne tourne, les roles sont reassignes
// TODO: Chaque personne se voit affecter un role
// TODO: Quand on shuffle les mobbers, c'est le meme ordre chez tout le monde
// TODO: Quand on change les roles dans les settings ca change chez tout le monde
// TODO: Quand on change la duree d'un tour ca change chez tout le monde
test('has title', async ({ page }) => {
    const mobHome = new MobHome(page, `test-${uuid()}`);
    const profile = await mobHome.goto();
    await profile.expectPageTitle();
    await profile.gotoMobHome();
    await mobHome.expectTitlePage();
});

test('single player acceptance test', async ({ page }) => {
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

test('shuffling players gives the same order for all players', async ({
    browser,
}) => {
    const contextFirstPlayer = await browser.newContext();
    const pageFirstPlayer = await contextFirstPlayer.newPage();
    const contextSecondPlayer = await browser.newContext();
    const pageSecondPlayer = await contextSecondPlayer.newPage();

    // Init mob with first player
    const appHome = new AppHome(pageFirstPlayer);
    await appHome.goto();
    await appHome.fillMobName();
    const mobHomeFirstPlayer = await appHome.createMob();

    // Second player joins
    const mobHomeSecondPlayer = new MobHome(
        pageSecondPlayer,
        mobHomeFirstPlayer.mobId,
    );
    const profile = await mobHomeSecondPlayer.goto();
    await profile.gotoMobHome();

    const players = ['First', 'Second', 'Third', 'Fourth'];

    // First player adds mobbers
    const mobberSettings = await mobHomeFirstPlayer.gotoMobberSettings();
    for (let player of players) {
        await mobberSettings.addMobber(player);
    }
    await mobberSettings.goBackHome();

    // Second player shuffles
    await mobHomeSecondPlayer.shuffleMobbers();
    expect(await mobHomeSecondPlayer.getTeamText()).toStrictEqual(
        await mobHomeFirstPlayer.getTeamText(),
    );
});

test('cooperation acceptance test', async ({ browser }) => {
    const contextFirstPlayer = await browser.newContext();
    const pageFirstPlayer = await contextFirstPlayer.newPage();
    const contextSecondPlayer = await browser.newContext();
    const pageSecondPlayer = await contextSecondPlayer.newPage();

    // Init mob with first player
    const appHome = new AppHome(pageFirstPlayer);
    await appHome.goto();
    await appHome.fillMobName();
    const mobHomeFirstPlayer = await appHome.createMob();

    // Second player joins
    const mobHomeSecondPlayer = new MobHome(
        pageSecondPlayer,
        mobHomeFirstPlayer.mobId,
    );
    const profile = await mobHomeSecondPlayer.goto();
    await profile.gotoMobHome();

    const players = ['First', 'Second', 'Third', 'Fourth'];

    // First player adds mobbers
    const mobberSettingsFirstPlayer =
        await mobHomeFirstPlayer.gotoMobberSettings();
    for (let player of players.slice(0, 2)) {
        await mobberSettingsFirstPlayer.addMobber(player);
    }
    await mobberSettingsFirstPlayer.goBackHome();

    // Second player adds mobbers
    const mobberSettingsSecondPlayer =
        await mobHomeSecondPlayer.gotoMobberSettings();
    for (let player of players.slice(2)) {
        await mobberSettingsSecondPlayer.addMobber(player);
    }
    await mobberSettingsSecondPlayer.goBackHome();

    // All player names are displayed
    await mobHomeFirstPlayer.expectPlayersInOrder(players);
    await mobHomeSecondPlayer.expectPlayersInOrder(players);

    // First player changes settings
    const settings = await mobHomeFirstPlayer.gotoSettings();
    await settings.toggleExtremeMode();
    await settings.setTurnLength(1);
    await settings.goBackHome();

    // Second player can start turn
    const startTurnButton = mobHomeSecondPlayer.getStartTurnButton();
    await expect(startTurnButton).toHaveText(/00:01/);
    await startTurnButton.click();

    // All players have music and overtime
    await mobHomeFirstPlayer.stopMusic();
    await mobHomeFirstPlayer.expectOvertime();
    await mobHomeSecondPlayer.stopMusic();
    await mobHomeSecondPlayer.expectOvertime();

    mobHomeSecondPlayer.stopTurn();
    await expect(startTurnButton).toBeVisible();

    // All players have rotated players
    await mobHomeFirstPlayer.expectPlayersInOrder([
        'Second',
        'Third',
        'Fourth',
        'First',
    ]);
    await mobHomeSecondPlayer.expectPlayersInOrder([
        'Second',
        'Third',
        'Fourth',
        'First',
    ]);
});
