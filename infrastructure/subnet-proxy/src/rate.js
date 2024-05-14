const low = require('lowdb')
const FileSync = require('lowdb/adapters/FileSync')

const adapter = new FileSync('faucet.limiter.json')
const db = low(adapter)
db.defaults({ users: [] })
    .write()
const limit = 24 * 60 * 60 * 1000;

async function canRequest(key) {
    const user = await db.get("users").find({
        key
    }).value();
    if (user) {
        if (Date.now() - user.time < limit) {
            return [false, Math.floor((limit - (Date.now() - user.time)) / 1000)];
        }
        return [true, 0];
    }
    return [true, 0];
}

async function setRequest(key) {
    const user = await db.get("users").find({
        key
    })
    if (user.value()) {
        await user.assign({
            time: Date.now()
        }).write();
    } else {
        await await db.get("users").push({ key, time: Date.now() }).write();
    }
}
module.exports = { canRequest, setRequest };

// canRequest('test').then(console.log);
// setRequest('test').then(console.log);