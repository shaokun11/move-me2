import { appendFile } from 'node:fs';
import { FAUCET_AMOUNT, FAUCET_CONTRACT, FAUCET_SENDER_ACCOUNT, client } from './const.js';
import { toBuffer, toHexStrict } from './helper.js';

const FAUCET_QUEUE = [];

export async function startFaucetTask() {
    const faucet_amount = toBuffer(toHexStrict((FAUCET_AMOUNT * 1e18).toString()));
    while (1) {
        await run(faucet_amount, 100);
        await sleep(0.5);
    }
}
/**
 * Add a task to the faucet
 * @param {Object} task - The task object
 * @param {string} task.addr - The address to send the tokens to
 * @param {string} task.ip - The IP address of the user
 */
export function addToFaucetTask(task) {
    return new Promise((resolve, reject) => {
        FAUCET_QUEUE.push({ resolve, reject, ...task });
    });
}

async function run(faucet_amount, batch = 100) {
    const send_accounts = FAUCET_QUEUE.slice(0, batch);
    if (send_accounts.length > 0) {
        const payload = {
            function: `${FAUCET_CONTRACT}::batch_transfer::batch_transfer_evm`,
            type_arguments: [],
            arguments: [send_accounts.map(it => toBuffer(it.addr)), send_accounts.map(() => faucet_amount)],
        };
        const ret_msg = {};
        try {
            const txnRequest = await client.generateTransaction(FAUCET_SENDER_ACCOUNT.address(), payload);
            const signedTxn = await client.signTransaction(FAUCET_SENDER_ACCOUNT, txnRequest);
            const transactionRes = await client.submitTransaction(signedTxn);
            await client.waitForTransaction(transactionRes.hash);
            const res = await client.getTransactionByHash(transactionRes.hash);
            if (res.success) {
                ret_msg['hash'] = res.hash;
                appendFile(
                    'faucet.log',
                    JSON.stringify({
                        hash: res.hash,
                        time: Date.now(),
                        data: send_accounts.map(it => ({
                            addr: it.addr,
                            ip: it.ip,
                        })),
                    }) + '\n',
                    () => {},
                );
            } else {
                // maybe not enough token to faucet
                ret_msg['error'] = 'System error, please try again after 1 min';
            }
        } catch (e) {
            // maybe network error
            ret_msg['error'] = 'System error, please try again after 5 min';
        }
        send_accounts.forEach(it => {
            it.resolve(ret_msg);
        });
        FAUCET_QUEUE.splice(0, send_accounts.length);
    }
}
