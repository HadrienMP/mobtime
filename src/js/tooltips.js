import tippy from 'tippy.js';
import 'tippy.js/dist/tippy.css';

export const setup = () =>
    tippy('button[title]', {
        delay: 200,
        content(reference) {
            const title = reference.getAttribute('title');
            reference.removeAttribute('title');
            return title;
        },
    });
