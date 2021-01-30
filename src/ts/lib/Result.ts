export function result<T, ERROR>(o: T | undefined, error: ERROR): Result<T, ERROR> {
    return o ? success(o) : fail(error);
}

export function success<OK, ERROR>(success: OK): Result<OK, ERROR> {
    return new Ok(success);
}
export function fail<OK, ERROR>(error: ERROR): Result<OK, ERROR> {
    return new Error(error);
}
export interface Result<OK, ERROR> {
    map<OK2>(f: (ok: OK) => OK2) : Result<OK2, ERROR>;
    flatMap<OK2>(f: (ok: OK) => Result<OK2, ERROR>) : Result<OK2, ERROR>;
    mapError<E2>(f : (error: ERROR) => E2) : Result<OK, E2>;
    onSuccess(f: (ok: OK) => void) : Result<OK, ERROR>;
    onError(f: (error: ERROR) => void) : Result<OK, ERROR>
    fold<T>(okF: (ok: OK) => T, errorF: (error: ERROR) => T) : T;
}
export class Ok<OK, ERROR> implements Result<OK, ERROR> {
    readonly value: OK;
    constructor(value: OK) {
        this.value = value;
    }

    map<OK2>(f: (ok: OK) => OK2): Result<OK2, ERROR> {
        return new Ok(f(this.value));
    }

    flatMap<OK2>(f: (ok: OK) => Result<OK2, ERROR>): Result<OK2, ERROR> {
        return f(this.value);
    }

    fold<T>(okF: (ok: OK) => T, errorF: (error: ERROR) => T): T {
        return okF(this.value);
    }

    mapError<E2>(f: (error: ERROR) => E2): Result<OK, E2> {
        return new Ok(this.value);
    }

    onError(f: (error: ERROR) => void): Result<OK, ERROR> {
        return this;
    }

    onSuccess(f: (ok: OK) => void): Result<OK, ERROR> {
        f(this.value);
        return this;
    }
}
export class Error<OK, ERROR> implements Result<OK, ERROR> {
    readonly value: ERROR;
    constructor(value: ERROR) {
        this.value = value;
    }

    flatMap<OK2>(f: (ok: OK) => Result<OK2, ERROR>): Result<OK2, ERROR> {
        return new Error(this.value);
    }

    fold<T>(okF: (ok: OK) => T, errorF: (error: ERROR) => T): T {
        return errorF(this.value);
    }

    map<OK2>(f: (ok: OK) => OK2): Result<OK2, ERROR> {
        return new Error(this.value);
    }

    mapError<E2>(f: (error: ERROR) => E2): Result<OK, E2> {
        return new Error(f(this.value));
    }

    onError(f: (error: ERROR) => void): Result<OK, ERROR> {
        f(this.value);
        return this;
    }

    onSuccess(f: (ok: OK) => void): Result<OK, ERROR> {
        return this;
    }

}