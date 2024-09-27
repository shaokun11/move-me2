import { gql } from '@urql/core';
import { indexer_client } from './const.js';
import { group, mapValues, sort, retry } from 'radash';
import { isAddress } from 'ethers';

export async function getMoveHash(evm_hash) {
    const run = async function () {
        const query = gql`
            {
                evm_move_hash(where:{
                    evm_hash:{
                    _eq:"${evm_hash}"
                    }
                }) {
                    move_hash
                    evm_hash
                }
            }
        `;
        const res = await indexer_client.query(query).toPromise();
        if (res.data.evm_move_hash.length == 0) {
            throw new Error('Transaction not found');
        }
        return res.data.evm_move_hash[0].move_hash;
    };
    // We need to wait for the indexer to sync the transaction info to the database.
    // Currently, the duration is 3 seconds is enough before running the query.
    return await retry({ times: 3, delay: 1000 }, run);
}

export async function getEvmHash(move_hash) {
    const run = async function () {
        const query = gql`
            {
                evm_move_hash(where:{
                    move_hash:{
                    _eq:"${move_hash}"
                    }
                }) {
                    move_hash
                    evm_hash
                }
            }
        `;
        const res = await indexer_client.query(query).toPromise();
        if (res.data.evm_move_hash.length == 0) {
            throw new Error('Transaction not found');
        }
        return res.data.evm_move_hash[0].evm_hash;
    };
    // We need to wait for the indexer to sync the transaction info to the database.
    // Currently, the duration is 3 seconds is enough before running the query.
    return await retry({ times: 3, delay: 1000 }, run);
}

export async function getBlockHeightByHash(block_hash) {
    const run = async function () {
        const query = gql`
            {
                block_metadata_transactions(where: {id: {_eq: "${block_hash}"}}) {
                    block_height
                    id
                }
            }
        `;
        const res = await indexer_client.query(query).toPromise();
        if (res.data.block_metadata_transactions.length == 0) {
            throw new Error('No block found by ' + block_hash);
        }
        return res.data.block_metadata_transactions[0].block_height;
    };
    // the graphql can't found block 0 , so we need to handle it
    if (block_hash == '0x' + '0'.repeat(64)) {
        return 0;
    }
    return await retry({ times: 3, delay: 1000 }, run);
}

export async function getEvmLogs(obj) {
    let topicWhere = '';
    if (obj.topics) {
        for (let i = 0; i < 5; i++) {
            if (obj.topics[i]) {
                let topicArr = [];
                if (Array.isArray(obj.topics[i])) {
                    topicArr = obj.topics[i];
                } else {
                    topicArr.push(obj.topics[i]);
                }
                // Why there need [] but the address doesn't need ? Just for the gql syntax?
                topicWhere += `topic${i}: {_in: [${topicArr.map(x => `"${x.toLowerCase()}"`)}]}\n`;
            }
        }
    }
    const addresses = obj.address.filter(it => isAddress(it));
    let addressWhere = '';
    if (addresses.length > 0) {
        addressWhere = `address: {_in: [${addresses.map(x => `"${x.toLowerCase()}"`)}]}\n`;
    }
    const query = gql`
            {
            evm_logs (where:{
                _and:{
                    block_number:{
                        _gte:${obj.from},
                        _lte:${obj.to}
                    }
                    ${addressWhere}
                    ${topicWhere}
                }
            }) {
                    topic0
                    topic1
                    topic2
                    topic3
                    topic4
                    data
                    address
                    block_number
                    version
                    block_hash
                    transaction_hash
                    log_index
                }
            }
    `;
    const res = await indexer_client.query(query).toPromise();
    const logs = res.data.evm_logs;
    const blockGroup = group(logs, it => parseInt(it.block_number));
    mapValues(blockGroup, v => sort(v, it => parseInt(it.version)));
    return [
        logs.map(it => {
            return {
                version: +it.version,
                hash: it.transaction_hash,
            };
        }),
        logs.map(it => {
            const topics = [];
            for (let i = 0; i < 5; i++) {
                if (it[`topic${i}`].length === 66) {
                    topics.push(it[`topic${i}`]);
                }
            }
            const transactionIndex = blockGroup[it.block_number].findIndex(
                ele => it.transaction_hash === ele.transaction_hash,
            );
            return {
                topics,
                data: it.data,
                address: it.address,
                blockHash: it.block_hash,
                blockNumber: it.block_number,
                transactionHash: it.transaction_hash,
                transactionIndex,
                logIndex: it.log_index,
            };
        }),
    ];
}

export async function getErrorTxMoveHash(evm_hash) {
    const query = gql`
        {
            evm_error_hash(limit: 1, where: {evm_hash: {_eq: "${evm_hash}"}}) {
                move_hash
            }
        }
    `;
    const res = await indexer_client.query(query).toPromise();
    return res.data.evm_error_hash[0];
}

export async function getEvmTransaction(startVersion, count = 20) {
    const query = gql`
        {
            evm_move_hash(limit: ${count}, order_by: {version: asc}, where: {version: {_gt: "${startVersion}"}}) {
                move_hash
                version
            }
        }
    `;
    const res = await indexer_client.query(query).toPromise();
    return res.data.evm_move_hash;
}
