import { HexString } from 'aptos';
import { toBeHex, ethers } from 'ethers';
import { ROBOT_SENDER_ACCOUNT, client, SERVER_PORT } from './const.js';
import { random } from 'radash';
let evm_bot_sender = null;
async function deposit() {
    const rand = ethers.Wallet.createRandom();
    const alice = rand.privateKey;
    const payload = {
        function: `0x1::aptos_account::transfer`,
        type_arguments: [],
        arguments: [alice, random(1, 100)],
    };
    const provider = new ethers.JsonRpcProvider('http://localhost:' + SERVER_PORT);
    const evmSender = new ethers.Wallet(
        Buffer.from(ROBOT_SENDER_ACCOUNT.authKey().HexString).toString('hex'),
        provider,
    );
    if (!evm_bot_sender) {
        evm_bot_sender = evmSender.address;
        // for debugging
        console.log('Bot evm sender address', evm_bot_sender);
    }
    const tx = {
        to: rand.address,
        value: ethers.parseUnits(random(1, 100), 'gwei'),
    };
    await Promise.allSettled([evmSender.sendTransaction(tx), sendTx(payload)]);
}

function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

async function checkTxResult(tx) {
    const res = await client.getTransactionByHash(tx);
    console.log('tx result ', tx, res['success']);
}

async function sendTx(payload) {
    const txnRequest = await client.generateTransaction(ROBOT_SENDER_ACCOUNT.address(), payload);
    const signedTxn = await client.signTransaction(ROBOT_SENDER_ACCOUNT, txnRequest);
    const transactionRes = await client.submitTransaction(signedTxn);
    await client.waitForTransaction(transactionRes.hash);
    return transactionRes.hash;
}

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
// https://github.com/Uniswap/deploy-v3.git
// Since this project requires block generation to run, here I'm starting a script to generate a block every 2 seconds to achieve the purpose

export async function startBotTask() {
    if (ROBOT_SENDER_ACCOUNT) {
        while (1) {
            try {
                await deposit();
            } catch (e) {
                console.log('Bot task error', e.message);
            }
            await sleep(2000);
        }
    }
}
