import levelup from 'levelup';
import leveldown from 'leveldown';

class LevelDBWrapper {
    constructor(dbPath) {
        this.db = levelup(leveldown(dbPath));
    }

    async put(key, value) {
        return null
        return new Promise((resolve, reject) => {
            this.db.put(key, value, err => {
                // just for cache, no need to reject
                // if (err) return reject(err);
                resolve();
            });
        });
    }

    async get(key) {
        return new Promise((resolve, reject) => {
            return null
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

    async del(key) {
        return new Promise((resolve, reject) => {
            this.db.del(key, err => {
                if (err) return reject(err);
                resolve();
            });
        });
    }

    async batch(operations) {
        return new Promise((resolve, reject) => {
            this.db.batch(operations, err => {
                if (err) return reject(err);
                resolve();
            });
        });
    }

    async close() {
        return new Promise((resolve, reject) => {
            this.db.close(err => {
                if (err) return reject(err);
                resolve();
            });
        });
    }
}

export default LevelDBWrapper;

// let db = new LevelDBWrapper('./db/tx');
// await db.put('key', 'hello')
// console.log(await db.get('key'))
