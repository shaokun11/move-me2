import 'dotenv/config.js';
import { AptosClient, AptosAccount } from 'aptos';
import { Client, fetchExchange } from '@urql/core';
export const SERVER_PORT = process.env.SERVER_PORT || 8998;

/**
 * NODE_URL is the URL of the node, fetched from environment variables
 */
export const NODE_URL = process.env.NODE_URL;

/**
 * EVM_SENDER is the sender's address, fetched from environment variables
 */
const EVM_SENDER = (process.env.EVM_SENDER ?? '').split(',');
if (EVM_SENDER.length === 0) {
    console.warn('evm sender is empty and will not be able to send transactions');
}
const FAUCET_SENDER = process.env.FAUCET_SENDER;
const ROBOT_SENDER = process.env.ROBOT_SENDER;

export const FAUCET_AMOUNT = process.env.FAUCET_AMOUNT || 1;
export const CHAIN_ID = 30732;
export const ZERO_HASH = '0x' + '0'.repeat(64);
export const LOG_BLOOM = '0x' + '0'.repeat(512);

const senderAccounts = [];
EVM_SENDER.forEach(privateKeyHex => {
    if (privateKeyHex && privateKeyHex.length === 66) {
        senderAccounts.push(
            AptosAccount.fromAptosAccountObject({
                privateKeyHex,
            }),
        );
    }
});

senderAccounts.forEach((account, i) => {
    console.log(`Sender ${i}: ${account.address().hexString}`);
});
export const GET_SENDER_ACCOUNT = (i = 0) => senderAccounts[i];
export const SENDER_ACCOUNT_COUNT = senderAccounts.length;
export let FAUCET_SENDER_ACCOUNT = null;
if (FAUCET_SENDER) {
    FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
        privateKeyHex: FAUCET_SENDER,
    });
    console.log(`Faucet sender: ${FAUCET_SENDER_ACCOUNT.address().hexString}`);
}
export const client = new AptosClient(NODE_URL);
export const indexer_client = new Client({
    url: process.env.INDEXER_URL,
    exchanges: [fetchExchange],
});

export const ROBOT_SENDER_ACCOUNT = Boolean(ROBOT_SENDER)
    ? AptosAccount.fromAptosAccountObject({
          privateKeyHex: ROBOT_SENDER,
      })
    : null;
if (ROBOT_SENDER_ACCOUNT) {
    console.log(`Robot sender: ${ROBOT_SENDER_ACCOUNT.address().hexString}`);
}

export const ENV_IS_PRO = process.env.NODE_ENV === 'production';
export const START_SUMMARY_TASK = process.env.START_SUMMARY_TASK || false;
export const RECAPTCHA_SECRET = process.env.RECAPTCHA_SECRET;

export const SUMMARY_URL = process.env.SUMMARY_URL;
export const DISABLE_SEND_TX = process.env.DISABLE_SEND_TX === 'true';
export const DISABLE_EVM_ARCHIVE_NODE = process.env.DISABLE_EVM_ARCHIVE_NODE === 'true';
export const DISABLE_CACHE = process.env.DISABLE_CACHE === 'true';
