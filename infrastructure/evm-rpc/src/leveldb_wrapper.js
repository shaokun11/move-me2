import levelup from 'levelup';
import leveldown from 'leveldown';
import { DISABLE_CACHE, REMOTE_CACHE_URL } from './const.js';

class LevelDBWrapper {
    constructor(dbPath) {
        this.db = levelup(leveldown(dbPath));
    }

    async put(key, value) {
        if (DISABLE_CACHE) return;
        return new Promise((resolve, reject) => {
            this.db.put(key, value, err => {
                // just for cache, no need to reject
                // if (err) return reject(err);
                resolve();
            });
        });
    }

    async get(key) {
        if (DISABLE_CACHE) return null;
        return new Promise((resolve, reject) => {
            this.db.get(key, (err, value) => {
                if (err) {
                    // just for cache, no need to reject
                    resolve(null);
                }
                // now we only support string
                resolve((value && value.toString()) || null);
            });
        });
    }
}

class remoteLevelDBWrapper {
    constructor(url) {
        this.url = url;
    }

    async put(key, value) {
        return fetch(this.url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                key,
                value,
            }),
        })
            .then(res => res.text())
            .catch(() => null);
    }

    async get(key) {
        return fetch(this.url + '?key=' + key)
            .then(res => res.text())
            .catch(() => null);
    }
}

export const DB_TX = REMOTE_CACHE_URL
    ? new remoteLevelDBWrapper(REMOTE_CACHE_URL)
    : new LevelDBWrapper('db/tx');
export default LevelDBWrapper;

// let db = new LevelDBWrapper('./db/tx');
// await db.put('key', 'hello')
// console.log(await db.get('key'))
