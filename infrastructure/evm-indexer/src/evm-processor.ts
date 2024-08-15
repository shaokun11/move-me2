import { DataSource } from "typeorm";
import { ProcessingResult, TransactionsProcessor } from "./processor";
import { aptos } from "@aptos-labs/aptos-protos";
import { EvmErrorHash, EvmHash, EvmLogs } from "./models/evm";
import { ethers } from "ethers";
import {
  createNextVersionToProcess,
  NextVersionToProcess,
} from "./models/next_version_to_process";

function move2ethAddress(addr) {
  addr = addr.toLowerCase();
  return "0x" + addr.slice(-40);
}
function toHex(num: number) {
  return "0x" + num.toString(16);
}

async function parseLogs(
  block_hash: string,
  events: any,
  evm_hash: string,
  blockNumber: bigint,
  version: bigint,
) {
  let logs: any = [];
  for (let i = 0; i < events.length; i++) {
    const data = events[i];
    logs.push({
      address: move2ethAddress(data.contract),
      topics: data.topics,
      data: data.data,
      blockNumber: blockNumber,
      transactionHash: evm_hash,
      version,
      blockHash: block_hash,
      logIndex: toHex(i),
      removed: false,
    });
  }
  return logs.map((log) => {
    const {
      address,
      version,
      topics,
      data,
      blockNumber,
      transactionHash,
      blockHash,
      logIndex,
    } = log;
    let evt = new EvmLogs();
    evt.logIndex = logIndex;
    evt.blockNumber = blockNumber;
    evt.blockHash = blockHash;
    evt.version = version;
    evt.transactionHash = transactionHash;
    evt.address = address;
    evt.data = data || "0x";
    evt.topic0 = topics[0] || "0x0";
    evt.topic1 = topics[1] || "0x1";
    evt.topic2 = topics[2] || "0x2";
    evt.topic3 = topics[3] || "0x3";
    evt.topic4 = topics[4] || "0x4";
    return evt;
  });
}

const blockNumberToHash = new Map<bigint, string>();

async function getBlockHashByNumber(dataSource: DataSource, number: bigint) {
  if (blockNumberToHash.has(number)) {
    return blockNumberToHash.get(number)!;
  }
  while (true) {
    try {
      const info = await dataSource.query(
        `select id from block_metadata_transactions where block_height = ${parseInt(number.toString())} limit 1`,
      );
      // console.log("get block info", info)
      if (info && info.length > 0) {
        blockNumberToHash.set(number, info[0].id);
        return info[0].id;
      }
    } catch (e) {
      // console.log("get block info error", e)
    }
    await new Promise((resolve) => setTimeout(resolve, 100));
  }
}

export class EvmProcessor extends TransactionsProcessor {
  name(): string {
    return "evm_processor";
  }

  async processTransactions({
    transactions,
    startVersion,
    endVersion,
    dataSource,
  }: {
    transactions: aptos.transaction.v1.Transaction[];
    startVersion: bigint;
    endVersion: bigint;
    dataSource: DataSource; // DB connection
  }): Promise<ProcessingResult> {
    let allLogs: EvmLogs[] = [];
    let hashArr: EvmHash[] = [];
    let errorTxhArr: EvmErrorHash[] = [];
    for (const transaction of transactions) {
      // Filter out all transactions that are not User Transactions
      if (
        transaction.type !=
        aptos.transaction.v1.Transaction_TransactionType.TRANSACTION_TYPE_USER
      ) {
        continue;
      }
      const transactionBlockHeight = transaction.blockHeight!;
      const userTransaction = transaction.user!;
      // console.log("Processing EVM transaction", transaction);
      const is_evm_tx =
        userTransaction?.request?.payload?.entryFunctionPayload
          ?.entryFunctionIdStr === "0x1::evm::send_tx";
      if (!is_evm_tx) {
        continue;
      }
      let evmTx;
      try {
        //@ts-ignore
        const tx =userTransaction.request.payload.entryFunctionPayload.arguments[0].replaceAll('"',"",);
        evmTx = ethers.Transaction.from(tx);
      } catch (error) {
        // maybe this payload is not a valid tx skip it
        continue;
      }
      const evm_hash = evmTx.hash;
      const move_tx_hash =
        "0x" + Buffer.from(transaction.info!.hash!).toString("hex");
      if (transaction.info?.success === true) {
        // this is evm hash, pase logs
        let item = new EvmHash();
        item.evm_hash = evm_hash;
        item.move_hash = move_tx_hash;
        item.version = transaction.version!.toString();
        item.blockNumber = transactionBlockHeight.toString();
        hashArr.push(item);
        const events: any = userTransaction?.events?.filter((it) => {
          return it.typeStr === "0x1::evm::ExecResultEvent";
        });
        if (!events || events.length === 0) {
          continue;
        }
        const blockHash = await getBlockHashByNumber(
          dataSource,
          transactionBlockHeight,
        );

        const logs = await parseLogs(
          blockHash,
          JSON.parse(events[0].data).logs,
          item.evm_hash,
          transactionBlockHeight,
          transaction.version!,
        );
        allLogs = allLogs.concat(logs);
      } else {
        let item = new EvmErrorHash();
        item.evm_hash = evm_hash;
        item.move_hash = move_tx_hash;
        item.version = transaction.version!.toString();
        item.blockNumber = transactionBlockHeight.toString();
        errorTxhArr.push(item);
      }
    }
    await dataSource.transaction(async (txnManager) => {
      // the first is the hash of the transaction
      if (hashArr.length > 0) {
        await txnManager.insert(EvmHash, hashArr);
      }
      if (errorTxhArr.length > 0) {
        await txnManager.insert(EvmErrorHash, errorTxhArr);
      }
      // Insert in chunks of 100 at a time to deal with this issue:
      // https://stackoverflow.com/q/66906294/3846032
      if (allLogs.length > 0) {
        const chunkSize = 100;
        for (let i = 0; i < allLogs.length; i += chunkSize) {
          const chunk = allLogs.slice(i, i + chunkSize);
          await txnManager.insert(EvmLogs, chunk);
        }
      }
      const nextVersionToProcess = createNextVersionToProcess({
        indexerName: this.name(),
        version: endVersion + 1n,
      });
      await txnManager.upsert(NextVersionToProcess, nextVersionToProcess, [
        "indexerName",
      ]);
    });
    return {
      startVersion,
      endVersion,
    };
  }
}
