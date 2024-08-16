import BigNumber from 'bignumber.js';
import { client } from './const.js';
import { DB_TX } from './leveldb_wrapper.js';

export class ClientWrapper {
    static async getBlockByHeight(height, withTxs) {
        const key = `move:block:${height}`;
        const value = await DB_TX.get(key);
        if (value) {
            const block = JSON.parse(value);
            if (!withTxs) {
                block.transactions = null;
            }
            return block;
        }
        // this api only return the first 100 transactions
        //  end 12616241
        //  start 12616111
        //  12616111 12616210
        const block = await client.getBlockByHeight(height, true);
        let count = BigNumber(block.last_version).minus(block.first_version).toNumber() - 100 + 1;
        if (count > 0) {
            block.transactions.push(
                ...(await Promise.all(
                    Array(count)
                        .fill()
                        .map((_, i) => {
                            return client.getTransactionByVersion(block.first_version + i + 100);
                        }),
                )),
            );
        }
        await DB_TX.put(key, JSON.stringify(block));
        if (!withTxs) {
            block.transactions = null;
            return block;
        }
        return block;
    }
}
