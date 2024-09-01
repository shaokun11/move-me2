import {
    GET_SENDER_ACCOUNT,
    client,
    ZERO_HASH,
    LOG_BLOOM,
    CHAIN_ID,
    SENDER_ACCOUNT_COUNT,
    EVM_SUMMARY_URL,
    DISABLE_EVM_ARCHIVE_NODE,
    DISABLE_SEND_TX,
    DISABLE_BATCH_FAUCET,
    EVM_RAW_TX_URL,
    EVM_FAUCET_URL,
    EVM_NONCE_URL,
    MEVM_EVENT,
} from './const.js';
import { parseRawTx, toHex, toNumber, toHexStrict, sleep } from './helper.js';
import { getMoveHash, getBlockHeightByHash, getEvmLogs, getErrorTxMoveHash } from './db.js';
import { ZeroAddress, ethers, isHexString, toBeHex, keccak256, isAddress } from 'ethers';
import BigNumber from 'bignumber.js';
import { toBuffer } from './helper.js';
import { move2ethAddress } from './helper.js';
import { googleRecaptcha } from './provider.js';
import { addToFaucetTask } from './task_faucet.js';
import { inspect } from 'node:util';
import { readFile, writeFile } from 'node:fs/promises';
import { DB_TX } from './leveldb_wrapper.js';
import { ClientWrapper } from './client_wrapper.js';
import { cluster } from 'radash';
import { postJsonRpc } from './request.js';

const pend_tx_path = 'db/tx-pending.json';
/// When eth_call or estimateGas,from may be 0x0,
// Now the evm's 0x0 address cannot exist in the move, so we need to convert it to 0x1
const ETH_ADDRESS_ONE = '0x0000000000000000000000000000000000000001';
const ETH_ADDRESS_ZERO = '0x0000000000000000000000000000000000000000';
const BLOCK_BASE_FEE = 5 * 1e9;
// if the block number is less than this value, we need to ignore the tx where the result is failed
const WRONG_BLOCK_TX = 1785834;

const SENDER_ACCOUNT_INDEX = Array.from({ length: SENDER_ACCOUNT_COUNT }, (_, i) => i);
const PENDING_TX_SET = new Set();
/**
 *
 *  {
 *     0x1 :[
 *          {
 *             nonce: 0,
 *             from:"0x1"
 *             key:"0x1:0"
 *             tx:"0x123",
 *             ts:1234
 *          }
 *   ]
 * }
 *
 */
const TX_MEMORY_POOL = {};
const TX_EXPIRE_TIME = 1000 * 60 * 5; // 5 Minutes
const ONE_ADDRESS_MAX_TX_COUNT = 20;
const TX_NONCE_FIRST_CHECK_TIME = {};

async function initTxPool() {
    try {
        const { pool } = JSON.parse(await readFile(pend_tx_path, 'utf8'));
        Object.keys(pool).forEach(key => {
            TX_MEMORY_POOL[key] = pool[key];
        });
    } catch (error) {}
}

await initTxPool();
// restart the process , save the tx pool
process.on('SIGINT', () => {
    writeFile(
        pend_tx_path,
        JSON.stringify({
            pool: TX_MEMORY_POOL,
        }),
    ).then(() => {
        process.exit(0);
    });
});

export async function getErrorByHash(hash) {
    if (!hash) {
        throw 'hash is empty';
    }
    if (hash.length !== 66) {
        throw 'hash format error';
    }
    const ret = {
        moveHash: null,
        error: 'Maybe the transaction is dropped by vm, you can try send it again',
    };
    const mHash = await getErrorTxMoveHash(hash);
    if (mHash) {
        ret.moveHash = mHash.move_hash;
        const info = await ClientWrapper.getTransactionByHash(mHash.move_hash);
        ret.error = info.vm_status;
    }
    return ret;
}

function removeTxFromMemoryPool(from, nonce) {
    const fromTx = TX_MEMORY_POOL[from];
    if (fromTx) {
        const existIndex = fromTx.findIndex(it => parseInt(it.nonce) === parseInt(nonce));
        if (existIndex !== -1) {
            fromTx.splice(existIndex, 1);
        }
    }
    // release the empty account info
    if (TX_MEMORY_POOL[from]?.length === 0) {
        delete TX_MEMORY_POOL[from];
    }
}

