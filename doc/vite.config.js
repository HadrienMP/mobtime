import { defineConfig } from 'vite';
import elmPlugin from 'vite-plugin-elm';

export default defineConfig({
    plugins: [elmPlugin()],
    root: './doc/',
    server: {
        port: '4321',
    },
    build: {
        outDir: './doc/dist/',
    },
});
