Movement Evm Stress Test
=====================

A stress test for the Movement subnet project.

Usage
-----

To run the stress test, execute the following command:

```bash
cargo run --release execute
```

Available Options
-----------------

The following options can be used with the stress test:

- `--num-accounts <NUM_ACCOUNTS>`: Sets the number of accounts to be used in the test. (default: 100,000)
- `--num-warmups <NUM_WARMUPS>`: Sets the number of warm-up iterations to be performed before the actual test. (default: 5)
- `--block-size <BLOCK_SIZE>`: Sets the size of each block in the test. (default: 10,000)
- `--num-blocks <NUM_BLOCKS>`: Sets the number of blocks to be executed in the test. (default: 15)
- `--concurrency-level-per-shard <CONCURRENCY_LEVEL_PER_SHARD>`: Sets the concurrency level per shard. (default: 8)
- `--num-executor-shards <NUM_EXECUTOR_SHARDS>`: Sets the number of executor shards. (default: 1)
- `--remote-executor-addresses <REMOTE_EXECUTOR_ADDRESSES>...`: Specifies the addresses of remote executors to be used in the test.
- `--no-conflict-txns`: Disables conflict transactions in the test.
- `--maybe-block-gas-limit <MAYBE_BLOCK_GAS_LIMIT>`: Sets the gas limit for maybe-block transactions. 
- `--generate-then-execute`: Generates transactions first and then executes them.
- `-h`, `--help`: Displays the help message.

Please refer to the command `cargo run --release execute --help` for more information on the available options.

