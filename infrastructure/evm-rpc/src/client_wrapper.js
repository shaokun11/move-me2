import BigNumber from 'bignumber.js';
import { client } from './const.js';

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
                            return client.getTransactionByVersion(block.first_version + i + 100);
                        }),
                )),
            );
        }
        return block;
    }
}
