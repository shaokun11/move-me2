import { BigNumber } from 'bignumber.js';
import { randomBytes } from 'node:crypto';
import { HexString } from 'aptos';
import { TransactionFactory } from '@ethereumjs/tx';
import logger from './logger.js';

export function parseRawTx(tx) {
    let tx2 = null;
    try {
        tx2 = TransactionFactory.fromSerializedData(Buffer.from(tx.slice(2), 'hex'));
    } catch (error) {
        logger.debug('parseRawTx error:%s', error);
        throw new Error('Invalid transaction');
    }
    //  enum TransactionType {
    //     Legacy = 0,
    //     AccessListEIP2930 = 1,
    //     FeeMarketEIP1559 = 2,
    //     BlobEIP4844 = 3,
    //   }
    if (tx.type >= 3) {
        throw new Error('Invalid transaction type');
    }
    let gasPrice = null;
    let maxPriorityFeePerGas = null;
    let maxFeePerGas = null;
    if (tx2.gasPrice) {
        gasPrice = toHex(tx2.gasPrice);
    }
    if (tx2.gasPrice === 0n) {
        gasPrice = '0x0';
    }
    if (tx2.maxFeePerGas === 0n) {
        maxFeePerGas = '0x0';
    }
    if (tx2.maxPriorityFeePerGas === 0n) {
        maxPriorityFeePerGas = '0x0';
    }
    if (tx2.maxPriorityFeePerGas) {
        maxPriorityFeePerGas = toHex(tx2.maxPriorityFeePerGas);
    }
    if (tx2.maxFeePerGas) {
        maxFeePerGas = toHex(tx2.maxFeePerGas);
    }
    return {
        type: toHex(tx2.type),
        from: tx2.getSenderAddress().toString().toLowerCase(),
        to: tx2.to?.toString().toLowerCase(),
        hash: '0x' + Buffer.from(tx2.hash()).toString('hex').padStart(64, '0'),
        messageHash: '0x' + Buffer.from(tx2.getHashedMessageToSign()).toString('hex').padStart(64, '0'),
        nonce: parseInt(tx2.nonce),
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        gasPrice: gasPrice,
        limit: toHex(tx2.gasLimit),
        value: toHex(tx2.value),
        data: '0x' + Buffer.from(tx2.data).toString('hex'),
        v: toHex(tx2.v?.toString() ?? 27),
        r: (tx2.r && toHex(tx2.r)) || '0x',
        s: (tx2.s && toHex(tx2.s)) || '0x',
        chainId: toHex(tx2.common.chainId()),
        accessList: tx2.accessList || [],
    };
}

export function toHex(number, remove_zero = false) {
    let ret = BigNumber(number).toString(16);
    if (remove_zero) {
        while (ret.startsWith('0')) {
            ret = ret.slice(1);
        }
    }
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

export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

export function move2ethAddress(addr) {
    addr = addr.toLowerCase();
    return '0x' + addr.slice(-40);
}
