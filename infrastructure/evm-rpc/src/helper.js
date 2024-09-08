import { ZeroAddress, Transaction } from 'ethers';
import { BigNumber } from 'bignumber.js';
import { randomBytes } from 'node:crypto';
import { HexString } from 'aptos';
import { TransactionFactory } from '@ethereumjs/tx';

export function parseRawTx(tx) {
    let tx_;
    let tx2;
    try {
        tx_ = Transaction.from(tx);
        // the ethers parse rsv is not correct , so we need to parse it again
        tx2 = TransactionFactory.fromSerializedData(Buffer.from(tx.slice(2), 'hex'));
    } catch (error) {
        throw new Error('Invalid transaction');
    }
    const txJson = tx_.toJSON();
    const from = tx_.from.toLowerCase();
    let gasPrice = null;
    let maxPriorityFeePerGas = null;
    let maxFeePerGas = null;
    if (txJson.gasPrice) {
        gasPrice = toHex(txJson.gasPrice);
    }
    if (txJson.maxPriorityFeePerGas) {
        maxPriorityFeePerGas = toHex(txJson.maxPriorityFeePerGas);
    }
    if (txJson.maxFeePerGas) {
        maxFeePerGas = toHex(txJson.maxFeePerGas);
    }
    return {
        hash: tx_.hash,
        nonce: txJson.nonce,
        from: from,
        maxPriorityFeePerGas: maxPriorityFeePerGas,
        maxFeePerGas: maxFeePerGas,
        type: toHex(txJson.type || 0),
        messageHash: tx_.unsignedHash,
        accessList: txJson.accessList,
        gasPrice: gasPrice,
        limit: toHex(txJson.gasLimit),
        to: txJson.to?.toLowerCase() || ZeroAddress,
        value: toHex(txJson.value),
        data: txJson.data || '0x',
        v: toHex(tx2.v?.toString() ?? 27),
        r: (tx2.r && toHex(tx2.r)) || '0x',
        s: (tx2.s && toHex(tx2.s)) || '0x',
        chainId: +txJson.chainId,
        accessList: txJson.accessList,
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

// let x =
//     '0x02f904b582780c048502540be4008502540be400834b482a94b1dadd5b6ca0880b20051c66bbbe7be9aad813dc80b90444a78563a4515be62244e966be715cdd306701b20a14e0310aaa49ace7e06f0b42193a4446000000000000000000000000000000000000000000000000000000000000016000000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000066d4c3100000000000000000000000000000000000000000000000000000000066d6141800000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000340000000000000000000000000000000000000000000000000000000000000006400000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000016345785d8a000000000000000000000000000000000000000000000000000000000000000000024b4b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000008000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000014000000000000000000000000000000000000000000000000000000000000000065465616d2031000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065465616d2032000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065465616d2033000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065465616d2034000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c568747470733a2f2f666972656261736573746f726167652e676f6f676c65617069732e636f6d2f76302f622f62726b742d65373065362e61707073706f742e636f6d2f6f2f636f6d7065746974696f6e25324631626164313737622d313964312d343933392d613165652d61326465633634623131373025324662726b742d64656661756c742d696d6167652e706e673f616c743d6d6564696126746f6b656e3d38626332623564332d646530342d343034612d393065642d353039626465616563373563000000000000000000000000000000000000000000000000000000c001a04d2a34666afc4b9cd7841a7eb69bb205ffc3a9cc8d2ed5264d07ea1307aa2649a01b7460f3f3b0fb81be140fbd0ab5f34d664a750b379f52f54c2414677fd01220';
// const tx = parseRawTx(x);
// console.log(tx);
// console.log(tx.to === ZeroAddress);
// console.log(parseInt(tx.limit) > 25_00_000 * 1.4);

export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

export function move2ethAddress(addr) {
    addr = addr.toLowerCase();
    return '0x' + addr.slice(-40);
}
