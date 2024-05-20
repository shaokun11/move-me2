import { AptosClient, AptosAccount } from 'aptos';
import { Client, fetchExchange } from '@urql/core';
export const SERVER_PORT = process.env.SERVER_PORT || 3044;

/**
 * NODE_URL is the URL of the node, fetched from environment variables
 */
export const NODE_URL = process.env.NODE_URL;

/**
 * EVM_SENDER is the sender's address, fetched from environment variables
 */
const EVM_SENDER = process.env.EVM_SENDER;
const FAUCET_SENDER = process.env.FAUCET_SENDER;
const ROBOT_SENDER = process.env.ROBOT_SENDER;

export const FAUCET_AMOUNT = process.env.FAUCET_AMOUNT || 1;
export const FAUCET_LIMIT_DURATION = process.env.FAUCET_LIMIT_DURATION || 24 * 60 * 60;

/**
 * EVM_CONTRACT is the contract address
 */
export const EVM_CONTRACT = '0x1';

/**
 * CHAIN_ID is the ID of the chain
 */
export const CHAIN_ID = 336;

/**
 * ZERO_HASH is a constant representing a hash of all zeros
 */
export const ZERO_HASH = '0x' + '0'.repeat(64);

/**
 * LOG_BLOOM is a constant representing a bloom filter of all zeros
 */
export const LOG_BLOOM = '0x' + '0'.repeat(512);

/**
 * SENDER_ACCOUNT is the sender's account, created from the sender's private key
 */
export const SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: EVM_SENDER,
});

/**
 * SENDER_ADDRESS is the sender's address, fetched from the sender's account
 */
export const SENDER_ADDRESS = SENDER_ACCOUNT.address().hexString;

/**
 * client is an instance of AptosClient, initialized with the node URL
 */
export const client = new AptosClient(NODE_URL);

export const FAUCET_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: FAUCET_SENDER,
});

export const FAUCET_SENDER_ADDRESS = FAUCET_SENDER_ACCOUNT.address().hexString;

export const indexer_client = new Client({
    url: process.env.INDEXER_URL,
    exchanges: [fetchExchange],
});


export const AUTO_SEND_TX = process.env.AUTO_SEND_TX 

export const ROBOT_SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: FAUCET_SENDER || EVM_SENDER,
});

export const ROBOT_SENDER_ADDRESS = FAUCET_SENDER_ACCOUNT.address().hexString;