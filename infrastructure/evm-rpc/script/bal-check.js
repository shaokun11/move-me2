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
        '0xda3e05ec3191418a3400108cf5df18de88fea4df81b2778c08bc88e097b5496a',
        '0x5f2917124492550112afd2e2fba9eaae403419d33102ebdccf5a9ed7ca14838a',
        '0x32d77fb2f14342e17c77f5044b6ff00bf02a4974b951c7afa364f33c59fe8f11',
        '0xa363fb89d4338d4e0cd0c111b72b72b91162cfb03bd6be813e7fa172402a94e7',
        '0xe539548d86189b3b54c0f2e0b878be9a9f64a96ffefb32acbd6d786d1367dfb2',
        '0xe5b94f4815aa17b3ab5a779e39d53d8c0b4bcdfb30802d5efbb69f90fb857404',
        '0xe814c1dfac240a7cfba2aeaabb4611f7227a7fde069edf5b49828166a3134899',
        '0x27a8eccee9a4ee778327005ff07d260c867bc58ee46e0139bd252c263becb498',
        '0x78de982fc794ba3b3044db7ce5fc954293b9cf5e15568cbea4ad6ae8787f31ca',
        '0xf60ccbead4262d49928ebf963aba69ccf15ea83f520ab4b84639f4c1054f2657',
        "0x70e1724d70d1e51a311f394ea3891ea6092e63c9f4cdba1f920c91c336a367e5",
        "0x5094388f4dfcd73157b7f63a4c9b8153079ff42cbf6f5dd2aa9b9fd5c88a066a",
        "0x03002857fb53301a5dc8d664fde089a22219a159a1226e5145a51850e81cae00",
        "0xc11e75f4ea863b29849142cfffee79fa4c2901bc9382354bfbe40df6b74dfdf1",
        "0xef276ea2c35622b2a2f8a8b1cdc789fd582182b5d15ddc38f523c67f412cc446",
        "0xb4be3a5ada5f554d5c4ac015ace365afc18bc23957c3d44a63379de4014be7de",
        "0x9c348956044d6b8891228f39866b621bd56eb5188b4c8c16cf4dd5412653bbaa",
        "0x0d8eada04779c748a2f5c1403c83ef550c10571cf322f6e6c66680d2cac02356",
        "0xff4912c74bbf608c542e21769d7004ae295c40e2badf4e994e8528b823867aaa",
        "0xa180d7d7fb9f00e60a610041fb0e6213c6932d12f6f16d9d1f58cbc178f7d475",
        /**********        for sync node-1 sender                          */
        '0xdaee19bf07c589088947f5aaeeb2ac83755c60e8abcee84696be50a6c90aa4b5',
        '0x4ff4cfeacf38acec73e9a31e2cf17f607ca867606468cd54f01eb5fe04c111fb',
    ],
    threshold: 100 * 1e8,
    amount: 10000 * 1e8,
};

const faucet_sender = {
    sender: [
        '0xa4ca13309eb1b74344928a3ba008ce2cba9dacaac2354a83cd2021f4a78ce455', // base node 1 evm
        '0x43f1fa2559bb529ea189b4d582532306be79a5fe7b33a4f1fffc29b33aa18e42', // move
    ],
    threshold: 100 * 1e8,
    amount: 100000 * 1e8,
};

const bot_sender = {
    sender: [
        '0x84c0c08fa39d89989dc7a790ef97add425e82e203d4a2e1c19630d66b5d37d1a', // for move bot
    ],
    threshold: 100 * 1e8,
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

start();
