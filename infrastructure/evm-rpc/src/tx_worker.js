import { parseRawTx } from './helper.js';

export const sortTx = function (txPool) {
    const allTx = [];
    Object.values(txPool).forEach(txArr => {
        allTx.push(...txArr);
    });

    allTx.sort((a, b) => {
        // for ETH and ERC20 transfer priority
        if (a.gasLimit < 50000 && b.gasLimit < 50000) {
            if (a.gasLimit !== b.gasLimit) {
                return a.gasLimit - b.gasLimit;
            }
        }
        if (a.ts !== b.ts) {
            return a.ts - b.ts;
        }
        return b.nonce - a.nonce;
    });
    return allTx;
};

export const parseTx = function (tx) {
    return parseRawTx(tx);
};