export async function sendRawTx(tx) {
    if (DISABLE_SEND_TX) {
        throw new Error('Not implemented');
    }
    if (EVM_RAW_TX_URL) {
        const res = await postJsonRpc(EVM_RAW_TX_URL, 'eth_sendRawTransaction', [tx]);
        let msg = res.error?.message ?? res.result ?? res;
        console.log('send raw tx', msg);
        if (res.error) {
            throw res.error?.message ?? res.error;
        }
        return res.result;
    }
    const info = parseRawTx(tx);
    const price = getGasPriceFromTx(info);
    // also there could use tx hash as the key
    let key = info.from + ':' + info.nonce;
    const item = {
        nonce: info.nonce,
        tx,
        from: info.from,
        ts: Date.now(),
        key,
        price,
    };
    const checkIsSend = () => {
        if (PENDING_TX_SET.has(key)) {
            throw 'transaction is in tx memory pool';
        }
    };
    checkIsSend();
    await checkSendTx(info);
    checkIsSend();
    let fromTxArr = TX_MEMORY_POOL[info.from];
    if (fromTxArr) {
        const existIndex = fromTxArr.findIndex(it => parseInt(it.nonce) === parseInt(info.nonce));
        if (existIndex !== -1) {
            const mTx = parseRawTx(fromTxArr[existIndex].tx);
            const mPrice = getGasPriceFromTx(mTx);
            if (BigNumber(price).gt(mPrice)) {
                item.ts = fromTxArr[existIndex].ts;
                // delete the old tx
                fromTxArr.splice(existIndex, 1);
            } else {
                throw 'replacement transaction underpriced';
            }
        }
    }
    if (!fromTxArr) {
        TX_MEMORY_POOL[info.from] = [item];
    } else {
        if (fromTxArr.length > ONE_ADDRESS_MAX_TX_COUNT) {
            throw 'account has too many tx in the memory pool';
        }
        fromTxArr.push(item);
    }
    return info.hash;
}
function binarySearchInsert(arr, item) {
    let low = 0;
    let high = arr.length;
    while (low < high) {
        const mid = Math.floor((low + high) / 2);
        // Sort gasPrice first, then sort by timestamp
        // price is hex string
        // const p1 = BigNumber(arr[mid].price);
        // const p2 = BigNumber(item.price);
        // if (p1.lt(p2) || (p1.eq(p2) && arr[mid].ts < item.ts)) {
        if (arr[mid].ts < item.ts) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }
    return low;
}
const SEND_LARGE_TX_INFO = {
    sendTime: 0,
    isFinish: true,
};
async function sendTxTask() {
    let isSending = false;
    let lastSendTime = Date.now();
    setInterval(async () => {
        if (isSending) {
            return;
        }
        if (SENDER_ACCOUNT_INDEX.length === 0) {
            return;
        }
        let allTx = [];
        const allKeys = Object.keys(TX_MEMORY_POOL);
        for (let key of allKeys) {
            const accTxArr = TX_MEMORY_POOL[key];
            allTx = allTx.concat(accTxArr);
        }
        if (allTx.length === 0) {
            return;
        }
        if (Date.now() - lastSendTime >= 60 * 1000) {
            lastSendTime = Date.now();
            console.log('tx pool remain %s', allTx.length);
        }
        // set LOCKER
        isSending = true;

        // get the chain nonce
        const accMap = {};
        const keysArr = cluster(allKeys, 50);
        for (let keys of keysArr) {
            const info = await Promise.all(keys.map(key => getAccountInfo(key)));
            keys.forEach((k, i) => {
                accMap[k] = info[i];
            });
        }
        // find the tx nonce is equal to the chain nonce
        const sendTxArr = [];
        for (let item of allTx) {
            const { key, from, nonce } = item;
            const currAccInfo = accMap[from];
            // The chain nonce greater than the tx nonce ,it will be drop
            if (parseInt(currAccInfo.nonce) > parseInt(nonce)) {
                removeTxFromMemoryPool(from, nonce);
                continue;
            }
            if (parseInt(currAccInfo.nonce) !== parseInt(nonce)) {
                let checkTime = TX_NONCE_FIRST_CHECK_TIME[key];
                if (!checkTime) {
                    // record the first check time
                    TX_NONCE_FIRST_CHECK_TIME[key] = Date.now();
                } else {
                    // timeout
                    if (Date.now() - checkTime > TX_EXPIRE_TIME) {
                        //drop this tx
                        removeTxFromMemoryPool(from, nonce);
                        delete TX_NONCE_FIRST_CHECK_TIME[key];
                    }
                }
                continue;
            }
            // Now we simply sort the tx by the timestamp
            let insertIndex = binarySearchInsert(sendTxArr, item);
            sendTxArr.splice(insertIndex, 0, item);
            // sendTxArr.push(item);
        }
        // sendTxArr.sort((a, b) => a.ts - b.ts);
        if (sendTxArr.length > 0 && SENDER_ACCOUNT_INDEX.length > 0) {
            const size = sendTxArr.length;
            for (let i = 0; i < size; i++) {
                if (sendTxArr.length === 0) break;
                const txInfo = sendTxArr.shift();
                const { key, tx, from, nonce } = txInfo;
                if (PENDING_TX_SET.has(key)) {
                    // it has send to chain but not finish
                    removeTxFromMemoryPool(from, nonce);
                    continue;
                }
                if (SENDER_ACCOUNT_INDEX.length === 0) break;
                let isLargeTx = false;
                const txParsed = parseRawTx(tx);
                if (
                    // for we estimate the gas enlarge the gas limit to 140%
                    BigNumber(txParsed.limit).gt(25_00_000 * 1.4) &&
                    // not deploy contract
                    txParsed.to !== ZeroAddress
                ) {
                    isLargeTx = true;
                    if (!SEND_LARGE_TX_INFO.isFinish) {
                        // not commit the last large tx
                        continue;
                    }
                    if (Date.now() - SEND_LARGE_TX_INFO.sendTime < 10 * 1000) {
                        // the more time to send small tx and make tx quickly
                        continue;
                    }
                }
                // This tx will be send to chain , so we can remove the first check time
                delete TX_NONCE_FIRST_CHECK_TIME[key];
                removeTxFromMemoryPool(from, nonce);
                PENDING_TX_SET.add(key);
                const senderIndex = SENDER_ACCOUNT_INDEX.shift();
                try {
                    const sender = GET_SENDER_ACCOUNT(senderIndex);
                    await sendTx(sender, tx, key, senderIndex, isLargeTx);
                } catch (error) {
                    // reset this tx info to the pool
                    PENDING_TX_SET.delete(key);
                    const fromAcc = TX_MEMORY_POOL[from];
                    if (fromAcc) {
                        // put it back to the pool
                        fromAcc.push(txInfo);
                    } else {
                        TX_MEMORY_POOL[from] = [txInfo];
                    }
                    // put the sender back to the pool
                    SENDER_ACCOUNT_INDEX.push(senderIndex);
                    // maybe tx can't be send to the chain
                    console.warn('evm:%s,error %s ', key, error.message ?? error);
                }
            }
        }

        // release locker
        isSending = false;
    }, 1000);
}
sendTxTask();

