import BigNumber from 'bignumber.js';
import { client, NODE_URL } from './const.js';
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
    
    static getTransactionByHashMe(hash) {
        return fetch(NODE_URL + '/transactions/by_hash/' + hash).then(response => {
            return response.json();
        });
    }

    static view(payload, ledger_version) {
        const controller = new AbortController();
        const signal = controller.signal;
        const timeout = setTimeout(() => {
            controller.abort();
        }, 120 * 1000);
        let url = NODE_URL + '/view';
        if (ledger_version) {
            url = NODE_URL + '/view?ledger_version=' + ledger_version;
        }
        return fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            signal: signal,
            body: JSON.stringify(payload),
        }).then(response => {
            clearTimeout(timeout);
            return response.json();
        });
    }
}
