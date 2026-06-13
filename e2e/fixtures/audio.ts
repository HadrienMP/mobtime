import { test as base, Page } from '@playwright/test';

export class AudioMonitor {
    constructor(private page: Page) {}

    async start() {
        await this.page.addInitScript(() => {
            (window as any).soundsPlayed = [];

            // --- 1. Patch Standard HTML5 Audio ---
            const originalHtmlAudioPlay = HTMLAudioElement.prototype.play;
            HTMLAudioElement.prototype.play = function (...args) {
                const soundName =
                    this.src.split('/').pop()?.split('.')[0] ||
                    'unknown_html_audio';

                (window as any).soundsPlayed.push({
                    name: soundName,
                    src: this.src,
                    type: 'HTMLAudio',
                    timestamp: Date.now(),
                });

                return originalHtmlAudioPlay.apply(this, args);
            };

            // --- 2. Patch Web Audio API ---
            const originalBufferSourceStart =
                AudioBufferSourceNode.prototype.start;
            AudioBufferSourceNode.prototype.start = function (...args) {
                const soundName =
                    (this as any).audioName ||
                    (this.buffer
                        ? `buffer_len_${this.buffer.length}`
                        : 'unknown_web_audio');

                (window as any).soundsPlayed.push({
                    name: soundName,
                    type: 'WebAudio',
                    timestamp: Date.now(),
                });

                return originalBufferSourceStart.apply(this, args);
            };
        });
    }

    async getPlayedSounds(): Promise<string[]> {
        return await this.page.evaluate(() => {
            return (window as any).soundsPlayed?.map((s: any) => s.name) || [];
        });
    }

    async verifyExpectedSounds(expectedSounds: string[]) {
        const playedSounds = await this.getPlayedSounds();
        const missing = expectedSounds.filter(
            (expected) =>
                !playedSounds.some((played) => played.includes(expected)),
        );
        return { played: playedSounds, missing };
    }
}

// Extend Playwright's base test to include our audioMonitor fixture
export const test = base.extend<{ audioMonitor: AudioMonitor }>({
    audioMonitor: async ({ page }, use) => {
        const monitor = new AudioMonitor(page);
        await monitor.start();
        await use(monitor);
        // Cleanup is automatic as the window object is destroyed with the page
    },
});

export { expect } from '@playwright/test';
