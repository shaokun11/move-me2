# Running Your Own Imola Node

### System Configuration
> ubuntu22.04  
> c5.9x.large  
> 1000g ssd  

### Setup Steps
> Please note that the following ports should not be changed, and all services are running on the same machine (postgres maybe not)

1. Clone this project and switch the branch to mevm2.0:
```bash
git clone https://github.com/movementlabsxyz/movement-v2
git checkout -b mevm2.0 origin/mevm2.0
```

2. Set up the environment:
```bash
# Increase the memory limit, otherwise you may encounter stack errors
ulimit -s 16384

./scripts/dev_setup.sh
```

3. Compile Aptos:
```bash
cargo build -p aptos-node --release
```

4. Update the node configuration [fullnode.yaml](fullnode.yaml):
- Replace `/home/ubuntu/aptos-node-sync/data` with the directory where you want to store the node data
- Replace `/home/ubuntu/aptos-node-sync/waypoint.txt` with the actual path to the [waypoint](waypoint.txt) file
- Replace `/home/ubuntu/aptos-node-sync/genesis.blob` with the actual path to the [genesis](genesis.blob) file

5. Run the node:
```bash
# Navigate to the compiled aptos-node directory
cd target/release
# Assuming the fullnode.yaml from step 4 is in this directory
# The p2p node at 3.255.148.243 is currently not open, please contact the node administrator if you need to synchronize
./aptos-node -f fullnode.yaml
# output.log
# INFO state-sync/state-sync-driver/src/bootstrapper.rs:174 {"message":"Adding a new epoch to the epoch ending ledger infos. Epoch: 972, Version: 203558, Ends epoch: true, Waypoint: Ok(Waypoint { version: 203558, value: HashValue(e3e8afd4f905ddb7cbeb5742b8b20897c9686aadc0edb61b440749c4971a7e5e) })","name":"bootstrapper"}

# Check the synchronization progress when the ledger_version is same
curl https://aptos.devnet.imola.movementlabs.xyz/api/v1

curl http://127.0.0.1:8080/v1
```
- output.json
```json
{
	"chain_id": 4,
	"epoch": "37575",
	"ledger_version": "13604690",
	"oldest_ledger_version": "0",
	"ledger_timestamp": "1724024449202228",
	"node_role": "full_node",
	"oldest_block_height": "0",
	"block_height": "5231519",
	"git_hash": "b1dbe72fc83b9a65a9131a8523cb96fc84db030f"
}
```

6. Initialize the indexer database:
```bash
# Prepare a postgres database and get a similar URL
export db_url=postgres://postgres@localhost:5432/apt-indexer 

# Install diesel
cargo install diesel_cli --no-default-features --features postgres

# Get the migrations files
git clone https://github.com/aptos-labs/aptos-indexer-processors.git

cd rust/processor/src/db/postgres

diesel migration run --database-url=$db_url
```

7. Run the Aptos indexer:
```bash
cargo build -p aptos-me-indexer --release
cd target/release

./aptos-me-indexer node run-local-testnet --with-indexer-api --postgres-url $db_url
```

8. Run the [EVM indexer](infrastructure/evm-indexer):
```bash
cd infrastructure/evm-indexer
npm i
cp config .config
# Update the db_connection_uri to your actual db_url
db_connection_uri: "postgres://postgres@127.0.0.1:5433/apt-indexer"

node dist/index.js
# { message: '[Parser] Response received', startVersion: 14971870n }
```

9. Start the GraphQL service:
> Ensure that you have Docker installed beforehand
```bash
docker run -d -p 8090:8080 -e HASURA_GRAPHQL_DATABASE_URL=$db_url -e HASURA_GRAPHQL_ENABLE_CONSOLE=true   hasura/graphql-engine:latest
```

10. Import the Hasura metadata:
- Go to 127.0.0.1:8090/console
- Select the SETTINGS option in the top right
- Choose Import Metadata
- Select the hasura_metadata_2024_08_23_13_10_28_300.json file in this directory to import

11. Start the [MEVM node](infrastructure/evm-rpc):
```bash
cd infrastructure/evm-rpc

cp .env.example .env

npm i

node src/app.js


# If you want to enable sending transactions to the chain, update the environment variables as follows. This operation is only effective if the node has synchronized to the latest state.
DISABLE_SEND_TX=false
# Ensure that the evm_sender's Move account has enough Move tokens
EVM_SENDER=0xf238ff22567c56bdaa18105f229ac0dacc2d9f73dfc5bf08a2a2a4a0fac4d220
```

12. Test the MEVM node:
```bash
curl http://127.0.0.1:8998/ \
-X POST \
 -H "Content-Type: application/json" \
--data '{"method":"eth_getBlockByNumber","params":["0x234",false],"id":1,"jsonrpc":"2.0"}'
```

output.json
```json
{
	"jsonrpc": "2.0",
	"id": 1,
	"result": {
		"baseFeePerGas": "0x12a05f200",
		"difficulty": "0x10000000000000",
		"extraData": "0xf623dd376af0f1583552511b4d4b90d197fc08858f54dec19e9d9f90a4ae5009",
		"gasLimit": "0x1c9c380",
		"gasUsed": "0x1312d00",
		"hash": "0x41dd422f451b60f2755b946af4649745f60db472ac0e5f40a386ee3583ace9b5",
		"logsBloom": "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
		"miner": "0x0000000000000000000000000000000000000000",
		"mixHash": "0x84ddd21add232929f0483cd3da3658fc9ca5d1a479f1070a6cc4ca914ce67d01",
		"nonce": "0x10000000000004d2",
		"number": "0x234",
		"parentHash": "0xeaf88ee094d8c42e55444f39543cfdf561e7999c84092e0b09a76010263110f4",
		"receiptsRoot": "0x679a8f40fadfebe96028282c1b05dd0d0052db6184cdcb00b2b8c741168c6071",
		"sha3Uncles": "0x0fe86a9d820e22249cf62d3fb0459437c00a1695860c5f85a17ad518d9d25423",
		"size": "0x1c9c380",
		"stateRoot": "0xad7468a1cea68e967b3814e7ca7d67a6d2d82e49fa35b6ecd0cfc5b8d8e8281c",
		"timestamp": "0x669deb01",
		"totalDifficulty": "0x100000000000000004d3",
		"transactions": [],
		"transactionsRoot": "0xd92cfeb17f03ff65c2f2a160fe6913d8de9dcbf5202f13c218287c7a09c9ee9c",
		"uncles": []
	}
}
```