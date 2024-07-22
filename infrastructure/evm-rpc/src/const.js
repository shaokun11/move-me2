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
const EVM_SENDER = process.env.EVM_SENDER.split(',');
const FAUCET_SENDER = process.env.FAUCET_SENDER;
const ROBOT_SENDER = process.env.ROBOT_SENDER;

export const FAUCET_AMOUNT = process.env.FAUCET_AMOUNT || 1;

/**
 * CHAIN_ID is the ID of the chain
 */
export const CHAIN_ID = 30732;

/**
 * ZERO_HASH is a constant representing a hash of all zeros
 */
export const ZERO_HASH = '0x' + '0'.repeat(64);

/**
 * LOG_BLOOM is a constant representing a bloom filter of all zeros
 */
export const LOG_BLOOM = '0x' + '0'.repeat(512);

const senderAccounts = EVM_SENDER.map(privateKeyHex =>
    AptosAccount.fromAptosAccountObject({
        privateKeyHex,
    }),
);
senderAccounts.forEach((account, i) => {
    console.log(`Sender ${i}: ${account.address().hexString}`);
});
export const GET_SENDER_ACCOUNT = (i = 0) => senderAccounts[i];
export const SENDER_ACCOUNT_COUNT = senderAccounts.length;
export const FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: FAUCET_SENDER,
});
console.log(`Faucet sender: ${FAUCET_SENDER_ACCOUNT.address().hexString}`);
export const client = new AptosClient(NODE_URL);
export const indexer_client = new Client({
    url: process.env.INDEXER_URL,
    exchanges: [fetchExchange],
});

export const AUTO_SEND_TX = process.env.START_TASK_ROBOT || false;

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
