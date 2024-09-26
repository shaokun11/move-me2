import { AptosClient, AptosAccount } from 'aptos';
import { appendFile } from 'fs/promises';
import { setTimeout } from 'timers/promises';
import { parseRawTx } from '../../src/helper.js';
// https://explorer.devnet.imola.movementlabs.xyz/#/txn/0x44a3efe00d15951abc94ea4af07a545029dc58294d17c3e1c7e2e0ad411f94fb/payload?network=testnet
// 0xec65a811ae02ec6c7be112bb7653c794cedfd74400d6baaa194b278c2cfa8129
// version
// 29293904

let client = new AptosClient('http://127.0.0.1:8080/v1');

// the hash of this version : 0x592bc2b5ed2fc48871d5f8001bcc7dc8afa36bd4bba97463cfdd44ac87679d63
// let startVer = 29283365;
// const endVer = 32744115;
// 0xCde46284D32148c4D470fA33BA788710b3d21E89
// 0xb136c8f0EA9D1c3F676f91FeacEA8BF967fDA7d0
const START = {
    start: 29283365,
    delta: 576792,
    end: 32744115,
};
const part = process.argv[2];
const startVer = START.start + START.delta * parseInt(part);
let endVer = START.start + START.delta * (parseInt(part) + 1) - 1;
if (endVer > START.end) {
    endVer = START.end;
}
console.log('will sync from ', startVer, ' to ', endVer);

async function start() {
    let start = startVer;
    while (start < endVer) {
        let end = start + 100;
        if (end > endVer) {
            end = endVer;
        }
        const results = await Promise.all(
            Array.from({
                length: end - start + 1,
            }).map((_, it) => {
                return client.getTransactionByVersion('' + (start + it));
            }),
        );
        let versions = results
            .filter(it => it.type === 'user_transaction' && it.success)
            .map(it => it.version);
        let blockInfo = await Promise.all(versions.map(it => client.getBlockByVersion(it)));
        const txArr = [];
        const faucetTx = [];
        for (let i = 0; i < results.length; i++) {
            const res = results[i];
            if (res.type !== 'user_transaction') continue;
            if (!res.success) continue;
            if (res?.payload?.function === '0x1::evm::send_tx') {
                const tx = parseRawTx(res.payload.arguments[0]);
                // const evt = res.events.find(it => it.type.startsWith('0x1::evm::ExecResultEvent'));
                const block = blockInfo.find(
                    it => +it.first_version < res.version && it.last_version > +res.version,
                );
                // console.log(block);
                const item = {
                    version: res.version,
                    tx: res.payload.arguments[0],
                    from: tx.from,
                    to: tx.to,
                    type: 'tx',
                    ts: Math.trunc(+block.block_timestamp / 1e6),
                    number: +block.block_height,
                    // evt,
                };
                txArr.push(item);
            } else if (res?.payload?.function === '0x1::evm::batch_deposit') {
                faucetTx.push({
                    version: res.version,
                    tx: res.payload.arguments,
                    type: 'faucet',
                });
            }
        }
        console.log(`${start}-${end} ${txArr.length} ${faucetTx.length}`);
        start = end + 1;
        if (txArr.length > 0) {
            await appendFile(part + 'error-tx.txt', JSON.stringify(txArr) + '\n');
        }
        if (faucetTx.length > 0) {
            await appendFile(part + 'error-tx-faucet.txt', JSON.stringify(faucetTx) + '\n');
        }
    }
}
start();
