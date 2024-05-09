let request = new Map();
const limit = 24 * 60 * 60 * 1000;
function canRequest(key) {
    let callTime = request.get(key);
    if (!callTime) {
        request.set(key, Date.now());
        return true;
    }
    if (Date.now() - callTime < limit) {
        return false;
    }
    request.set(key, Date.now());
    return true;
}
module.exports = {
    canRequest
}