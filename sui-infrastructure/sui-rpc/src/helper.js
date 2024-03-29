import { HexString } from 'aptos-sui';
import base58 from 'bs58';
import os from 'node:os';
import { execa } from 'execa';
import fs from 'node:fs/promises';
export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

export function hexToDigest(hex) {
    if (hex.startsWith('0x')) {
        hex = hex.slice(2);
    }
    return base58.encode(Buffer.from(hex, 'hex'));
}

export function digestToHex(digest) {
    const buf = base58.decode(digest);
    return '0x' + Buffer.from(buf).toString('hex');
}

export async function decodeSuiTx(tx_data, signature) {
    let platform = os.platform();
    const params = [tx_data];
    if (signature) params.push(signature);
    let p = '';
    if (platform === 'win32') {
        p = 'target/release/sui-transaction-decode.exe';
    } else {
        p = 'target/release/sui-transaction-decode';
    }
    try {
        await fs.access(p, fs.constants.F_OK);
    } catch (e) {
        throw "please run 'cargo build -p ' to build sui transaction decoder binary'";
    }
    const { stdout } = await execa(p, params).catch(e => {
        // console.log(e);
        return -1;
    });
    if (stdout) {
        return JSON.parse(stdout);
    } else {
        throw 'transaction decode failed or signature is invalid';
    }
}
