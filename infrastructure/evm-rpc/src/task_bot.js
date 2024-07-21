import { HexString } from 'aptos';
import { toBeHex, ethers } from 'ethers';
import { ROBOT_SENDER_ACCOUNT, client } from './const.js';

async function deposit() {
    const wallet = ethers.Wallet.createRandom();
    const alice = wallet.privateKey;
    let payload = {
        function: `0x1::aptos_account::transfer`,
        type_arguments: [],
        arguments: [alice, 1],
    };
    let hash = await sendTx(payload);
    // console.log(' deposit to ', alice)
    // await checkTxResult(hash);
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
            } catch (e) {}
            await sleep(2000);
        }
    }
}
