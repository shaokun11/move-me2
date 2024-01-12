import { ZeroAddress, Transaction } from 'ethers';
import { BigNumber } from 'bignumber.js';
import { randomBytes } from 'node:crypto';
import { LegacyTransaction } from '@ethereumjs/tx';
export function parseRawTx(tx) {
    const tx_ = Transaction.from(tx);
    tx_.signature;
    const txJson = tx_.toJSON();
    const from = tx_.from.toLowerCase();
    const tx2 = LegacyTransaction.fromSerializedTx(tx);
    return {
        hash: tx_.hash,
        nonce: txJson.nonce,
        from: from,
        messageHash: tx_.unsignedHash,
        gasPrice: toHex(txJson.gasPrice),
        limit: toHex(txJson.gasLimit),
        to: txJson.to?.toLowerCase() || ZeroAddress,
        value: toHex(txJson.value),
        data: txJson.data || '0x',
        v: +tx2.v?.toString() ?? 27,
        r: (tx2.r && toHex(tx2.r)) || '0x',
        s: (tx2.s && toHex(tx2.s)) || '0x',
        chainId: +txJson.chainId,
    };
}

export function toHex(number) {
    let ret = BigNumber(number).toString(16);
    return '0x' + ret;
}

export function toNumber(number) {
    return BigNumber(number).toNumber();
}

export function toNumberStr(number) {
    return BigNumber(number).decimalPlaces(0).toFixed();
}

export function toU256Hex(a, includePrefix = true) {
    let it = toHex(a).slice(2).padStart(64, '0');
    if (includePrefix) return '0x' + it;
    return it;
}

export function sleep(s) {
    return new Promise(r => {
        setTimeout(r, s * 1000);
    });
}

export function randomHex(bytes = 32) {
    return '0x' + Buffer.from(randomBytes(bytes)).toString('hex');
}
