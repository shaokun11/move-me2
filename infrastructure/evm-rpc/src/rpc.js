import { toHex } from './helper.js';
import { CHAIN_ID } from './const.js';
import {
    callContract,
    estimateGas,
    getBalance,
    getBlock,
    getBlockByHash,
    getBlockByNumber,
    getCode,
    getGasPrice,
    getNonce,
    getStorageAt,
    getTransactionByHash,
    getTransactionReceipt,
    sendRawTx,
    faucet,
    getLogs,
    eth_feeHistory,
    get_move_hash,
    traceTransaction,
    getMoveAddress,
    batch_faucet,
    getBlockReceipts,
    getEvmSummary
} from './bridge.js';
import JsonRpc from 'json-rpc-2.0';
const { JSONRPCErrorException } = JsonRpc;
import { AbiCoder } from 'ethers';
import { vmErrors } from './vm_error.js';

function checkCall(res) {
    if (!res.success) {
        let msg = 'execution reverted';
        let data = res.message;
        if (res.code === '209') {
            if (res.message.startsWith('0x08c379a0')) {
                // evm revert with reason
                try {
                    const coder = new AbiCoder();
                    const decodeMsg = coder.decode(['string'], '0x' + res.message.slice(10));
                    data = res.message;
                    msg = decodeMsg[0];
                } catch (e) {}
            } else {
                // The solidity error type, we keep it as the original message
                msg = 'execution reverted';
                data = res.message;
            }
        } else {
            if (vmErrors[parseInt(res.code)]) {
                msg = vmErrors[parseInt(res.code)];
            }
        }
        throw new JSONRPCErrorException(msg, -32000, data);
    }
}

