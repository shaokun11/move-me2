const aptos = require("aptos");
const { toBeHex, ethers } = require("ethers");
const HexString = aptos.HexString;
import { AUTO_SEND_TX, SENDER_ACCOUNT, client } from "./const.js";

async function deposit() {
    const wallet = ethers.Wallet.createRandom()
    const alice = wallet.address
    let payload = {
        function: `0x1::evm::deposit`,
        type_arguments: [],
        arguments: [toBuffer(alice), toBuffer(toBeHex((1e12).toString()))],
    };
    let hash = await sendTx(payload);
    await checkTxResult(hash);
}
function toBuffer(hex) {
    return new HexString(hex).toUint8Array();
}

async function checkTxResult(tx) {
    const res = await client.getTransactionByHash(tx);
    console.log("tx result ", tx, res["success"]);
}

async function sendTx(payload) {
    const txnRequest = await client.generateTransaction(SENDER_ADDRESS, payload);
    const signedTxn = await client.signTransaction(SENDER_ACCOUNT, txnRequest);
    const transactionRes = await client.submitTransaction(signedTxn);
    await client.waitForTransaction(transactionRes.hash);
    return transactionRes.hash;
}

function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}

async function start() {
    while (1) {
        try {
            await deposit();
        } catch (e) { }
        await sleep(2000);
    }
}
// https://github.com/Uniswap/deploy-v3.git
// Since this project requires block generation to run, here I'm starting a script to generate a block every 2 seconds to achieve the purpose
if (AUTO_SEND_TX) {
    start()
}