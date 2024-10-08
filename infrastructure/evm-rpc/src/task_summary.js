/// for summary all evm wallet address and evm transaction count

import { client } from './const.js';
import { getEvmTransaction, getTotalMoveAddress } from './db.js';
import { JSONFilePreset } from 'lowdb/node';
import { sleep } from './helper.js';
import { writeFile } from 'node:fs/promises';

const db = await JSONFilePreset('db/summary-task-db.json', {
    address: [],
    txCount: 0,
    syncVersion: 0,
    moveWalletCount: 0,
});

let count = 0;
let startTs = 0;
let moveWalletCount = 3743265;

// init the address set
const addressSet = new Set(db.data.address);

async function store(addressArr, txCount, syncVersion) {
    const saveAddress = new Set(addressArr.filter(it => !addressSet.has(it)));
    await db.update(data => {
        if (saveAddress.size > 0) {
            data.address.push(...saveAddress);
            saveAddress.forEach(it => addressSet.add(it));
        }
        data.txCount += txCount;
        data.syncVersion = syncVersion;

        // maybe need provider api to get this data
        writeFile(
            'tx-summary.json',
            JSON.stringify({
                txCount: data.txCount,
                addrCount: addressSet.size,
                moveWalletCount: moveWalletCount,
            }),
        )
            .then(() => {
                // ignore
            })
            .catch(() => {
                // ignore
            });
    });
}

async function run(startVersion) {
    const txArr = await getEvmTransaction(startVersion, 50);
    if (!txArr || txArr.length === 0) {
        // Nothing, we slowly the task
        await sleep(5);
        return;
    }
    // console.log('Get tx count:', txArr.length);
    const txInfo = await Promise.all(txArr.map(it => client.getTransactionByHash(it.move_hash)));
    // get all address
    const address = [];
    txInfo.forEach(it => {
        // If this evm account join the transaction , it's storage must be changed.
        // So we can trace it to found all the evm address
        const accounts = it.changes.filter(ele => ele.data?.type === '0x1::evm_storage::AccountStorage');
        accounts.forEach(ele => {
            if (ele.data.data.code === '0x') {
                // we just need the wallet account
                address.push(ele.address);
            }
        });
    });
    // The last item is the max version , it guarantee by the query
    const endVersion = txArr[txArr.length - 1].version;
    await store(address, txArr.length, endVersion);
}

async function getMoveWalletAddressCount() {
    try {
        const count = await getTotalMoveAddress();
        moveWalletCount = count;
    } catch (error) {}
}

// this could be do it at evm indexers
export async function startSummaryTask() {
    while (1) {
        try {
            if (Date.now() - startTs > 1000 * 60 * 10) {
                startTs = Date.now();
                await getMoveWalletAddressCount();
            }
            const ver = await db.data.syncVersion;
            await run(ver);
        } catch (e) {
            console.log('Summary task error', e.message);
        }
        await sleep(1);
        count++;
        if (count % 100 === 0) {
            count = 0;
            break;
        }
    }
    setImmediate(startSummaryTask);
}

startSummaryTask();
