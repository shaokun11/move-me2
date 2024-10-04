import knex from 'knex';
import { client } from './const.js';
import { getEvmTransaction, getTotalMoveAddress } from './db.js';
import { sleep } from './helper.js';
import { writeFile } from 'node:fs/promises';

// Initialize knex connection
const db = knex({
    client: 'better-sqlite3',
    connection: {
        filename: './db/summary-task-db.sqlite',
    },
    useNullAsDefault: true,
});

let cachedTxCount = 0;
let cachedAddrCount = 0;
let moveWalletCount = 0;
let cachedSyncVersion = 0;
let startTs = 0;

async function initTable() {
    // Create tables if they don't exist
    await db.schema.hasTable('addresses').then(exists => {
        if (!exists) {
            return db.schema.createTable('addresses', table => {
                table.string('address').primary(); // Set address as PRIMARY KEY
            });
        }
    });

    await db.schema.hasTable('summary_meta').then(exists => {
        if (!exists) {
            return db.schema
                .createTable('summary_meta', table => {
                    table.integer('txCount').defaultTo(0);
                    table.integer('syncVersion').defaultTo(0);
                    table.integer('addrCount').defaultTo(0);
                    table.integer('moveWalletCount').defaultTo(0);
                })
                .then(() => {
                    // Insert initial row in summary_meta table
                    return db('summary_meta').insert({
                        txCount: 0,
                        syncVersion: 0,
                        moveWalletCount: 0,
                    });
                });
        }
    });
    const meta = await db('summary_meta').first('txCount', 'syncVersion', 'moveWalletCount', 'addrCount');
    cachedTxCount = meta.txCount || 0;
    cachedSyncVersion = meta.syncVersion || 0;
    moveWalletCount = meta.moveWalletCount || 3743265;
    cachedAddrCount = meta.addrCount || 0;
}

async function store(addressArr, txCount, syncVersion) {
    const uniqueAddresses = [...new Set(addressArr)];
    await db.transaction(async trx => {
        let insertedRows = 0;
        const existingAddresses = await trx('addresses')
            .whereIn('address', uniqueAddresses)
            .select('address');
        const existingAddressSet = new Set(existingAddresses.map(a => a.address));
        const newAddresses = uniqueAddresses.filter(address => !existingAddressSet.has(address));
        if (newAddresses.length > 0) {
            const insertData = newAddresses.map(address => ({ address }));
            await trx('addresses').insert(insertData);
            insertedRows = newAddresses.length;
        }
        cachedAddrCount += insertedRows;
        cachedTxCount += txCount;
        cachedSyncVersion = syncVersion;

        await trx('summary_meta').update({
            txCount: cachedTxCount,
            syncVersion: cachedSyncVersion,
            moveWalletCount: moveWalletCount,
            addrCount: cachedAddrCount,
        });
    });

    await writeFile(
        'tx-summary2.json',
        JSON.stringify({
            txCount: cachedTxCount,
            addrCount: cachedAddrCount,
            moveWalletCount: moveWalletCount,
            time: new Date().toUTCString(),
        }),
    ).catch(() => {});
}

async function run(startVersion) {
    console.log('sync evm info version start:', startVersion);
    const txArr = await getEvmTransaction(startVersion, 5000);
    if (!txArr || txArr.length === 0) {
        await sleep(5);
        return;
    }

    const txInfo = await Promise.all(txArr.map(it => client.getTransactionByHash(it.move_hash)));
    const address = [];
    txInfo.forEach(it => {
        const accounts = it.changes.filter(ele => ele.data?.type === '0x1::evm_storage::AccountStorage');
        accounts.forEach(ele => {
            if (ele.data.data.code === '0x') {
                address.push(ele.address);
            }
        });
    });

    const endVersion = txArr[txArr.length - 1].version;
    await store(address, txArr.length, endVersion);
}

async function getMoveWalletAddressCount() {
    try {
        const count = await getTotalMoveAddress();
        moveWalletCount = count;
    } catch (error) {
        console.error('Error fetching move wallet count', error);
    }
}

export async function startSummaryTask() {
    await initTable();
    while (true) {
        try {
            if (Date.now() - startTs > 1000 * 60 * 10) {
                startTs = Date.now();
                //await getMoveWalletAddressCount();
            }
            const ver = await db('summary_meta').first('syncVersion');
            await run(ver.syncVersion);
        } catch (e) {
            console.log('Summary task error', e.message);
        }
    }
}

startSummaryTask();
