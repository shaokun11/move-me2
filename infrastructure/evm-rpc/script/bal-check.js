import { AptosClient } from 'aptos';

const evm_sender = {
    sender: [
        /** for base node sender */
        '0x167bf5e7a3135d4d23054bea0605d3c3eb1b8efde51ffbb62994ba8361d05853',
        '0x5a3ad3ef2196cf8b269efd135e3a6bdd06e7d9897d46f2bb357f30200c33d9d3',
        '0x1790163a7821879e3ddd2b1cc14821425c501fa7c2889f27303fda427859d43c',
        '0xd0550f2114672745be5f718219f83a01c6419e70be02505aa7f0057563c0232a',
        '0x8b74c092dd065409ea80becf329e980a121427f5fe7b3eea46a075edf5e48727',
        '0xc12501d0212a60382009587a7025b77976473c0ddedc75f6c2fb650a4d1d4bfd',
        '0x206f16b6d685c804236a7e64a202029fa1866402134b93f6e199d4108f5595c3',
        '0x1f565d5b45b9976a0ae73eb675b31625d1da9939a25c5ec829ffd564d6a0bebb',
        '0xb7293fa5b8ad8b89c70f9b329946286453235b63a8ebe1b62f6fa4e103a7fc12',
        '0x184df25baa560c9fac901d71147f8b0da3e75967e342cf0308749a416e00bdc6',
        /** for base node sender  2 */
        '0xd8b4bff3c6678cd3cea9c89fd66626f74eec5b3fab4d17f9312d243807a02e48',
        '0x2acbc25fb5fde0dd8f8055d08887c828a8e5318ff6761884b62a8a1eb9535c0a',
        '0x9350d69fddea50008f9d2ac82dc0c38e2ab257e5fed4f3954b5dfcaed0a84034',
        '0x470b3a02a621b7cc456bf63879f39d7cc71c6ec9fe51dcf05c7c944d2dae48dc',
        '0xdd23c83c517ddb9600c93381b5f617180ff92273fc210e79abfb783a920d88ba',
        '0xae7622da2ff4f4dfd57321a52adfa1ae3b2792214f3072ff5b9dc1f998848481',
        '0x36f86ebf12f6711973ed90af878d9667626fd0983d9547c1c626a701cb950392',
        '0x2ac5ccf29419dfc7caf97544fa05a8c3954aef234077f97a194a800f03ec9815',
        '0x1938ff1ea78f4a45b319accf86ce9dd8bdf8200c6220804497f97b26c172b4f8',
        '0xd881ba68225d34293c174a48c3e5bd6a733410889bdde9ee3a5dc8d6ef915d10',
        
        /**********        for sync node-1 sender                          */
        '0xdaee19bf07c589088947f5aaeeb2ac83755c60e8abcee84696be50a6c90aa4b5',
        '0x4ff4cfeacf38acec73e9a31e2cf17f607ca867606468cd54f01eb5fe04c111fb',
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
                .then(res => {
                    console.log(`Funding ${s} with ${task.amount / 1e8}`);
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

start();
