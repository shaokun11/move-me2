import { AptosClient, AptosAccount } from 'aptos';
import { indexer_client } from '../../src/const.js';
import { appendFile } from 'fs/promises';
import { setTimeout } from 'timers/promises';
import { gql } from '@urql/core';
// https://explorer.devnet.imola.movementlabs.xyz/#/txn/0x44a3efe00d15951abc94ea4af07a545029dc58294d17c3e1c7e2e0ad411f94fb/payload?network=testnet
// 0xec65a811ae02ec6c7be112bb7653c794cedfd74400d6baaa194b278c2cfa8129
// version
// 29283365 ->32744115
// block
// 9723536 -> 10711479
async function getLogs(startVersion, endVersion) {
    const query = gql`
        {
            evm_logs(where: { version: { _gte: ${startVersion}, _lte: ${endVersion} } }) {
                version
                topic0
                topic1
                topic2
                topic3
                data
                topic4
                block_number
                address
                transaction_hash
                block_hash
                log_index
            }
        }
    `;
    const res = await indexer_client.query(query).toPromise();
    return res.data.evm_logs;
}

let startVer = 29283365;
const endVer = 32744115;

async function start() {
    let start = startVer;
    while (start < endVer) {
        let end = start + 2000;
        if (end > endVer) {
            end = endVer;
        }
        const logs = await getLogs(start, end);
        const count = logs.length;
        if (count > 0) {
            await appendFile('error-block-logs.txt', JSON.stringify(logs) + '\n');
        }
        console.log(`${start}-${end} : ${count}`);
        start = end + 1;
        await setTimeout(200);
    }
}

start();
