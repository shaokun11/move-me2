import { parseRawTx } from './helper.js';

export const sortTx = function (txPool) {
    const allTx = [];
    Object.values(txPool).forEach(txArr => {
        allTx.push(...txArr);
    });

    allTx.sort((a, b) => {
        if (a.nonce !== b.nonce) {
            return b.nonce - a.nonce;
        }
        return a.ts - b.ts;
    });
    return allTx;
};

export const parseTx = function (tx) {
    return parseRawTx(tx);
};
