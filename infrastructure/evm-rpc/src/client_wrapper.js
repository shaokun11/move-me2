import BigNumber from 'bignumber.js';
import { client } from './const.js';
import { retry } from 'radash';
BigNumber.config({ EXPONENTIAL_AT: 100 });
export class ClientWrapper {
    static async getBlockByHeight(height, withTxs) {
        if (!withTxs) {
            return client.getBlockByHeight(height, false);
        }
        // this api only return the first 100 transactions
        const block = await client.getBlockByHeight(height, true);
        const fetchCount = block.transactions.length;
        let count = BigNumber(block.last_version).minus(block.first_version).toNumber() - fetchCount + 1;
        if (count > 0) {
            block.transactions.push(
                ...(await Promise.all(
                    Array(count)
                        .fill()
                        .map((_, i) => {
                            return client.getTransactionByVersion(
                                BigNumber(block.first_version)
                                    .plus(fetchCount + i)
                                    .toFixed(0),
                            );
                        }),
                )),
            );
        }
        return block;
    }

    static getTransactionByHash(hash) {
        const run = () => {
            return client.getTransactionByHash(hash);
        };
        // for some node may not sync to the latest block, we need to retry
        return retry(
            {
                times: 10,
                delay: 1000,
            },
            run,
        );
    }
}
