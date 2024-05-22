import { DataSource } from "typeorm";
import { ProcessingResult, TransactionsProcessor } from "./processor";
import { aptos } from "@aptos-labs/aptos-protos";
import { EvmHash, EvmLogs } from "./models/evm";

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
  let evmLogs = [0, 1, 2, 3, 4].map((it) => `0x1::evm::Log${it}Event`);
  events = events.filter((it) => evmLogs.includes(it.typeStr));
  for (let i = 0; i < events.length; i++) {
    const data = JSON.parse(events[i].data);
    const event = events[i];
    let topics: any = [];
    if (data.topic0) {
      topics.push(data.topic0);
    } else {
      topics.push("0x0");
    }
    if (data.topic1) {
      topics.push(data.topic1);
    } else {
      topics.push("0x1");
    }
    if (data.topic2) {
      topics.push(data.topic2);
    } else {
      topics.push("0x2");
    }
    if (data.topic3) {
      topics.push(data.topic3);
    } else {
      topics.push("0x3");
    }
    if (data.topic4) {
      topics.push(data.topic4);
    } else {
      topics.push("0x4");
    }
    logs.push({
      address: move2ethAddress(data.contract),
      topics,
      data: data.data,
      blockNumber: blockNumber,
      transactionHash: evm_hash,
      version,
      transactionIndex: toHex(0),
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
      transactionIndex,
      blockHash,
      logIndex,
    } = log;
    let evt = new EvmLogs();
    evt.logIndex = logIndex;
    evt.blockNumber = blockNumber;
    evt.blockHash = blockHash;
    evt.version = version;
    evt.transactionHash = transactionHash;
    evt.transactionIndex = transactionIndex;
    evt.address = address;
    // evt.topics = JSON.stringify(topics)
    evt.data = data || "0x";
    evt.topic0 = topics[0];
    evt.topic1 = topics[1];
    evt.topic2 = topics[2];
    evt.topic3 = topics[3];
    evt.topic4 = topics[4];
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
        `select id from block_metadata_transactions where block_height = ${parseInt(number.toString())} limit 1`
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
      if (transaction.info?.success === false) {
        // evm transaction failed,no need to parse logs
        continue;
      }
      // console.log("Processing EVM transaction", transaction)
      const events: any = userTransaction?.events?.filter((it) => {
        return it.typeStr === "0x1::evm::TXHashEvent";
      });
      if (!events || events.length === 0) {
        continue;
      }
      const move_tx_hash =
        "0x" + Buffer.from(transaction.info!.hash!).toString("hex");
      // this is evm hash, pase logs
      const data = JSON.parse(events[0].data);
      let item = new EvmHash();
      item.evm_hash = data.evm_tx_hash;
      item.move_hash = move_tx_hash;
      item.version = transaction.version!.toString();
      item.blockNumber = transactionBlockHeight.toString();
      hashArr.push(item);
      const blockHash = await getBlockHashByNumber(dataSource, transactionBlockHeight)
      const logs = await parseLogs(
        blockHash,
        userTransaction.events,
        item.evm_hash,
        transactionBlockHeight,
        transaction.version!,
      );
      allLogs = allLogs.concat(logs);
    }

    await dataSource.transaction(async (txnManager) => {
      // the first is the hash of the transaction
      if (hashArr.length > 0) {
        await txnManager.insert(EvmHash, hashArr);
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
    });
    return {
      startVersion,
      endVersion,
    };
  }
}
