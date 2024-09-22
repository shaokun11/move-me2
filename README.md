# Build from source

## System Requirements
- System: AWS Ubuntu 22.04
- Configuration: c5.2xlarge
- Hard Disk: 500GB

## Setup Steps
0. Prepare the system environment:
```bash
sudo apt update
sudo apt install build-essential
sudo apt install git
```

1. Install Docker and Docker Compose following the [Docker installation guide](https://docs.docker.com/engine/install/ubuntu/).
> please make sure add the user ubuntu to the docker with `sudo usermod -aG docker ubuntu`

2. Get the source code:
```bash
git clone https://github.com/movementlabsxyz/movement-v2
git checkout mevm2.0
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
# if you want reset chain data , add --force-restart option
cargo run --bin aptos node run-local-testnet --with-indexer-api 

```
5. Get the test token
```bash
cargo run --bin aptos account fund-with-faucet --faucet-url http://127.0.0.1:8081 --url http://127.0.0.1:8080 --account 0x51db4a29acaa390e45422f031e1f10acb88c2422ac79bac2102c285ed959ebbf --amount 10000000000
```
6. [Running evm indexer ](./infrastructure/evm-indexer/)
7. [Running evm rpc](./infrastructure/evm-rpc/)
8. [Running explorer](./infrastructure/explorer/)


### Deployment info

| Service                | URL                                              |
|------------------------|--------------------------------------------------|
| MEVM RPC               | https://mevm.devnet.imola.movementlabs.xyz |
| CHAIN ID               | 30732                                            |
| APTOS URL              | https://aptos.devnet.imola.movementlabs.xyz/api/v1 |
| APTOS INDEXER URL      | https://aptos.devnet.imola.movementlabs.xyz/indexer/v1/graphql |
| FAUCET WEB             | https://faucet.devnet.imola.movementlabs.xyz |
| EXPLORER               | https://explorer.devnet.imola.movementlabs.xyz |
| Server Info            | eu-west-1 m1.testnet.node  

