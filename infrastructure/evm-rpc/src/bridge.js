import {
    GET_SENDER_ACCOUNT,
    client,
    ZERO_HASH,
    LOG_BLOOM,
    FAUCET_SENDER_ACCOUNT,
    CHAIN_ID,
    FAUCET_AMOUNT,
    SENDER_ACCOUNT_COUNT,
    ENV_IS_PRO,
} from './const.js';
import { parseRawTx, sleep, toHex, toNumber, toHexStrict } from './helper.js';
import { getMoveHash, getBlockHeightByHash, getEvmLogs } from './db.js';
import { ZeroAddress, ethers, isHexString, toBeHex, keccak256 } from 'ethers';
import BigNumber from 'bignumber.js';
import Lock from 'async-lock';
import { toBuffer } from './helper.js';
import { move2ethAddress } from './helper.js';
import { googleRecaptcha } from './provider.js';
import { addToFaucetTask } from './task_faucet.js';
import { inspect } from 'node:util';
import { readFile } from 'node:fs/promises';
const locker = new Lock({
    maxExecutionTime: 15 * 1000,
    maxPending: SENDER_ACCOUNT_COUNT * 30,
});

let SEND_TX_ACCOUNT_INDEX = 0;

const CACHE_ETH_ADDRESS_TO_MOVE = {};
const CACHE_MOVE_HASH_TO_BLOCK_HEIGHT = {};

const ETH_ADDRESS_ONE = '0x0000000000000000000000000000000000000001';

function isSuccessTx(info) {
    const txResult = info.events.find(it => it.type === '0x1::evm::ExecResultEvent');
    return txResult.data.exception === '200';
}

export async function getEvmSummary() {
    const ret = {
        txCount: 0,
        addressCount: 0,
    };
    try {
        const res = JSON.parse(await readFile('tx-summary.json', 'utf8'));
        ret.addressCount = res.addrCount;
        ret.txCount = res.txCount;
    } catch (error) {}
    return ret;
}

export async function getMoveAddress(acc) {
    acc = acc.toLowerCase();
    return acc;
    // let moveAddress = CACHE_ETH_ADDRESS_TO_MOVE[acc];
    // try {
    //     if (!moveAddress) {
    //         let payload = {
    //             function: `0x1::evm::get_move_address`,
    //             type_arguments: [],
    //             arguments: [acc],
    //         };
    //         let result = await client.view(payload);
    //         moveAddress = result[0];
    //         CACHE_ETH_ADDRESS_TO_MOVE[acc] = moveAddress;
    //     }
    // } catch (error) {
    //     // maybe error so the account not found in move
    // }
    // return moveAddress || '0x0';
}

export async function get_move_hash(evm_hash) {
    if (evm_hash?.length !== 66) {
        throw 'query evm hash format error';
    }
    return getMoveHash(evm_hash);
}

export async function traceTransaction(hash) {
    // now it is not support
    return {};
    const move_hash = await getMoveHash(hash);
    const info = await client.getTransactionByHash(move_hash);
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
    if ((await googleRecaptcha(token)) === false) {
        throw 'recaptcha error';
    }
    if (!ethers.isAddress(addr)) {
        throw 'Address format error';
    }
    const res = await addToFaucetTask({ addr });
    if (res.error) {
        throw res.error;
    }
    console.log('faucet %s %s success', addr, ip);
    return res.data;
}

let IS_FAUCET_RUNNING = false;

