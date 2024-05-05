import { gql } from '@urql/core';
import { indexer_client } from './const.js';

setTimeout(() => {
    // getMoveHash("0x44e623b81b26d27198f9aa05df51d9614629649b2a5b892535a828ab5ab4f68e")
    // getBlockHeightByHash("0xf8c3af27597d5f80821bfa29a6dda5b2b30d8b892dd85dd6cdb29be17d7bf0a1").then(console.log)
    // getEvmLogs({
    //     from: 1,
    //     to: 18779,
    //     address: ["0xfda50a0ba843c14125efaab5bca4ed860b7a3c88"],
    //     topics: [
    //         "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    //         null,
    //         "0x000000000000000000000000fca2fba9427f9100c14c6c2f175bc9ec744a77cf"
    //     ],
    // }).then(console.log)
}, 1000);

export async function getMoveHash(evm_hash) {
    const query = gql`
        query getHash($data: jsonb) {
            events(where: { _and: { data: { _contains: $data }, type: { _eq: "0x1::evm::TXHashEvent" } } }) {
                data
            }
        }
    `;
    const res = await indexer_client
        .query(query, {
            data: {
                evm_tx_hash: evm_hash,
            },
        })
        .toPromise();
    return res.data.events[0].data.move_tx_hash;
}

export async function getBlockHeightByHash(block_hash) {
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
        throw new Error('No block found');
    }
    return res.data.block_metadata_transactions[0].block_height;
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
                    transaction_hash
                    transaction_index
                }
            }
    `;
    const res = await indexer_client.query(query).toPromise();
    return res.data.evm_logs.map(it => {
        const topics = [];
        for (let i = 0; i < 5; i++) {
            if (it[`topic${i}`].length === 66) {
                topics.push(it[`topic${i}`]);
            }
        }
        return {
            topics,
            data: it.data,
            address: it.address,
            block_number: it.block_number,
            transaction_hash: it.transaction_hash,
            transaction_index: it.transaction_index,
        };
    });
}