function isSuccessTx(info) {
    const txResult = info.events.find(it => it.type.startsWith(MEVM_EVENT));
    return txResult.data.exception === '200';
}

export async function getEvmSummary() {
    const ret = {
        txCount: 0,
        addressCount: 0,
    };
    try {
        let res;
        if (EVM_SUMMARY_URL) {
            // for the async node, it could get this info  from base node
            res = await postJsonRpc(EVM_SUMMARY_URL, 'admin_getEvmTxSummary', []).then(res => res.result);
            ret.addressCount = res.addressCount;
            ret.txCount = res.txCount;
        } else {
            res = JSON.parse(await readFile('tx-summary.json', 'utf8'));
            ret.addressCount = res.addrCount;
            ret.txCount = res.txCount;
        }
    } catch (error) {}
    return ret;
}

export async function getMoveAddress(acc) {
    acc = acc.toLowerCase();
    // for mevm2.0 this evm address is the same move address
    return acc;
}

export async function get_move_hash(evm_hash) {
    if (evm_hash?.length !== 66) {
        throw 'query evm hash format error';
    }
    return getMoveHash(evm_hash);
}

export async function traceTransaction(hash) {
    // Now it is not support , but maybe useful in the future
    return {};
    const move_hash = await getMoveHash(hash);
    const info = await ClientWrapper.getTransactionByHash(move_hash);
    const callType = ['CALL', 'STATIC_CALL', 'DELEGATE_CALL'];
    const toEtherAddress = addr => '0x' + addr.slice(-40);
    const format_item = data => ({
        from: toEtherAddress(data.from),
        gas: toHex(data.gas),
        gasUsed: toHex(data.gas_used),
        to: toEtherAddress(data.to),
        input: data.input,
        output: data.output || '0x',
        value: toHex(data.value),
        type: callType[data.type],
    });
    const traces = info.events.find(it => it.type === 'vector<0x1::evm_global_state::CallEvent>');
    traces.data.sort((a, b) => parseInt(a.depth) - parseInt(b.depth));
    console.log('traceTransaction', inspect(traces, false, null, true));
    const root_call = format_item(traces.data.shift());

    const find_caller = (item, trace) => {
        if (trace.to === item.from) {
            if (!trace.calls) trace['calls'] = [];
            trace.calls.push(item);
        } else {
            if (!root_call.calls) {
                // now we think it top level,
                if (!root_call.calls) root_call['calls'] = [];
                root_call.calls.push(item);
            } else {
                for (let call of trace.calls) {
                    find_caller(item, call);
                }
            }
        }
    };
    traces.data.forEach(data => {
        find_caller(format_item(data), root_call);
    });
    return root_call;
}

export async function batch_faucet(addr, token, ip) {
    // for production use
    if (DISABLE_BATCH_FAUCET) {
        throw 'please get the token from web page';
    }
    if (!ethers.isAddress(addr)) {
        throw 'Address format error';
    }
    if (EVM_FAUCET_URL) {
        const res = await postJsonRpc(EVM_FAUCET_URL, 'eth_batch_faucet', [addr], {
            token: token,
        });
        return res.result;
    }
    if ((await googleRecaptcha(token)) === false) {
        throw 'recaptcha error';
    }

    const res = await addToFaucetTask({ addr, ip });
    if (res.error) {
        throw res.error;
    }
    return res.hash;
}

export async function getMaxPriorityFeePerGas() {
    return toHex(2);
}

export async function eth_feeHistory() {
    const block = await getBlock();
    const baseFeePerGas = toHex(5 * 10 ** 9);
    return {
        oldestBlock: toHex(toNumber(block) - 4),
        reward: [
            ['0x5f5e100', '0xd3cdba48'],
            ['0x5f5e100', '0xb146453a'],
            ['0xb8c63f00', '0xb8c63f00'],
            ['0x5f5e100', '0x77359400'],
        ],
        baseFeePerGas: Array.from({ length: 4 }, () => baseFeePerGas),
        gasUsedRatio: [0.5329073333333333, 0.3723229, 0.6996228333333333, 0.5487537333333333],
    };
}

/**
 * Get the latest block. If the last block was fetched less than 2 seconds ago, return the cached block.
 * Otherwise, fetch the latest block from the client and update the cache.
 * @returns {Promise<string>} - A promise that resolves to the latest block
 */
export async function getBlock() {
    const info = await client.getLedgerInfo();
    return toHex(info.block_height);
}

export async function getBlockReceipts(block) {
    if (!isHexString(block)) {
        throw 'block number error';
    }
    const block_info = await getBlockByNumber(block, false);
    return Promise.all(block_info.transactions.map(it => getTransactionReceipt(it.hash)));
}

