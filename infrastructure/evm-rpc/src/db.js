import { gql } from '@urql/core';
import { indexer_client } from './const.js';
import { group, mapValues, sort, retry } from 'radash';

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
    }
    return await retry({ times: 3, delay: 1000 }, run);

}

export async function getEvmLogs(obj) {
    let topicWhere = '';
    if (obj.topics) {
        for (let i = 0; i < 5; i++) {
            if (obj.topics[i]) {
                topicWhere += `topic${i}: {_eq: "${obj.topics[i]}"}\n`;
            }
        }
    }
    const query = gql`
            {
            evm_logs (where:{
                _and:{
                    block_number:{
                        _gte:${obj.from},
                        _lte:${obj.to}
                    }
                    address:{
                        _in:${obj.address.map(x => `"${x}"`)}
                    }
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
    return logs.map(it => {
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
    });
}
