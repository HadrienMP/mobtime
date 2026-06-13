import { Page } from '@playwright/test';
import { test, expect } from './fixtures/audio';
import { v4 as uuid } from 'uuid';

const testMobId = `test-${uuid()}`;
const roles = ['Driver', 'Navigator', 'Next Navigator'];

// TODO: Quand on lance un tour ca le lance chez tout le monde
// TODO: Quand le tour se termine ca joue un son de la playlist selectionnee, le meme chez tout le monde
// TODO: On peut ajouter des gens
// TODO: Quand un tour se finit, la liste des personne tourne, les roles sont reassignes
// TODO: Chaque personne se voit affecter un role
// TODO: Quand on shuffle les mobbers, c'est le meme ordre chez tout le monde
// TODO: Quand on change les roles dans les settings ca change chez tout le monde
// TODO: Quand on change la duree d'un tour ca change chez tout le monde
test('has title', async ({ page }) => {
    await page.goto(`http://localhost:3000/mob/${testMobId}`);
    await expect(page).toHaveTitle(`Profile | ${testMobId} | Mob Time`);
    await page.getByRole('button', { name: 'Test the audio' }).click();
    await page.getByRole('button', { name: 'Join' }).click();
    await expect(page).toHaveTitle(`${testMobId} | Mob Time`);
});

test('test', async ({ page }) => {
    await page.goto('http://localhost:3000/');
    await page.getByRole('textbox', { name: 'Name' }).fill(testMobId);
    await page.getByRole('button', { name: 'Test the audio' }).click();
    await page.getByRole('button', { name: 'Create' }).click();
    await expect(page).toHaveTitle(`${testMobId} | Mob Time`);

    await page.getByRole('button', { name: 'Add' }).click();
    await page.getByRole('textbox', { name: 'Name' }).fill('First P');
    await page.getByRole('button', { name: 'Add' }).click();
    await page.getByRole('textbox', { name: 'Name' }).fill('Second P');
    await page.getByRole('button', { name: 'Add' }).click();
    await page.getByRole('textbox', { name: 'Name' }).fill('Third P');
    await page.getByRole('button', { name: 'Add' }).click();
    await page.getByRole('textbox', { name: 'Name' }).fill('Fourth P');
    await page.getByRole('button', { name: 'Add' }).click();
    await page.getByRole('button', { name: 'Back' }).click();

    await expectPlayersInOrder(page, ['First', 'Second', 'Third', 'Fourth']);

    await page.getByRole('link', { name: 'Settings' }).click();
    await page.getByRole('button', { name: 'Extreme Mode' }).click();
    await page.getByRole('slider', { name: 'Turn' }).fill('1');
    await page.getByRole('button', { name: 'Back' }).click();
    await page.getByRole('button', { name: 'Start a turn 00:01' }).click();
    await page.getByRole('button', { name: 'Stop music' }).click();

    await expect(page.getByText('Overtime')).toBeVisible();
    await expect(
        page.getByRole('button', { name: 'Start a turn' }),
    ).not.toBeVisible();

    await page.getByRole('button', { name: 'Stop' }).first().click();
    await expect(
        page.getByRole('button', { name: 'Start a turn' }),
    ).toBeVisible();

    await expectPlayersInOrder(page, ['Second', 'Third', 'Fourth', 'First']);
});
async function expectPlayersInOrder(page: Page, playersInOrder: string[]) {
    for (let i in playersInOrder) {
        const player = playersInOrder[i];
        const role = roles[i] ?? '';
        await expect(page.getByText(`${role}${player} P`)).toBeVisible();
    }
}