/**
 * Get a block by its number. If the block number is "latest", fetch the latest block from the client.
 * @param {string|number} block - The block number or "latest"
 * @returns {Promise<Object>} - A promise that resolves to the block object with the following properties:
 *   - difficulty: string - The difficulty level of the block
 *   - extraData: string - Extra data related to the block
 *   - gasLimit: string - The maximum gas that transactions in the block are allowed to consume
 *   - gasUsed: string - The total gas that transactions in the block have consumed
 *   - hash: string - The hash of the block
 *   - logsBloom: string - The bloom filter for the logs in the block
 *   - miner: string - The address of the miner who mined the block
 *   - mixHash: string - A hash that, combined with the nonce, proves that the block has gone through enough computation
 *   - nonce: string - A random value that, combined with the mixHash, proves that the block has gone through enough computation
 *   - number: string - The number of the block in the blockchain
 *   - parentHash: string - The hash of the parent block
 *   - receiptsRoot: string - The root of the receipts trie of the block
 *   - sha3Uncles: string - The SHA3 hash of the uncles data in the block
 *   - size: string - The size of the block in bytes
 *   - stateRoot: string - The root of the final state trie of the block
 *   - timestamp: string - The timestamp when the block was mined
 *   - totalDifficulty: string - The total difficulty of the chain up to this block
 *   - transactions: Array<string> - The transactions included in the block
 *   - transactionsRoot: string - The root of the transactions trie of the block
 *   - uncles: Array<string> - The uncle blocks of the block
 */
export async function getBlockByNumber(block, withTx) {
    let is_pending = false;
    if (block === 'pending') {
        is_pending = true;
    }
    if (block === 'latest') {
        let info = await client.getLedgerInfo();
        block = info.block_height;
    }
    block = BigNumber(block).toNumber();
    if (block < 0) {
        throw 'block number error';
    }
    const eKey = `block:${withTx}:` + block;
    if (!is_pending) {
        // only cache the block not pending
        const cache = await DB_TX.get(eKey);
        if (cache) {
            return JSON.parse(cache);
        }
    }
    let info;
    try {
        const mKey = 'move:block:' + block;
        const moveInfo = await DB_TX.get(mKey);
        if (moveInfo) {
            info = JSON.parse(moveInfo);
        } else {
            info = await ClientWrapper.getBlockByHeight(block, true);
            await DB_TX.put(mKey, JSON.stringify(info));
        }
    } catch (error) {
        // block not found
        return null;
    }

    let parentHash = ZERO_HASH;
    if (block >= 1) {
        let info = await ClientWrapper.getBlockByHeight(block - 1, false);
        parentHash = info.block_hash;
    }
    let transactions = info.transactions || [];
    let evm_tx = [];
    if (!is_pending) {
        for (let i = 0; i < transactions.length; i++) {
            let it = transactions[i];
            if (
                it.success &&
                it.type === 'user_transaction' &&
                it?.payload?.function?.startsWith('0x1::evm::send_tx')
            ) {
                if (BigNumber(block).lt(WRONG_BLOCK_TX)) {
                    // tmp fix for the old tx
                    if (!isSuccessTx(it)) {
                        // this tx should't be exist at evm
                        continue;
                    }
                }
                const { hash: evm_hash } = await parseMoveTxPayload(it);
                evm_tx.push(evm_hash);
            }
        }
    }
    const genHash = c => {
        const seed = info.block_hash;
        let hash = seed;
        while (c > 0) {
            c--;
            hash = keccak256(hash);
        }
        return hash;
    };
    if (withTx && evm_tx.length > 0) {
        evm_tx = await Promise.all(evm_tx.map(it => getTransactionByHash(it)));
    }
    let timestamp = toHex(Math.trunc(info.block_timestamp / 1e6));
    if (block === 0) {
        timestamp = BigNumber((await getBlockByNumber(1, false)).timestamp).minus(1);
        timestamp = toHex(timestamp);
    }
    const ret = {
        baseFeePerGas: toHex(BLOCK_BASE_FEE),
        difficulty: toHex(BigNumber('0x10000000000000')), //  7 bytes
        extraData: genHash(1),
        gasLimit: toHex(30_000_000),
        gasUsed: toHex(20_000_000),
        hash: info.block_hash,
        logsBloom: LOG_BLOOM,
        miner: ZeroAddress,
        mixHash: genHash(2),
        nonce: toHex(BigNumber('0x1000000000000000').plus(info.first_version)), //  8 bytes
        number: toHex(block),
        parentHash: parentHash,
        receiptsRoot: genHash(3),
        sha3Uncles: genHash(4),
        size: toHex(30_000_000),
        stateRoot: genHash(5),
        timestamp: timestamp,
        totalDifficulty: toHex(BigNumber('0x10000000000000000000').plus(info.last_version)), //  10 bytes
        transactions: evm_tx,
        transactionsRoot: genHash(6),
        uncles: [],
    };
    if (!is_pending) {
        await DB_TX.put(eKey, JSON.stringify(ret));
    }
    return ret;
}

export async function getBlockByHash(hash, withTx) {
    try {
        // Use keccak256 for make key more shorter
        const key = keccak256(Buffer.from(`hash:to:block:${hash}`, 'utf8'));
        let height = await DB_TX.get(key);
        if (!height) {
            height = await getBlockHeightByHash(hash);
            await DB_TX.put(key, height);
        }
        return getBlockByNumber(parseInt(height), withTx);
    } catch (error) {
        return null;
    }
}
/**
 * Get the code at a specific address.
 * @param {string} addr - The address to get the code from.
 * @returns {Promise<string>} - A promise that resolves to the code at the given address.
 */
export async function getCode(addr) {
    let result = await getAccountInfo(addr);
    return result.code;
}

