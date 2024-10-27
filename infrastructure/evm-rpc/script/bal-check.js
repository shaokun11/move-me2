import { AptosClient } from 'aptos';
import { SENDER_ACCOUNT_COUNT, GET_SENDER_ACCOUNT } from '../src/const.js';

const evm_sender = {
    sender: [
        /**********        for sync node-1 sender                          */
        '0xdaee19bf07c589088947f5aaeeb2ac83755c60e8abcee84696be50a6c90aa4b5',
        '0x4ff4cfeacf38acec73e9a31e2cf17f607ca867606468cd54f01eb5fe04c111fb',
    ],
    threshold: 1000 * 1e8,
    amount: 10000 * 1e8,
};

async function loadBaseSender() {
    /** for base node sender */
    for (let i = 0; i < SENDER_ACCOUNT_COUNT; i++) {
        const sender = GET_SENDER_ACCOUNT(i);
        evm_sender.sender.push(sender.address().hexString);
    }
}

const faucet_sender = {
    sender: [
        '0xa4ca13309eb1b74344928a3ba008ce2cba9dacaac2354a83cd2021f4a78ce455', // base node 1 evm
        '0x43f1fa2559bb529ea189b4d582532306be79a5fe7b33a4f1fffc29b33aa18e42', // move
    ],
    threshold: 1000 * 1e8,
    amount: 100000 * 1e8,
};

const bot_sender = {
    sender: [
        '0x84c0c08fa39d89989dc7a790ef97add425e82e203d4a2e1c19630d66b5d37d1a', // for move bot
    ],
    threshold: 1000 * 1e8,
    amount: 10000 * 1e8,
};
const url = 'http://localhost:8080';
const client = new AptosClient(url);

const APT_TOKEN_TYPE = '0x1::coin::CoinStore<0x1::aptos_coin::AptosCoin>';

async function run(task) {
    const sender = task.sender;
    for (const s of sender) {
        const requestToken = async () => {
            await fetch(`http://127.0.0.1:8081/fund`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    address: s,
                    amount: task.amount,
                }),
            })
                .then(res => res.json())
                .then(res => {
                    console.log(`Funding ${s} with ${task.amount / 1e8} ${res.hash}`);
                })
                .catch(err => {
                    console.log(`Error when funding ${s}: ${err.message}`);
                });
        };
        try {
            const res = await client.getAccountResource(s, APT_TOKEN_TYPE);
            if (parseInt(res.data.coin.value) > task.threshold) {
                console.log(`Sender ${s} has enough balance ${res.data.coin.value / 1e8}`);
                continue;
            } else {
                await requestToken();
            }
        } catch (error) {
            // the first time resource not found
            if (error?.message?.includes('Resource not found')) {
                await requestToken();
            }
        }
    }
}

async function start() {
    try {
        console.log('Start checking evm sender balance');
        await run(evm_sender);
        console.log('Start checking faucet balance');
        await run(faucet_sender);
        console.log('Start checking bot balance');
        await run(bot_sender);
    } catch (error) {
        console.log(`Error when checking balance: ${error.message}`);
    }
    setTimeout(start, 60 * 1000);
}
loadBaseSender().then(start);
