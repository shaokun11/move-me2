import { ZeroAddress, Transaction } from 'ethers';
import { BigNumber } from 'bignumber.js';
import { randomBytes } from 'node:crypto';
import { TransactionFactory } from '@ethereumjs/tx';
import { HexString } from 'aptos';

export function parseRawTx(tx) {
    const tx_ = Transaction.from(tx);
    const txJson = tx_.toJSON();
    const tx2 = TransactionFactory.fromSerializedData(Buffer.from(tx.slice(2), 'hex'));
    const from = tx_.from.toLowerCase();
    let gasPrice = null;
    if (txJson.type === 2) {
        gasPrice = toHex(txJson.maxFeePerGas);
    }
    return {
        hash: tx_.hash,
        nonce: txJson.nonce,
        from: from,
        maxPriorityFeePerGas: txJson.maxPriorityFeePerGas,
        maxFeePerGas: txJson.maxFeePerGas,
        type: toHex(txJson.type || 0),
        messageHash: tx_.unsignedHash,
        accessList: txJson.accessList,
        gasPrice: gasPrice,
        limit: toHex(txJson.gasLimit),
        to: txJson.to?.toLowerCase() || ZeroAddress,
        value: toHex(txJson.value),
        data: txJson.data || '0x',
        v: txJson?.sig.v ?? 27,
        r: txJson?.sig.r ?? '0x',
        s: txJson?.sig.v ?? '0x',
        chainId: +txJson.chainId,
        accessList: txJson.accessList,
    };
}

export function toHex(number) {
    let ret = BigNumber(number).toString(16);
    return '0x' + ret;
}

export function toHexStrict(number) {
    let ret = BigNumber(number).toString(16);
    if (ret.length % 2 != 0) {
        ret = '0' + ret;
    }
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

// let x =
//     '0x02f8d58201500486015d3ef7980086015d3ef79800825208946a9a394cb23b2c5b2e4290f75f80a8e049f3347e80b864c47f00270000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000668656c6c6f320000000000000000000000000000000000000000000000000000c001a038787b861c38d1ff1efaa187cba5f4939228d103e732eae0173d7078389e0af9a079d70b4d9453f35688d3930bbfd87827a274eec1a7ffd8034898d5a600c14811';
// parseRawTx(x);

export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

export function move2ethAddress(addr) {
    addr = addr.toLowerCase();
    return '0x' + addr.slice(-40);
}
export function parseMoveTxPayload(info) {
    const args = info.payload.arguments;
    const tx = parseRawTx(args[0]);
    return {
        value: tx.value,
        from: tx.from,
        to: tx.to,
        type: tx.type,
        nonce: tx.nonce,
        data: tx.data,
        fee: args[2],
        r: tx.r,
        s: tx.s,
        v: tx.v,
        hash: tx.hash,
        limit: tx.limit,
        gasPrice: tx.gasPrice,
        maxPriorityFeePerGas: tx.maxPriorityFeePerGas,
        maxFeePerGas: tx.maxFeePerGas,
    };
}