export async function getStorageAt(addr, pos) {
    let res = '0x';
    let payload = {
        function: `0x1::evm::get_storage_at`,
        type_arguments: [],
        arguments: [addr, toHexStrict(pos)],
    };
    try {
        let result = await client.view(payload);
        res = result[0];
    } catch (error) {
        // console.log('getStorageAt error', error);
    }
    return res;
}

function getGasPriceFromTx(tx) {
    let gasPrice;
    if (tx.type === '0x2') {
        if (BigNumber(tx.maxFeePerGas).lt(BLOCK_BASE_FEE)) {
            throw 'maxFeePerGas must be greater than or equal to baseFee';
        }
        if (BigNumber(tx.maxFeePerGas).lt(tx.maxPriorityFeePerGas)) {
            throw 'maxFeePerGas must be greater than or equal to maxPriorityFeePerGas';
        }
        const p0 = BigNumber(tx.maxPriorityFeePerGas).plus(BLOCK_BASE_FEE);
        if (p0.gt(tx.maxFeePerGas)) {
            gasPrice = toHex(p0);
        } else {
            gasPrice = toHex(tx.maxFeePerGas);
        }
    } else if (tx.type === '0x0' || tx.type === '0x1') {
        gasPrice = tx.gasPrice;
    } else {
        throw 'not support transaction type';
    }
    if (!gasPrice || BigNumber(gasPrice).lt(BLOCK_BASE_FEE)) {
        throw 'gasPrice must be greater than or equal to baseFee';
    }
    return gasPrice;
}

// 1. `gasprice` should be greater than or equal to `basefee` (for regular transactions).
// 2. `max_fee_per_gas` should be greater than or equal to `basefee` (for EIP-1559 transactions).
// 3. `max_fee_per_gas` should be greater than or equal to `max_priority_fee_per_gas` (for EIP-1559 transactions).
// 4. `gasLimit` should be less than or equal to `blockGasLimit` (currently 30,000,000, general rule).
// 5. `gasprice * gaslimit + value` should be greater than or equal to the balance (general rule, `gasprice` calculation as per above).
// 6. The `sender` cannot be a contract (general rule, check if the `sender` has code).
// 7. `gasLimit` should be greater than or equal to the base cost (21,000 + data cost + access list cost).
// 8. `nonce` should be equal to the current nonce + 1 (general rule).

async function checkSendTx(tx) {
    const gasPrice = getGasPriceFromTx(tx);
    const account = await getAccountInfo(tx.from);
    if (BigNumber(gasPrice).times(tx.limit).plus(tx.value).gt(account.balance)) {
        throw 'insufficient balance';
    }

    if (account.code !== '0x') {
        throw 'sender not EOA';
    }

    if (BigNumber(tx.limit).gt(30_000_000)) {
        throw 'gasLimit must be less than or equal to blockGasLimit';
    }
    // hex length is 2 * byte length
    const MAX_INIT_CODE_SIZE = 49152 * 2;
    if (tx.data.slice(2).length > MAX_INIT_CODE_SIZE && !tx.to) {
        throw "contract creation code can't be more than 49152 bytes";
    }
    let data_cost = 21000; // base cost
    if (tx.data !== '0x') {
        let data = tx.data.startsWith('0x') ? tx.data.slice(2) : tx.data;
        let cursor = 0;
        if (data.length % 2 !== 0) {
            throw new Error('invalid data length, should be even.');
        }
        while (cursor < data.length) {
            const byte = data.slice(cursor, cursor + 2);
            if (byte === '00') {
                data_cost += 4;
            } else {
                data_cost += 16;
            }
            cursor += 2;
        }
    }

    // The next check now we are skip
    // if (tx.accessList && tx.accessList.length > 0) {
    //     //     [
    //     //       {
    //     //         "address": "0x0000000000000000000000000000000000000064",
    //     //         "storageKeys": [
    //     //           "0x0000000000000000000000000000000000000000000000000000000000000064",
    //     //           "0x00000000000000000000000000000000000000000000000000000000000000c8"
    //     //         ]
    //     //       }
    //     //     ]
    //     const addressCost = 2400;
    //     const keyCost = 1900;
    //     for (let { address, storageKeys } of tx.accessList) {
    //         if (!isAddress(address)) {
    //             throw 'AccessList address format error';
    //         }
    //         data_cost += addressCost;
    //         storageKeys.forEach(it => {
    //             if (it.length !== 66) {
    //                 throw 'AccessList storageKeys format error';
    //             }
    //             data_cost += keyCost;
    //         });
    //     }
    // }
    if (BigNumber(tx.limit).lt(data_cost)) {
        throw 'gasLimit must be greater than or equal to base cost plus tx data cost';
    }
    const chainNonce = parseInt(account.nonce);
    if (chainNonce > parseInt(tx.nonce)) {
        throw new Error('nonce too low');
    }
}

export async function callContract(from, contract, calldata, value, block) {
    if (from === ETH_ADDRESS_ZERO || !from) {
        from = ETH_ADDRESS_ONE;
    }
    contract = contract || ZeroAddress;
    if (DISABLE_EVM_ARCHIVE_NODE) {
        block = undefined;
    } else {
        if (block?.blockHash?.length === 66) {
            const height = await getBlockHeightByHash(block.blockHash);
            const info = await ClientWrapper.getBlockByHeight(toNumber(height), false);
            block = info.last_version;
        } else if (isHexString(block)) {
            try {
                const info = await ClientWrapper.getBlockByHeight(toNumber(block), false);
                block = info.last_version;
            } catch (error) {
                throw 'block number error';
            }
        } else {
            // it maybe latest
            block = undefined;
        }
    }
    return callContractImpl(from, contract, calldata, value, block);
}
/**
 * Estimate the gas needed for a transaction.
 * @param {Object} info - The transaction information, including from, to, data, and value.
 * @returns {Promise<Object>} - A promise that resolves to an object containing:
 *   - success: boolean - Whether the gas estimation was successful
 *   - gas_used: number - The amount of gas used
 *   - show_gas: number - The amount of gas to show,
 */