export async function faucet(addr) {
    if (ENV_IS_PRO && addr !== ETH_ADDRESS_ONE) {
        throw 'please get the test token from web page';
    }
    if (!ethers.isAddress(addr)) {
        throw 'Eth address format error';
    }
    if (IS_FAUCET_RUNNING) {
        throw 'System busy, please try later';
    }
    let amount = FAUCET_AMOUNT;
    if (addr === ETH_ADDRESS_ONE) {
        amount = 100 * FAUCET_AMOUNT;
    }
    const payload = {
        function: `0x1::evm::deposit`,
        type_arguments: [],
        arguments: [toBuffer(addr), toBuffer(toBeHex(BigNumber(amount).times(1e18).toString()))],
    };
    const txnRequest = await client.generateTransaction(FAUCET_SENDER_ACCOUNT.address(), payload, {
        expiration_timestamp_secs: Math.floor(Date.now() / 1000) + 10,
    });
    const signedTxn = await client.signTransaction(FAUCET_SENDER_ACCOUNT, txnRequest);
    const transactionRes = await client.submitTransaction(signedTxn);
    // this not do any check , but we make it slowly to keep this function
    // await sleep(5);
    try {
        const res = await client.waitForTransactionWithResult(transactionRes.hash);
        console.log('faucet %s %s %s', addr, transactionRes.hash, res.vm_status);
        if (res.success) {
            return transactionRes.hash;
        } else {
            throw res.vm_status;
        }
    } catch (e) {
        throw 'System error, please try later';
    } finally {
        IS_FAUCET_RUNNING = false;
    }
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
    let info = await client.getBlockByHeight(block, true);
    let parentHash = ZERO_HASH;
    if (block > 2) {
        let info = await client.getBlockByHeight(block - 1, false);
        parentHash = info.block_hash;
    }
    let transactions = info.transactions || [];
    let evm_tx = [];
    if (!is_pending) {
        for (let i = 0; i < transactions.length; i++) {
            let it = transactions[i];
            if (it.type === 'user_transaction' && it?.payload?.function?.startsWith('0x1::evm::send_tx')) {
                const { hash: evm_hash } = parseMoveTxPayload(it);
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
    return {
        baseFeePerGas: toHex(5 * 1e9), // eip1559  set half of gasPrice
        difficulty: toHex(BigNumber('0x100000000000000000')),
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
        timestamp: toHex(Math.trunc(info.block_timestamp / 1e6)),
        totalDifficulty: toHex(BigNumber('0x100000000000000000').plus(info.last_version)), //  10 bytes
        transactions: evm_tx,
        transactionsRoot: genHash(6),
        uncles: [],
    };
}

export async function getBlockByHash(hash, withTx) {
    try {
        let height = CACHE_MOVE_HASH_TO_BLOCK_HEIGHT[hash];
        if (!height) {
            height = await getBlockHeightByHash(hash);
            CACHE_MOVE_HASH_TO_BLOCK_HEIGHT[hash] = [height];
        }
        return getBlockByNumber(height, withTx);
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
        console.log('getStorageAt error', error);
    }
    return res;
}

// Forge will send multiple transactions at the same time
// and the order of nonces is not necessarily in ascending order,
// so we need to sort them again.
async function checkAddressNonce(info) {
    const startTs = Date.now();
    while (1) {
        try {
            const accInfo = await Promise.race([
                getAccountInfo(info.from),
                new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout')), 10 * 1000)),
            ]);
            if (parseInt(accInfo.nonce) === parseInt(info.nonce)) {
                return true;
            }
        } catch (error) {
            continue;
        }
        if (Date.now() - startTs > 30 * 1000) {
            throw 'Timeout to discard from memory pool. Please send tx follow address nonce order';
        }
        await sleep(0.5);
    }
}

// Because only successful transactions in Move EVM will update the nonce,
// we don't need to check the nonce here.
// We can directly read it from the blockchain instead of relying on user input.
export async function sendRawTx(tx) {
    const info = parseRawTx(tx);
    const payload = {
        function: `0x1::evm::send_tx`,
        type_arguments: [],
        arguments: [toBuffer(tx)],
    };
    // this guarantee the nonce order for same from address
    await checkAddressNonce(info);
    const SENDER_ACCOUNT = GET_SENDER_ACCOUNT(SEND_TX_ACCOUNT_INDEX % SENDER_ACCOUNT_COUNT);
    SEND_TX_ACCOUNT_INDEX++;
    // this guarantee the the sender address is order
    return locker.acquire('sendTx:' + SEND_TX_ACCOUNT_INDEX, async function (done) {
        sendTx(SENDER_ACCOUNT, payload)
            .then(hash => {
                done(null, info.hash);
            })
            .catch(err => {
                done(err.message || 'sendTx error');
            });
    });
}

export async function callContract(from, contract, calldata, value, block) {
    from = from || ETH_ADDRESS_ONE;
    contract = contract || ZeroAddress;
    if (isHexString(block)) {
        let info = await client.getBlockByHeight(toNumber(block), false);
        block = info.last_version;
    } else {
        // it maybe latest
        block = undefined;
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
    if (!info.from) {
        info.from = ETH_ADDRESS_ONE;
    }
    const nonce = await getNonce(info.from);
    if (!info.data) info.data = '0x';
    let type = info.type === '0x1' ? '1' : '2';
    let gasPrice = toBeHex(await getGasPrice());
    let maxFeePerGas = toBeHex(1);
    if (type === '2' && info.maxFeePerGas) {
        gasPrice = toBeHex(1);
        maxFeePerGas = toBeHex(info.maxFeePerGas);
    }
    const payload = {
        function: `0x1::evm::query`,
        type_arguments: [],
        arguments: [
            info.from,
            info.to || '0x',
            toBeHex(nonce),
            toBeHex(info.value || '0x0'),
            info.data === '0x' ? '0x' : toBeHex(info.data),
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
    const ret = {
        success: isSuccess,
        gas_used: isSuccess ? result[1] : 3e7,
        code: result[0],
        message: result[2],
    };
    return ret;
}
export async function getGasPrice() {
    return toHex(10 * 1e9);
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
    const move_hash = await getMoveHash(evm_hash);
    const info = await client.getTransactionByHash(move_hash);
    const block = await client.getBlockByVersion(info.version);
    const txInfo = parseMoveTxPayload(info);
    const transactionIndex = toHex(await getTransactionIndex(block.block_height, evm_hash));
    // const txResult = info.events.find(it => it.type === '0x1::evm::ExecResultEvent');
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
        gas: txInfo.limit,
        hash: txInfo.hash,
        input: txInfo.data,
        type: txInfo.type,
        nonce: toHex(txInfo.nonce),
        to: txInfo.to,
        accessList: txInfo.accessList,
        transactionIndex,
        value: toHex(txInfo.value),
        v: toHex(txInfo.v),
        r: txInfo.r,
        s: txInfo.s,
        chainId: toHex(CHAIN_ID),
        ...gasInfo,
    };
    return ret;
}

export async function getTransactionReceipt(evm_hash) {
    let move_hash = await getMoveHash(evm_hash);
    let info = await client.getTransactionByHash(move_hash);
    let block = await client.getBlockByVersion(info.version);
    const { to, from, type } = parseMoveTxPayload(info);
    // let contractAddress = await getDeployedContract(info);
    const transactionIndex = toHex(await getTransactionIndex(block.block_height, evm_hash));
    // we could get it from indexer , but is also to parse it directly to reduce the request
    const logs = parseLogs(info, block.block_height, block.block_hash, evm_hash, transactionIndex);
    const txResult = info.events.find(it => it.type === '0x1::evm::ExecResultEvent');
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
    return recept;
}
/**
 * Retrieves the nonce for a given sender.
 * @param {string} sender - The sender's address.
 * @returns {Promise<string>} The nonce in hexadecimal format.
 * @throws Will throw an error if the account information cannot be retrieved.
 */
export async function getNonce(sender) {
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
        if (isHexString(block)) {
            let info = await client.getBlockByHeight(toNumber(block), false);
            block = info.last_version;
        } else {
            block = undefined;
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

async function sendTx(sender, payload, option = {}) {
    try {
        const account = await client.getAccount(sender.address());
        const txnRequest = await client.generateTransaction(sender.address(), payload, {
            ...option,
            max_gas_amount: 1 * 1e6,
            sequence_number: account.sequence_number,
            expiration_timestamp_secs: Math.trunc(Date.now() / 1000) + 10,
        });
        const signedTxn = await client.signTransaction(sender, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        console.log('sendTx', transactionRes.hash);
        // no need care the result
        await client.waitForTransactionWithResult(transactionRes.hash, {
            timeoutSecs: 10,
        });
        return transactionRes.hash;
    } catch (error) {
        // this is system error ,we also throw the real reason to the client
        throw new Error(error.message || 'system error ');
    }
}
/**
 * Retrieves the address of the deployed contract.
 * @param {Object} info - The transaction information.
 * @returns {Promise<string|null>} The address of the deployed contract, or null if the transaction was not successful or did not deploy a contract.
 */
async function getDeployedContract(info) {
    if (!info.success) return null;
    const { nonce, to, from } = parseMoveTxPayload(info);
    if (to === ZeroAddress || !to) {
        return ethers.getCreateAddress({ from: from, nonce }).toLowerCase();
    }
    return null;
}

async function callContractImpl(from, contract, calldata, value, version) {
    const nonce = await getNonce(from);
    let payload = {
        function: `0x1::evm::query`,
        type_arguments: [],
        arguments: [
            from,
            contract,
            toBeHex(nonce),
            toBeHex(value),
            calldata,
            toBeHex(3e7),
            toBeHex(1),
            toBeHex(1),
            toBeHex(1),
            '0x',
            '1',
        ],
    };
    const result = await client.view(payload);
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
    // console.log('getLogs1', r);
    return r;
}

function parseLogs(info, blockNumber, blockHash, evm_hash, transactionIndex) {
    // this could from indexer get, but we could get them from the tx hash
    let logs = [];
    let events = info.events || [];
    events = events.filter(it => it.type === '0x1::evm::ExecResultEvent');
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
function parseMoveTxPayload(info) {
    const args = info.payload.arguments;
    return parseRawTx(args[0]);
}
