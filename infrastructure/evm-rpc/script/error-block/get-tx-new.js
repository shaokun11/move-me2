import { AptosClient } from 'aptos';
import { appendFile } from 'fs/promises';
import { parseRawTx } from '../../src/helper.js';
// https://explorer.devnet.imola.movementlabs.xyz/#/txn/0x44a3efe00d15951abc94ea4af07a545029dc58294d17c3e1c7e2e0ad411f94fb/payload?network=testnet
// 0xec65a811ae02ec6c7be112bb7653c794cedfd74400d6baaa194b278c2cfa8129
// version
// 29293904

let client = new AptosClient('http://127.0.0.1:8080/v1');

const START = {
    start: 29297290,
    delta: 29297290,
    end: 29708060,
};
const part = process.argv[2];
const startVer = START.start + START.delta * parseInt(part);
let endVer = START.start + START.delta * (parseInt(part) + 1) - 1;
if (endVer > START.end) {
    endVer = START.end;
}
console.log('will sync from ', startVer, ' to ', endVer);

const SENDER_FUN = '0xef484a99792ccba1be68dc29cdad33726f6e6c16817dfff98a7f6a5fa19c9b9b::hello::batch_send';

async function start() {
    let start = startVer;
    while (start < endVer) {
        let end = start + 300;
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
        const txArr = [];
        const faucetTx = [];
        const txArrRaw = [];
        let evtArrRaw = [];

        for (let i = 0; i < results.length; i++) {
            const res = results[i];
            if (res.type !== 'user_transaction') continue;
            if (res?.payload?.function === SENDER_FUN) {
                txArrRaw.push(...res.payload.arguments[0]);
                evtArrRaw = res.events.filter(it => it.type.startsWith('0x1::evm::ExecResultEvent'));
            }
        }

        for (let i = 0; i < evtArrRaw.length; i++) {
            const evt = evtArrRaw[i];
            if (evt?.data?.exception === '200') {
                const tx = parseRawTx(txArrRaw[i]);
                txArr.push({
                    hash: tx.hash,
                    event: evt.data,
                });
            }
        }
        console.log(`${start}-${end} ${txArr.length} ${faucetTx.length}`);
        start = end + 1;
        if (txArr.length > 0) {
            await appendFile(part + 'correct-tx.txt', JSON.stringify(txArr) + '\n');
        }
    }
}
start();
