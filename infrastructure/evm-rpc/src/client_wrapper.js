import BigNumber from 'bignumber.js';
import { client, NODE_URL } from './const.js';
import { retry } from 'radash';
BigNumber.config({ EXPONENTIAL_AT: 100 });
export class ClientWrapper {
    static async getBlockByVersion(ver, withTx) {
        let res = await this.getBlockByVersionMe(ver);
        if (!withTx) {
            return res;
        }
        return this.getBlockByHeight(res.block_height, true);
    }

    static async getBlockByHeight(height, withTxs) {
        if (!withTxs) {
            return this.getBlockByHeightMe(height, false);
        }
        // this api only return the first 100 transactions
        const block = await this.getBlockByHeightMe(height, true);
        const fetchCount = block.transactions.length;
        let count = BigNumber(block.last_version).minus(block.first_version).toNumber() - fetchCount + 1;
        if (count > 0) {
            block.transactions.push(
                ...(await Promise.all(
                    Array(count)
                        .fill()
                        .map((_, i) => {
                            return this.getTransactionByVersionMe(
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
            return this.getTransactionByHashMe(hash);
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
    static getLedgerInfo() {
        return fetch(NODE_URL).then(response => response.json());
    }

    static getBlockByHeightMe(height, withTxs) {
        return fetch(NODE_URL + '/blocks/by_height/' + height + '?with_transactions=' + withTxs).then(
            response => {
                return response.json();
            },
        );
    }

    static getBlockByVersionMe(ver) {
        return fetch(NODE_URL + '/blocks/by_version/' + ver + '?with_transactions=' + false).then(
            response => {
                return response.json();
            },
        );
    }

    static getTransactionByVersionMe(ver) {
        return fetch(NODE_URL + '/transactions/by_version/' + ver).then(response => {
            return response.json();
        });
    }

    static getTransactionByHashMe(hash) {
        return fetch(NODE_URL + '/transactions/by_hash/' + hash).then(response => {
            return response.json();
        });
    }
    static getAccount(account) {
        return fetch(NODE_URL + '/accounts/' + account).then(response => {
            return response.json();
        });
    }

    static submitTransaction(tx) {
        return fetch(NODE_URL + '/transactions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x.aptos.signed_transaction+bcs',
                accept: 'application/json',
            },
            body: tx,
        }).then(response => {
            return response.json();
        });
    }

    static getAccountResource(address, source, ledger_version) {
        let url = NODE_URL + `/accounts/${address}/resource/${source}`;
        if (ledger_version?.ledger_version) {
            url = url + `?ledger_version=${ledger_version.ledger_version}`;
        }
        return fetch(url).then(response => {
            return response.json();
        });
    }

    static view(payload, ledger_version) {
        // const controller = new AbortController();
        // const signal = controller.signal;
        // const timeout = setTimeout(() => {
        //     controller.abort();
        // }, 120 * 1000);
        let url = NODE_URL + '/view';
        if (ledger_version) {
            url = NODE_URL + '/view?ledger_version=' + ledger_version;
        }
        return fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            // signal: signal,
            body: JSON.stringify(payload),
        }).then(response => {
            // clearTimeout(timeout);
            return response.json();
        });
    }
}