export async function estimateGas(info) {
    if (!info.data && info.input) {
        // for cast cast 0.2.0 (23700c9 2024-05-22T00:16:24.627116943Z)
        // the data is in the input field
        info.data = info.input;
    }
    if (!info.from || info.from === ETH_ADDRESS_ZERO) {
        info.from = ETH_ADDRESS_ONE;
    }
    const nonce = await getNonce(info.from);
    if (!info.data) info.data = '0x';
    // Use maxFeePerGas to determine the type of transaction for MaxFeePerGas and gasPrice maybe both null
    let type = Boolean(info.maxFeePerGas) ? '2' : '1';
    let gasPrice = toBeHex(await getGasPrice());
    let maxFeePerGas = toBeHex(1);
    if (type === '2' && info.maxFeePerGas) {
        maxFeePerGas = toBeHex(info.maxFeePerGas);
    }
    let data = info.data === '0x' ? '0x' : toBeHex(info.data);
    if (info.data.length - 2 === data.length) {
        data = '0x00' + data.slice(2);
    }
    const payload = {
        function: `0x1::evm::query`,
        type_arguments: [],
        arguments: [
            info.from,
            info.to || '0x',
            toBeHex(nonce),
            toBeHex(info.value || '0x0'),
            data,
            toBeHex(3 * 1e7), // gas_limit 30_000_000
            gasPrice, // gas_price
            maxFeePerGas, // max_fee_per_gas
            toBeHex(1), // max_priority_per_gas
            '0x',
            type, //  if the tx type is 1 , only gas price is effect
        ],
    };
    const result = await client.view(payload);
    const isSuccess = result[0] === '200';
    // We need do more check, but now we just simply enlarge it 140%
    // https://github.com/ethereum/go-ethereum/blob/b0f66e34ca2a4ea7ae23475224451c8c9a569826/eth/gasestimator/gasestimator.go#L52
    let gas = isSuccess ? BigNumber(result[1]).times(14).div(10).toFixed(0) : 3e7;
    if (isSuccess && result[1] === '21000') {
        // If it just transfer eth ,we no need to change it
        gas = 21000;
    }
    const ret = {
        success: isSuccess,
        gas_used: gas,
        code: result[0],
        message: result[2],
    };
    return ret;
}
export async function getGasPrice() {
    return toHex(2 * BLOCK_BASE_FEE);
}

async function getTransactionIndex(block, hash) {
    const block_info = await getBlockByNumber(block, false);
    let transactionIndex = 0;
    for (let i = 0; i < block_info.transactions.length; i++) {
        if (block_info.transactions[i] === hash) {
            transactionIndex = i;
            break;
        }
    }
    return transactionIndex;
}
/**
 * Get a transaction by its hash.
 * @param {string} tx - The hash of the transaction.
 * @returns {Promise<Object>} - A promise that resolves to an object containing:
 *   - blockHash: string - The hash of the block containing the transaction
 *   - blockNumber: string - The number of the block containing the transaction
 *   - from: string - The address from which the transaction was sent
 *   - gas: string - The amount of gas used by the transaction
 *   - gasPrice: string - The price of gas in the transaction
 *   - hash: string - The hash of the transaction
 *   - input: string - The input data of the transaction
 *   - nonce: string - The nonce of the transaction
 *   - to: string - The address to which the transaction was sent
 *   - transactionIndex: string - The index of the transaction in the block
 *   - value: string - The value transferred in the transaction
 *   - v: string - The v value of the transaction's signature
 *   - r: string - The r value of the transaction's signature
 *   - s: string - The s value of the transaction's signature
 */
export async function getTransactionByHash(evm_hash) {
    let move_hash;
    try {
        move_hash = await getMoveHash(evm_hash);
    } catch (error) {
        // hash not found
        return null;
    }
    const key = 'tx:' + evm_hash;
    let cache = await DB_TX.get(key);
    if (cache) {
        return JSON.parse(cache);
    }
    const info = await ClientWrapper.getTransactionByHash(move_hash);
    const block = await client.getBlockByVersion(info.version);
    const txInfo = await parseMoveTxPayload(info);
    const transactionIndex = toHex(await getTransactionIndex(block.block_height, evm_hash));
    const gasInfo = {};
    if (txInfo.gasPrice) {
        gasInfo.gasPrice = toHex(txInfo.gasPrice);
    } else {
        gasInfo.maxFeePerGas = toHex(txInfo.maxFeePerGas);
        gasInfo.maxPriorityFeePerGas = toHex(txInfo.maxPriorityFeePerGas);
    }
    const ret = {
        blockHash: block.block_hash,
        blockNumber: toHex(block.block_height),
        from: txInfo.from,
        gas: toHex(txInfo.limit),
        hash: txInfo.hash,
        input: txInfo.data,
        type: toHex(txInfo.type),
        nonce: toHex(txInfo.nonce),
        to: txInfo.to,
        accessList: txInfo.accessList,
        transactionIndex,
        value: toHex(txInfo.value),
        v: toHex(txInfo.v),
        r: toHex(txInfo.r, true), // need remove the leading zero, otherwise the eth go sdk will parse error
        s: toHex(txInfo.s, true), // need remove the leading zero, otherwise the eth go sdk will parse error
        chainId: toHex(CHAIN_ID),
        ...gasInfo,
    };
    await DB_TX.put(key, JSON.stringify(ret));
    return ret;
}

