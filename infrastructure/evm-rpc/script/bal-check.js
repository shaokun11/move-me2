import { AptosClient } from 'aptos';

const evm_sender = {
    sender: [
        '0x167bf5e7a3135d4d23054bea0605d3c3eb1b8efde51ffbb62994ba8361d05853',
        '0x5a3ad3ef2196cf8b269efd135e3a6bdd06e7d9897d46f2bb357f30200c33d9d3',
        '0x1790163a7821879e3ddd2b1cc14821425c501fa7c2889f27303fda427859d43c',
        '0xd0550f2114672745be5f718219f83a01c6419e70be02505aa7f0057563c0232a',
        '0x8b74c092dd065409ea80becf329e980a121427f5fe7b3eea46a075edf5e48727',
        '0xc12501d0212a60382009587a7025b77976473c0ddedc75f6c2fb650a4d1d4bfd',
    ],
    threshold: 1000 * 1e8,
    amount: 10000 * 1e8,
};

const faucet_sender = {
    sender: [
        '0xa4ca13309eb1b74344928a3ba008ce2cba9dacaac2354a83cd2021f4a78ce455', // evm
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
        const res = await client.getAccountResource(s, APT_TOKEN_TYPE);
        if (parseInt(res.data.coin.value) > task.threshold) {
            console.log(`Sender ${s} has enough balance ${res.data.coin.value / 1e8}`);
            continue;
        } else {
            await fetch(`http://127.0.0.1:8081/fund`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    address: s,
                    amount: task.amount,
                }),
            }).catch(err => {
                console.log(`Error when funding ${s}: ${err.message}`);
            });
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

start();
