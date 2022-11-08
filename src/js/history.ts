import sum from 'hash-sum';

class History {
    private _events: any[];
    // private _hash: string;
    private constructor(events: any[]) {
        this._events = events;
        // this._hash = hash;
    }
    static from(events: any[]) {
        return new History(events);
    }
    static empty = this.from([]);
    add = (event: any): History => {
        this._events.push(event)
        return new History(
            this._events
        );
    }
    hash = () => 0;
    events = () => this._events;
}

export class RommHistories {
    private value: Record<string, History> = {}
    private histories: Record<string, History[]> = {}
    private timeOut: NodeJS.Timeout | null = null;
    add = (room: string, message: any) => {
        const roomHistory = this.value[room] ?? History.empty;
        this.value[room] = roomHistory.add(message);
    }
    elect = (room: string, history: any[], onElection: (history: History) => void) => {
        console.log(`📜 ⬅️ received a history`, history)
        const histories = this.histories[room] ?? [];
        histories.push(History.from(history));
        this.histories[room] = histories;
        if (!this.timeOut) {
            this.timeOut = setTimeout(() => {
                const all = this.histories[room] ?? []
                const votes: Record<string, number> = {};
                let elected = { count: 0, history: History.empty };
                let total = 0;
                all.forEach(it => {
                    console.log({it});
                    let count = votes[it.hash()] ?? 0
                    count += 1;
                    votes[it.hash()] = count;
                    total += 1;
                    if (count > elected.count) {
                        elected = { count, history: it }
                    }
                })
                this.value[room] = elected.history;
                console.log(`📜 🎩 elected a history ${elected.count}/${total}`, elected.history.events())
                onElection(elected.history);
                this.timeOut = null;
            }, 1000);
        }
    }
    of = (room: string) => {
        return this.value[room] || History.empty;
    }
}