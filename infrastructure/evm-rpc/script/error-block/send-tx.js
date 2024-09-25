import { AptosClient, AptosAccount, HexString, BCS } from 'aptos';
const client = new AptosClient('http://localhost:8080');
import readline from 'readline';
import { createReadStream } from 'fs';
export function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

const FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: '',
});

let nonce = 0;
let count = 0;
let skip_count = 0;
async function start(path) {
    const account = await client.getAccount(FAUCET_SENDER_ACCOUNT.address());
    nonce = account.sequence_number;
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
            count++;
            if (count <= skip_count) {
                continue;
            }
            console.log('%s send version start', count, item.version);
            await sendTx(payload, nonce);
            console.log('send version end ', Date.now() - startTs);
            nonce++;
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
start('filtered_transactions2.txt');
