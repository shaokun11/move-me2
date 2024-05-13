let request = new Map();

const ONE_DAY_SECONDS = 24 * 60 * 60;

export function canRequest(ip) {
    let callTime = request.get(ip);
    if (!callTime) {
        request.set(ip, Date.now());
        return [true, 0];
    }
    if (Date.now() - callTime < ONE_DAY_SECONDS * 1000) {
        return [false, Math.floor((ONE_DAY_SECONDS * 1000 - (Date.now() - callTime)) / 1000)];
    }
    request.set(ip, Date.now());
    return [true, 0];
}