export async function getTransactionReceipt(evm_hash) {
    let move_hash;
    try {
        move_hash = await getMoveHash(evm_hash);
    } catch (error) {
        // hash not found
        return null;
    }
    const key = 'receipt:' + evm_hash;
    let cache = await DB_TX.get(key);
    if (cache) {
        return JSON.parse(cache);
    }
    let info = await ClientWrapper.getTransactionByHash(move_hash);
    let block = await client.getBlockByVersion(info.version);
    const { to, from, type } = await parseMoveTxPayload(info);
    // let contractAddress = await getDeployedContract(info);
    const transactionIndex = toHex(await getTransactionIndex(block.block_height, evm_hash));
    // we could get it from indexer , but is also to parse it directly to reduce the request
    const logs = parseLogs(info, block.block_height, block.block_hash, evm_hash, transactionIndex);
    const txResult = info.events.find(it => it.type.startsWith(MEVM_EVENT));
    const status = isSuccessTx(info) ? '0x1' : '0x0';
    let contractAddress =
        txResult.data.created_address === '0x' ? null : move2ethAddress(txResult.data.created_address);
    let recept = {
        blockHash: block.block_hash,
        blockNumber: toHex(block.block_height),
        contractAddress,
        cumulativeGasUsed: toHex(txResult.data.gas_usage),
        effectiveGasPrice: toHex(txResult.data.gas_usage),
        from: from,
        gasUsed: toHex(txResult.data.gas_usage),
        logs: logs,
        to: Boolean(contractAddress) ? null : to,
        logsBloom: LOG_BLOOM,
        status: status,
        transactionHash: evm_hash,
        transactionIndex: transactionIndex,
        type,
    };
    await DB_TX.put(key, JSON.stringify(recept));
    return recept;
}
/**
 * Retrieves the nonce for a given sender.
 * @param {string} sender - The sender's address.
 * @returns {Promise<string>} The nonce in hexadecimal format.
 * @throws Will throw an error if the account information cannot be retrieved.
 */
export async function getNonce(sender) {
    if (EVM_NONCE_URL) {
        const res = await postJsonRpc(EVM_NONCE_URL, 'eth_getTransactionCount', [sender]);
        return res.result;
    }
    let info = await getAccountInfo(sender);
    return toHex(info.nonce);
}

/**
 * Retrieves the balance for a given sender.
 * @param {string} sender - The sender's address.
 * @returns {Promise<string>} The balance in hexadecimal format.
 * @throws Will throw an error if the account information cannot be retrieved.
 */
export async function getBalance(sender, block) {
    let info = await getAccountInfo(sender, block);
    return toHex(info.balance);
}

/**
 * Retrieves account information for a given Ethereum address.
 * @param {string} acc - The Ethereum address.
 * @returns {Promise<Object>} An object containing the account's balance, nonce, and code.
 * @throws Will not throw an error if the Ethereum address has not been deposited from Move.
 */
async function getAccountInfo(acc, block) {
    const ret = {
        balance: '0x0',
        nonce: 0,
        code: '0x',
        moveAddress: '0x0',
    };
    acc = acc.toLowerCase();
    try {
        let moveAddress = await getMoveAddress(acc);
        if (DISABLE_EVM_ARCHIVE_NODE) {
            block = undefined;
        } else {
            if (isHexString(block)) {
                let info = await ClientWrapper.getBlockByHeight(toNumber(block), false);
                block = info.last_version;
            } else {
                block = undefined;
            }
        }
        const resource = await client.getAccountResource(moveAddress, `0x1::evm_storage::AccountStorage`, {
            ledgerVersion: block,
        });
        ret.moveAddress = moveAddress;
        ret.balance = resource.data.balance;
        ret.nonce = +resource.data.nonce;
        ret.code = resource.data.code;
    } catch (error) {
        // if this eth address not deposit from move ,it will error
    }

    return ret;
}

