import { appendFile } from 'node:fs';
import { FAUCET_AMOUNT, FAUCET_SENDER_ACCOUNT, client } from './const.js';
import { sleep, toBuffer, toHexStrict } from './helper.js';

const FAUCET_QUEUE = [];

let count = 0;

/**
 * Start the batch faucet eth token task
 */
export async function startFaucetTask() {
    const faucet_amount = toBuffer(toHexStrict((FAUCET_AMOUNT * 1e18).toString()));
    while (1) {
        await run(faucet_amount, 100);
        await sleep(2);
        count++;
        if (count % 100 == 0) {
            count = 0;
            break;
        }
    }
    setImmediate(startFaucetTask);
}
/**
 * Add a task to the faucet
 * @param {Object} task - The task object
 * @param {string} task.addr - The address to send the tokens to
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
            function: `0x1::evm::batch_deposit`,
            type_arguments: [],
            arguments: [send_accounts.map(it => toBuffer(it.addr)), send_accounts.map(() => faucet_amount)],
        };
        const ret_msg = {};
        try {
            const expire_time_sec = 60 * 5;
            const txnRequest = await client.generateTransaction(FAUCET_SENDER_ACCOUNT.address(), payload, {
                gas_unit_price: 200,
                expiration_timestamp_secs: Math.floor(Date.now() / 1000) + expire_time_sec,
            });
            const signedTxn = await client.signTransaction(FAUCET_SENDER_ACCOUNT, txnRequest);
            const transactionRes = await client.submitTransaction(signedTxn);
            const res = await client.waitForTransactionWithResult(transactionRes.hash, {
                timeoutSecs: expire_time_sec,
            });
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
                console.error('Faucet EVM error:', res.vm_status);
                // maybe not enough token to faucet
                ret_msg['error'] = 'System error, please try again after 1 min';
            }
        } catch (e) {
            console.error('Faucet EVM error:', e.message || e);
            // maybe network error
            ret_msg['error'] = 'System error, please try again after 5 min';
        }
        send_accounts.forEach(it => {
            it.resolve(ret_msg);
        });
        FAUCET_QUEUE.splice(0, send_accounts.length);
    }
}
