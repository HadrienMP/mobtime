export const openInTab = (object) => {
    const tab = window.open(
        'data:text/json,' + encodeURIComponent(JSON.stringify(object)),
        '_blank'
    );
    tab.focus();
};
