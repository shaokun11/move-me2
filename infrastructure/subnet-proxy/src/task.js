const aptos = require('aptos');
const { PORT, FAUCET_SENDER } = require('./const');
const client = new aptos.AptosClient(`http://127.0.0.1:${PORT}/v1`);
// client.getLedgerInfo().then(console.log);
const { appendFile } = require('node:fs');
// Create a new account
// const account = new aptos.AptosAccount();
const account = aptos.AptosAccount.fromAptosAccountObject({
    privateKeyHex: FAUCET_SENDER,
});
const FAUCET_QUEUE = [];
faucet_task();

async function faucet_task() {
    const faucet_amount = 10 * 1e8;
    while (1) {
        const send_accounts = FAUCET_QUEUE.slice(0, 100);
        if (send_accounts.length > 0) {
            const payload = {
                function: `0x1::aptos_account::batch_transfer`,
                type_arguments: [],
                arguments: [send_accounts.map(it => it.addr), send_accounts.map(() => faucet_amount)],
            };
            try {
                const txnRequest = await client.generateTransaction(account.address(), payload);
                const signedTxn = await client.signTransaction(account, txnRequest);
                const transactionRes = await client.submitTransaction(signedTxn);
                await client.waitForTransaction(transactionRes.hash);
                const res = await client.getTransactionByHash(transactionRes.hash);
                if (res.success) {
                    for (let it of send_accounts) {
                        it.resolve({
                            data: res.hash,
                        });
                    }
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
                        () => { },
                    );
                } else {
                    // maybe not enough token to faucet
                    for (let it of send_accounts) {
                        it.resolve({
                            error: 'System error, please try again after 1 min',
                        });
                    }
                }
            } catch (e) {
                // maybe network error
                for (let it of send_accounts) {
                    it.resolve({
                        error: 'System error, please try again after 5 min',
                    });
                }
            }
            FAUCET_QUEUE.splice(0, send_accounts.length);
        }
        await new Promise(resolve => setTimeout(resolve, 500));
    }
}

exports.addFaucetTask = async function (addr, ip) {
    return new Promise((resolve, reject) => {
        FAUCET_QUEUE.push({ addr, ip, resolve, reject });
    });
};
