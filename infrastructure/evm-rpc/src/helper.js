import { ZeroAddress, Transaction } from 'ethers';
import { BigNumber } from 'bignumber.js';
import { randomBytes } from 'node:crypto';
import { HexString } from 'aptos';
import { TransactionFactory } from '@ethereumjs/tx';

export function parseRawTx(tx) {
    const tx_ = Transaction.from(tx);
    const txJson = tx_.toJSON();
    // the ethers parse rsv is not correct , so we need to parse it again
    const tx2 = TransactionFactory.fromSerializedData(Buffer.from(tx.slice(2), 'hex'));
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
//     '0x02f9025a82780c018502540be4008502540be4008302648d8080b901fd6080604052348015600e575f80fd5b506101e18061001c5f395ff3fe608060405234801561000f575f80fd5b506004361061003f575f3560e01c80633fb5c1cb146100435780638381f58a1461005f578063d09de08a1461007d575b5f80fd5b61005d600480360381019061005891906100e4565b610087565b005b610067610090565b604051610074919061011e565b60405180910390f35b610085610095565b005b805f8190555050565b5f5481565b5f808154809291906100a690610164565b9190505550565b5f80fd5b5f819050919050565b6100c3816100b1565b81146100cd575f80fd5b50565b5f813590506100de816100ba565b92915050565b5f602082840312156100f9576100f86100ad565b5b5f610106848285016100d0565b91505092915050565b610118816100b1565b82525050565b5f6020820190506101315f83018461010f565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f61016e826100b1565b91507fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff82036101a05761019f610137565b5b60018201905091905056fea2646970667358221220c0fc660a6ea710e79da030325756297c16376731f4e7bcd5f371b69b97526c4f64736f6c634300081a0033c080a0d5a3876f116fa992d9ad1ea745407ef886f4c6df7d8417c77b3d47e4088d307ba00feeb1c106c96800350e03951d54081c942f64641bb29af6091cf6974e8387f1';
// console.log(parseRawTx(x));

export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

export function move2ethAddress(addr) {
    addr = addr.toLowerCase();
    return '0x' + addr.slice(-40);
}
