export const setup = (app) =>
    app.ports.copyShareLink.subscribe(text => {
        if (navigator.clipboard) {
            navigator.clipboard
                .writeText(text)
                .finally(() => app.ports.events.send({ name: 'Copied', value: "" }))
        } else {
            if (fallbackCopyTextToClipboard(text))
                app.ports.shareLinkCopied.send("");
            else {
                alert('wut')
            }
        }
    });

function fallbackCopyTextToClipboard(text) {
    var textArea = document.createElement("textarea");
    textArea.value = text;

    // Avoid scrolling to bottom
    textArea.style.top = "0";
    textArea.style.left = "0";
    textArea.style.position = "fixed";

    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();

    try {
        return document.execCommand('copy');
    } catch (err) {
        console.error('Fallback: Oops, unable to copy', err);
        return false;
    } finally {
        document.body.removeChild(textArea);
    }
}