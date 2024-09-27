import 'dotenv/config.js';
import { AptosClient, AptosAccount } from 'aptos';
import { Client, fetchExchange } from '@urql/core';
export const SERVER_PORT = process.env.SERVER_PORT || 8998;
export const CACHE_SERVER_PORT = process.env.CACHE_SERVER_PORT || 8898;

/**
 * NODE_URL is the URL of the node, fetched from environment variables
 */
export const NODE_URL = process.env.NODE_URL;
export const EVM_RAW_TX_URL = process.env.EVM_RAW_TX_URL;
export const EVM_FAUCET_URL = process.env.EVM_FAUCET_URL;
export const EVM_SUMMARY_URL = process.env.EVM_SUMMARY_URL;
export const EVM_NONCE_URL = process.env.EVM_NONCE_URL;
export const REMOTE_CACHE_URL = process.env.REMOTE_CACHE_URL;
export const EVM_FIXED_LOG_URL = process.env.EVM_FIXED_LOG_URL;
/**
 * EVM_SENDER is the sender's address, fetched from environment variables
 */
const EVM_SENDER = (process.env.EVM_SENDER ?? '').split(',');

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
    console.log(`evm sender ${i}: ${account.address().hexString}`);
});
export const GET_SENDER_ACCOUNT = (i = 0) => senderAccounts[i];
export const SENDER_ACCOUNT_COUNT = senderAccounts.length;

export let FAUCET_SENDER_ACCOUNT = null;
if (FAUCET_SENDER) {
    FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
        privateKeyHex: FAUCET_SENDER,
    });
    console.log(`faucet sender: ${FAUCET_SENDER_ACCOUNT.address().hexString}`);
}
export const client = new AptosClient(NODE_URL);
const INDEXER_URL = process.env.INDEXER_URL;
export const indexer_client = new Client({
    url: INDEXER_URL,
    exchanges: [fetchExchange],
});

export const ROBOT_SENDER_ACCOUNT = Boolean(ROBOT_SENDER)
    ? AptosAccount.fromAptosAccountObject({
          privateKeyHex: ROBOT_SENDER,
      })
    : null;
if (ROBOT_SENDER_ACCOUNT) {
    console.log(`robot sender: ${ROBOT_SENDER_ACCOUNT.address().hexString}`);
}

export const RECAPTCHA_SECRET = process.env.RECAPTCHA_SECRET;

export const DISABLE_EVM_SUMMARY_TASK = process.env.DISABLE_EVM_SUMMARY_TASK === 'true';

export const DISABLE_SEND_TX = process.env.DISABLE_SEND_TX === 'true';
export const DISABLE_EVM_ARCHIVE_NODE = process.env.DISABLE_EVM_ARCHIVE_NODE === 'true';
export const DISABLE_CACHE = process.env.DISABLE_CACHE === 'true';
export const DISABLE_BATCH_FAUCET = process.env.DISABLE_BATCH_FAUCET === 'true';

export const MEVM_EVENT = '0x1::evm::ExecResultEvent'; // 0x1::evm::ExecResultEventV2

export const IS_MAIN_NODE = !DISABLE_SEND_TX && !EVM_RAW_TX_URL;

console.log({
    SERVER_PORT,
    NODE_URL,
    EVM_RAW_TX_URL,
    EVM_FAUCET_URL,
    EVM_SUMMARY_URL,
    EVM_NONCE_URL,
    INDEXER_URL,
    FAUCET_AMOUNT,
    CHAIN_ID,
    DISABLE_EVM_SUMMARY_TASK,
    DISABLE_SEND_TX,
    DISABLE_EVM_ARCHIVE_NODE,
    DISABLE_CACHE,
    DISABLE_BATCH_FAUCET,
    IS_MAIN_NODE,
    REMOTE_CACHE_URL,
    EVM_FIXED_LOG_URL,
});
