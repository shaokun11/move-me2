import { JSONFilePreset } from 'lowdb/node';
import { FAUCET_LIMIT_DURATION } from './const.js';
const db = await JSONFilePreset(`faucet.limiter.json`, []);
const limit = parseInt(FAUCET_LIMIT_DURATION) * 1000;

export async function canRequest(key) {
    const user = await db.data.find(it => it.key === key);
    if (user) {
        if (Date.now() - user.time < limit) {
            return [false, Math.floor((limit - (Date.now() - user.time)) / 1000)];
        }
        return [true, 0];
    }
    return [true, 0];
}

export async function setRequest(key) {
    await db.update(users => {
        const item = users.find(it => it.key === key);
        if (item) {
            item[key] = Date.now();
        } else {
            users.push({ key, time: Date.now() });
        }
    });
}
