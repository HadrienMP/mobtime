const timers = {};
export const debounce =
    (func, name, timeout = 300) =>
    () => {
        if (timers[name]) {
            return;
        }
        func();
        timers[name] = setTimeout(() => clearTimeout(timers[name]), timeout);
    };