async function sendTx(sender, tx, txKey, senderIndex, isLargeTx) {
    const payload = {
        function: `0x1::evm::send_tx`,
        type_arguments: [],
        arguments: [toBuffer(tx)],
    };
    const expire_time_sec = 600;
    const account = await client.getAccount(sender.address());
    const txnRequest = await client.generateTransaction(sender.address(), payload, {
        max_gas_amount: 2 * 1e6, // Now it is the max value
        gas_unit_price: 100, // the default value
        sequence_number: account.sequence_number,
        expiration_timestamp_secs: Math.trunc(Date.now() / 1000) + expire_time_sec,
    });
    const signedTxn = await client.signTransaction(sender, txnRequest);
    const startTs = Date.now();
    const transactionRes = await client.submitTransaction(signedTxn);
    if (isLargeTx) {
        SEND_LARGE_TX_INFO.isFinish = false;
    }
    const checkTxResult = async () => {
        let isRunning = false;
        let checkStart = Date.now();
        await new Promise(resolve => {
            let intervalId = setInterval(async () => {
                if (isRunning) {
                    return;
                }
                isRunning = true;
                try {
                    const accountNow = await client.getAccount(sender.address());
                    // if the sequence_number is changed, this account can reuse to send tx again
                    if (account.sequence_number !== accountNow.sequence_number) {
                        clearInterval(intervalId);
                        resolve();
                    }
                    if (Date.now() - checkStart > (expire_time_sec + 5) * 1000) {
                        // maybe drop the tx for the tx expired
                        clearInterval(intervalId);
                        resolve();
                    }
                } catch (error) {}
                isRunning = false;
            }, 500);
        });
        SENDER_ACCOUNT_INDEX.push(senderIndex);
        PENDING_TX_SET.delete(txKey);
        if (isLargeTx) {
            SEND_LARGE_TX_INFO.isFinish = true;
            SEND_LARGE_TX_INFO.ts = Date.now();
        }
        const result = await ClientWrapper.getTransactionByHash(transactionRes.hash);
        // maybe pending
        console.log(
            '%s,ms:%s,move:%s,tx:%s,%s',
            isLargeTx,
            Date.now() - startTs,
            transactionRes.hash,
            txKey,
            result.success || 'pending',
            result.vm_status || 'none',
        );
    };
    // Need to check the tx result for log and return sender account to the pool
    checkTxResult().catch(err => {
        console.error('checkTxResult %s error %s', transactionRes.hash, err.message ?? err);
    });
    return transactionRes.hash;
}
/**
 * Retrieves the address of the deployed contract.
 * @param {Object} info - The transaction information.
 * @returns {Promise<string|null>} The address of the deployed contract, or null if the transaction was not successful or did not deploy a contract.
 */
async function getDeployedContract(info) {
    if (!info.success) return null;
    const { nonce, to, from } = await parseMoveTxPayload(info);
    if (to === ZeroAddress || !to) {
        return ethers.getCreateAddress({ from: from, nonce }).toLowerCase();
    }
    return null;
}

async function callContractImpl(from, contract, calldata, value, version) {
    let data = calldata === '0x' ? '0x' : toBeHex(calldata);
    if (data.length === calldata.length - 2) {
        data = '0x00' + data.slice(2);
    }
    const nonce = await getNonce(from);
    let payload = {
        function: `0x1::evm::query`,
        type_arguments: [],
        arguments: [
            from,
            contract,
            toBeHex(nonce),
            toBeHex(value),
            data,
            toBeHex(3e7),
            toBeHex(await getGasPrice()),
            toBeHex(1),
            toBeHex(1),
            '0x',
            '1',
        ],
    };
    const result = await client.view(payload, version);
    const isSuccess = result[0] === '200';
    const ret = {
        success: isSuccess,
        gas_used: isSuccess ? result[1] : 3e7,
        code: result[0],
        message: result[2],
    };
    return ret;
}

export async function getLogs(obj) {
    const nowBlock = await getBlock();
    const fromBlock = isHexString(obj.fromBlock) ? toNumber(obj.fromBlock) : toNumber(nowBlock);
    const toBlock = isHexString(obj.toBlock) ? toNumber(obj.toBlock) : toNumber(nowBlock);
    const address = Array.isArray(obj.address) ? obj.address : [obj.address];
    if (toBlock < fromBlock) throw new Error('block range error');
    if (toBlock - fromBlock > 2000) throw new Error('block range too large, max 2000 blocks');
    const ret = await getEvmLogs({
        from: fromBlock,
        to: toBlock,
        address,
        topics: obj.topics,
    });
    const r = ret.map(it => {
        return {
            ...it,
            blockNumber: toHex(it.blockNumber),
            transactionIndex: toHex(it.transactionIndex),
            removed: false,
        };
    });
    // skip the wrong tx
    const blocks = Array.from(
        new Set(
            r.map(it => ({
                number: parseInt(it.blockNumber),
                hash: it.transactionHash,
            })),
        ),
    );
    const skipTx = [];
    for (const { number, hash } of blocks) {
        if (number < WRONG_BLOCK_TX) {
            const blockTx = await getBlockByNumber(number, false);
            if (blockTx.transactions.includes(hash)) {
                continue;
            }
            skipTx.push(hash);
        }
    }
    if (skipTx.length > 0) {
        return r.filter(it => !skipTx.includes(it.transactionHash));
    }
    return r;
}

function parseLogs(info, blockNumber, blockHash, evm_hash, transactionIndex) {
    // this could from indexer get, but we could get them from the tx hash
    let logs = [];
    let events = info.events || [];
    events = events.filter(it => it.type.startsWith(MEVM_EVENT));
    if (events.length > 0) {
        const tx_logs = events[0].data.logs;
        for (let i = 0; i < tx_logs.length; i++) {
            const log = tx_logs[i];
            logs.push({
                address: move2ethAddress(log.contract),
                topics: log.topics,
                data: log.data,
                blockNumber: toHex(blockNumber),
                transactionHash: evm_hash,
                transactionIndex,
                blockHash: blockHash,
                logIndex: toHex(i),
                removed: false,
            });
        }
    }
    return logs;
}
async function parseMoveTxPayload(info) {
    const args = info.payload.arguments;
    // return await workerPool.run(args[0], { name: 'parseTx' });
    return parseRawTx(args[0]);
}

export async function getTxPool() {
    if (EVM_RAW_TX_URL) {
        const res = await postJsonRpc(EVM_RAW_TX_URL, 'admin_getTxPool', []);
        if (res.error) {
            throw res.error?.message ?? res.error;
        }
        return res.result;
    }
    return TX_MEMORY_POOL;
}
