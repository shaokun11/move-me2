import { AptosClient, AptosAccount, HexString } from 'aptos';
const client = new AptosClient('http://localhost:8080');
import readline from 'readline';
import { createReadStream } from 'fs';
export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

const FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: '0xf238ff22567c56bdaa18105f229ac0dacc2d9f73dfc5bf08a2a2a4a0fac4d220',
});

let SENDER_NONCE = 0;
let SEND_COUNT = 0;
let SKIP_COUNT = 0;
const BATCH_COUNT = 50;
let RUNNING_COUNT = 0;
async function start(path) {
    const account = await client.getAccount(FAUCET_SENDER_ACCOUNT.address());
    SENDER_NONCE = account.sequence_number;
    const lines = [];
    const fileStream = createReadStream(path);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
    });
    for await (const line of rl) {
        if (line.length > 0) {
            // console.log("line", line);
            let item = JSON.parse(line);
            const payload = makePayload(item);
            const startTs = Date.now();
            SEND_COUNT++;
            if (SEND_COUNT <= SKIP_COUNT) {
                continue;
            }
            console.log('%s send version start', SEND_COUNT, item.version);
            await sendTx(payload, SENDER_NONCE);
            console.log('send version end ', Date.now() - startTs);
            SENDER_NONCE++;
        }
    }
    return lines;
}

function makePayload(item) {
    if (item.type === 'faucet') {
        const send_accounts = item.tx[0];
        return {
            function: `0x1::evm::batch_deposit`,
            type_arguments: [],
            arguments: [
                send_accounts.map(it => toBuffer(it)),
                send_accounts.map(() => toBuffer('0x0de0b6b3a7640000')),
            ],
        };
    }
    return {
        function: `0x1::evm::send_tx`,
        type_arguments: [],
        arguments: [toBuffer(item.tx)],
    };
}

async function sendTx(payload, nonce) {
    const isTx = payload.function === '0x1::evm::send_tx';
    const txnRequest = await client.generateTransaction(FAUCET_SENDER_ACCOUNT.address(), payload, {
        max_gas_amount: 2 * 1e6,
        gas_unit_price: 100,
        sequence_number: nonce,
    });
    const signedTxn = await client.signTransaction(FAUCET_SENDER_ACCOUNT, txnRequest);
    const transactionRes = await client.submitTransaction(signedTxn);
    let res = await client.waitForTransactionWithResult(transactionRes.hash);
    console.log('sendTx:', new Date().toISOString(), res.vm_status, res.version, isTx);
}

async function sendTxBatch(payload, nonce) {
    let start = Date.now();
    console.log('start count :', SEND_COUNT);
    //process.exit(1);
    const txnRequest = await client.generateTransaction(FAUCET_SENDER_ACCOUNT.address(), payload, {
        max_gas_amount: 2 * 1e6,
        gas_unit_price: 100,
        sequence_number: nonce,
        expiration_timestamp_secs: Date.now() + 120,
    });
    const signedTxn = await client.signTransaction(FAUCET_SENDER_ACCOUNT, txnRequest);
    const transactionRes = await client.submitTransaction(signedTxn);
    let res = await client.waitForTransactionWithResult(transactionRes.hash, {
        timeoutSecs: 120 + 5,
    });

    console.log('sendTxBatch:', Date.now() - start, res.vm_status, res.version, new Date().toISOString());
    if (!res.success) {
        console.log('run error:', JSON.stringify(res));
        process.exit(1);
    }
    if (RUNNING_COUNT >= 100) {
        // process.exit(1);
    }
}

function makeBatchPayload(item, is_faucet) {
    if (is_faucet) {
        const send_accounts = item.tx[0];
        return {
            function: `0x1::evm::batch_deposit`,
            type_arguments: [],
            arguments: [
                send_accounts.map(it => toBuffer(it)),
                send_accounts.map(() => toBuffer('0x0de0b6b3a7640000')),
            ],
        };
    }
    return {
        function: `0xef484a99792ccba1be68dc29cdad33726f6e6c16817dfff98a7f6a5fa19c9b9b::hello::batch_send`,
        type_arguments: [],
        arguments: [item.map(it => toBuffer(it.tx)), item.length],
    };
}

async function start_batch(path) {
    const account = await client.getAccount(FAUCET_SENDER_ACCOUNT.address());
    SENDER_NONCE = account.sequence_number;
    console.log('start nonce:', SENDER_NONCE);
    const lines = [];
    const fileStream = createReadStream(path);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
    });
    let txArr = [];
    let payload = '';
    const batchSendTx = async () => {
        payload = makeBatchPayload(txArr, false);
        console.log('send count ', txArr.length);
        await sendTxBatch(payload, SENDER_NONCE);
        SENDER_NONCE++;
        SEND_COUNT += txArr.length;
        RUNNING_COUNT += txArr.length;
        txArr = [];
    };
    for await (const line of rl) {
        if (line.length > 0) {
            if (SEND_COUNT < SKIP_COUNT) {
                SEND_COUNT++;
                continue;
            }
            // console.log('line', line);
            const item = JSON.parse(line);
            const is_faucet = item.type === 'faucet';
            let payload = '';

            const sendFaucet = async () => {
                payload = makeBatchPayload(item, true);
                console.log('send count ', 1);
                await sendTxBatch(payload, SENDER_NONCE);
                SENDER_NONCE++;
                SEND_COUNT++;
                RUNNING_COUNT++;
            };

            if (is_faucet) {
                if (txArr.length > 0) {
                    await batchSendTx();
                }
                await sendFaucet();
            } else {
                txArr.push(item);
                if (txArr.length >= BATCH_COUNT) {
                    await batchSendTx();
                }
            }
        }
    }
    if (txArr.length > 0) {
        await batchSendTx();
    }
    return lines;
}

// start('filtered_transactions2.txt');
start_batch('filtered_transactions2.txt');
