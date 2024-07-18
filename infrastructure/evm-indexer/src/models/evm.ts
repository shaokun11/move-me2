import {
  Entity,
  PrimaryColumn,
  Column,
  PrimaryGeneratedColumn,
  Index,
} from "typeorm";
import { Base } from ".";

@Entity("evm_logs")
@Index(["blockNumber", "address"])
@Index(["blockNumber", "address", "topic0"])
@Index(["blockNumber", "address", "topic0", "topic1"])
@Index(["blockNumber", "address", "topic0", "topic1", "topic2"])
@Index(["blockNumber", "address", "topic0", "topic1", "topic2", "topic3"])
@Index([
  "blockNumber",
  "address",
  "topic0",
  "topic1",
  "topic2",
  "topic3",
  "topic4",
])
export class EvmLogs extends Base {
  @PrimaryGeneratedColumn({ type: "bigint" })
  id!: string;

  @Column()
  logIndex!: string;

  @Column({ type: "bigint" })
  blockNumber!: string;

  @Column({ type: "bigint" })
  version!: string;

  @Column({ length: 66 })
  blockHash!: string;

  @Column({ length: 66 })
  transactionHash!: string;

  @Column({ length: 42 })
  address!: string;

  @Column({ type: "text" })
  data!: string;

  @Column({ length: 66 })
  topic0!: string;

  @Column({ length: 66 })
  topic1!: string;

  @Column({ length: 66 })
  topic2!: string;

  @Column({ length: 66 })
  topic3!: string;

  @Column({ length: 66 })
  topic4!: string;
}
@Entity("evm_move_hash")
export class EvmHash extends Base {
  @PrimaryColumn({ length: 66 })
  evm_hash!: string;

  @PrimaryColumn({ length: 66 })
  move_hash!: string;

  @Column({ type: "bigint" })
  blockNumber!: string;

  @Column({ type: "bigint" })
  version!: string;
}