export const rpc = {
    admin_getEvmTxSummary: async function () {
        return getEvmSummary();
    },
    debug_traceTransaction: async function (args) {
        const caller = args[1]?.tracer || 'callTracer';
        if (caller !== 'callTracer') {
            throw 'Only callTracer is supported';
        }
        return traceTransaction(args[0]);
    },

    /**
     * Use the evm tx hash to get the move hash ,It useful to find the raw tx on the move explorer
     * @returns
     */
    debug_getMoveHash: async function (args) {
        return get_move_hash(args[0]);
    },

    /**
     * @deprecated
     *  Now it is same as the evm address , we keep it for compatibility
     * @returns
     */
    debug_getMoveAddress: async function (args) {
        return getMoveAddress(args[0]);
    },

    /**
     * Fixed value to compatible with the evm
     */
    eth_feeHistory: async function (args) {
        return eth_feeHistory();
    },
    eth_getLogs: async function (args) {
        return getLogs(args[0]);
    },
    /**
     * Fixed value to compatible with the evm
     */
    web3_clientVersion: async function () {
        return 'Geth/v1.11.6-omnibus-f83e1598/linux-.mdx64/go1.20.3';
    },
    /**
     * Returns the chain ID in hexadecimal format.
     * @returns {Promise<string>} The chain ID.
     */
    eth_chainId: async function () {
        return toHex(CHAIN_ID);
    },

    /**
     * Returns the version number in hexadecimal format.
     * @returns {Promise<string>} The version number.
     */
    net_version: async function () {
        return toHex(CHAIN_ID);
    },

    /**
     * Retrieves the current gas price.
     * @returns {Promise<number>} The current gas price.
     */
    eth_gasPrice: async function () {
        return getGasPrice();
    },

    /**
     * Retrieves the latest block number.
     * @returns {Promise<number>} The latest block number.
     */
    eth_blockNumber: async function () {
        return getBlock();
    },

    /**
     * Sends a signed raw transaction.
     * @param {Array<string>} args - The arguments array, where the first element is the signed transaction data.
     * @returns {Promise<string>} The transaction hash.
     * @throws Will throw an error if the transaction fails.
     */
    eth_sendRawTransaction: async function (args) {
        try {
            return await sendRawTx(args[0]);
        } catch (error) {
            if (typeof error === 'string') {
                throw new Error(error);
            }
            throw new Error(error.message || 'execution reverted');
        }
    },

    /**
     * Invokes a method of a smart contract.
     * @param {Array<Object>} args - The arguments array, where the first element is an object containing the 'from', 'to', and 'data' properties.
     * @returns {Promise<string>} The result of the contract method invocation.
     * @throws Will throw an error if the contract method invocation fails.
     */
    eth_call: async function (args) {
        let { to, data, from, value } = args[0];
        // for cast cast 0.2.0 (23700c9 2024-05-22T00:16:24.627116943Z)
        // the data is in the input field
        if (!data) data = args[0].input;
        if (!value || value === '0x') value = '0x0';
        let res = await callContract(from, to, data, value, args[1]);
        checkCall(res);
        return res.message;
    },

    /**
     * Get the transaction count for a given address
     * @param {Array} args - The arguments array, where args[0] is the address
     * @returns {Promise} - A promise that resolves to the transaction count
     */
    eth_getTransactionCount: async function (args) {
        return getNonce(args[0]);
    },

    /**
     * Get a transaction by its hash
     * @param {Array} args - The arguments array, where args[0] is the transaction hash
     * @returns {Promise} - A promise that resolves to the transaction object
     */
    eth_getTransactionByHash: async function (args) {
        return getTransactionByHash(args[0], args[1]);
    },

    /**
     * Get the receipt of a transaction by its hash
     * @param {Array} args - The arguments array, where args[0] is the transaction hash
     * @returns {Promise} - A promise that resolves to the transaction receipt object
     */
    eth_getTransactionReceipt: async function (args) {
        return getTransactionReceipt(args[0]);
    },

    /**
     * Estimate the gas required to execute a transaction
     * @param {Array} args - The arguments array, where args[0] is the transaction object
     * @returns {Promise} - A promise that resolves to the estimated gas
     */
    eth_estimateGas: async function (args) {
        let res = await estimateGas(args[0]);
        checkCall(res);
        return toHex(res.gas_used);
    },

    /**
     * Get a block by its number
     * @param {Array} args - The arguments array, where args[0] is the block number
     * @returns {Promise} - A promise that resolves to the block object
     */
    eth_getBlockByNumber: async function (args) {
        return getBlockByNumber(args[0], args[1] || false);
    },

    /**
     * Get a block by its hash
     * @param {Array} args - The arguments array, where args[0] is the block hash
     * @returns {Promise} - A promise that resolves to the block object
     */
    eth_getBlockByHash: async function (args) {
        return getBlockByHash(args[0], args[1] || false);
    },

    /**
     * Get the balance of an address
     * @param {Array} args - The arguments array, where args[0] is the address
     * @param {Object} ctx - The context object
     * @returns {Promise} - A promise that resolves to the balance
     */
    eth_getBalance: async function (args) {
        return getBalance(args[0], args[1]);
    },

    /**
     * Get the code at a specific address
     * @param {Array} args - The arguments array, where args[0] is the address
     * @returns {Promise} - A promise that resolves to the code
     */
    eth_getCode: async function (args) {
        return getCode(args[0]);
    },

    /**
     * Get the storage at a specific position in a specific address
     * @param {Array} args - The arguments array, where args[0] is the address and args[1] is the storage position
     * @returns {Promise} - A promise that resolves to the storage value
     */
    eth_getStorageAt: async function (args) {
        return getStorageAt(args[0], args[1]);
    },
    eth_getBlockReceipts: async function (args) {
        return getBlockReceipts(args[0]);
    },
    /**
     * For development purpose, to get some test token
     */
    eth_faucet: async function (args, ctx) {
        return faucet(args[0], ctx.ip);
    },
    /**
     * Use google recaptcha to implement the faucet
     */
    eth_batch_faucet: async function (args, ctx) {
        return batch_faucet(args[0], ctx.token, ctx.ip);
    },
    /**
     * Maybe should remove it, some client may use it
     * @returns
     */
    eth_accounts: async function (args) {
        return [];
    },
};
