import BigNumber from 'bignumber.js';
import { client } from './const.js';
BigNumber.config({ EXPONENTIAL_AT: 100 });
export class ClientWrapper {
    static async getBlockByHeight(height, withTxs) {
        if (!withTxs) {
            return client.getBlockByHeight(height, false);
        }
        // this api only return the first 100 transactions
        const block = await client.getBlockByHeight(height, true);
        let count = BigNumber(block.last_version).minus(block.first_version).toNumber() - 100 + 1;
        if (count > 0) {
            block.transactions.push(
                ...(await Promise.all(
                    Array(count)
                        .fill()
                        .map((_, i) => {
                            return client.getTransactionByVersion(
                                BigNumber(block.first_version)
                                    .plus(100 + i)
                                    .toFixed(0),
                            );
                        }),
                )),
            );
        }
        return block;
    }
}
