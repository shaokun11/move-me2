Here are the steps to run the movement chain and move-evm by yourself:

## System Requirements
- System: AWS Ubuntu 22.04
- Configuration: c5.4xlarge
- Hard Disk: 500GB

## Setup Steps
0. Prepare the system environment:
```bash
sudo apt update
sudo apt install build-essential
sudo apt install git
```

1. Install Docker and Docker Compose following the [Docker installation guide](https://docs.docker.com/engine/install/ubuntu/).

2. Get the source code:
```bash
git clone https://github.com/movementlabsxyz/movement-v2
git checkout -b m1-new m1-new
```

3. Set up the build environment:
```bash
cd ~/movement-v2
./scripts/dev_setup.sh
```

4. Run the Move chain:
> This will start the Move chain on port 8080 and the gas faucet functionality on port 8081.
```bash
cd ~/movement-v2
cargo run --bin aptos node run-local-testnet --with-indexer-api 
```

5. Start the EVM indexer:
```bash
cd ~/movement-v2
cd ./infrastructure/evm-indexer
npm i 
npm start
```

6. Start the EVM-RPC:
> This will start the server at `http://127.0.0.1:8898`. The EVM chain ID is 336.
```bash
cd ~/movement-v2
cd ./infrastructure/evm-rpc
cp .env.example .env
npm i 
npm start
```

7. Get the gas token required for MEVM:
```bash
curl --location 'http://127.0.0.1:8081/fund' \
--header 'Content-Type: application/json' \
--data '{
    "address": "0xef484a99792ccba1be68dc29cdad33726f6e6c16817dfff98a7f6a5fa19c9b9b",
    "amount": 1000000000
}'
```

8. Faucet test tokens to your Ethereum account:
```bash
curl --location 'http://127.0.0.1:8998' \
--header 'Content-Type: application/json' \
--data '{
    "id": "1",
    "jsonrpc": "2.0",
    "method": "eth_faucet",
    "params": [
        "0xfcA2FBA9427f9100c14c6c2f175BC9eC744a77cf"
    ]
}'
```