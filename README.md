  
Running movement subnet by yourself.
---

## System Requirements
- System: AWS Ubuntu 22.04
- Configuration: c5.4xlarge
- Hard Disk: 500GB

## Step Setup
0. Prepare system env
```bash
sudo apt update
sudo apt install build-essential
sudo apt install git
```
1. Get the source code
```bash
git clone https://github.com/movementlabsxyz/movement-v2
```
2. Set up the build environment:
```bash
cd ~/movement-v2
./scripts/dev_setup.sh
```
3. Build the subnet binary file:
```bash
cd ~/movement-v2
cargo build -p subnet --release
```
4. Configure the Avalanche environment:
```bash
# Go to the user's root directory
cd ~
# Download and extract avalanchego
wget https://github.com/ava-labs/avalanchego/releases/download/v1.11.1/avalanchego-linux-amd64-v1.11.1.tar.gz
tar -cvf avalanchego-linux-amd64-v1.11.1.tar.gz
# Install avalanche-network-runner
curl -sSfL https://raw.githubusercontent.com/ava-labs/avalanche-network-runner/main/scripts/install.sh | sh -s
   ```
5. Create the subnet configuration files:
```bash
cd ~
mkdir config
cd config
echo "{}" > genesis.json
mkdir plugins
cd plugins
# q69acQzi35gi6ppPAuRowDV2EwUJaAwzMoCd9bwCGm3KwFknK, do not change the file name
cp ~/movement-v2/target/release/subnet q69acQzi35gi6ppPAuRowDV2EwUJaAwzMoCd9bwCGm3KwFknK
```
6. Start the `avalanche-network-runner`:
```bash
avalanche-network-runner server --log-level debug --port=":8080" --grpc-gateway-port=":8081"
```
7. Start the subnet:
> Open a new terminal,it will start the server at `http://127.0.0.1:9650/ext/bc/{chainId}/rpc`. For more options you can refer [avalanche-network-runner](https://github.com/ava-labs/avalanche-network-runner/blob/main/docs/examples.md)

```bash
curl -X POST -k http://localhost:8081/v1/control/start -d '{"execPath":"/home/ubuntu/avalanchego-v1.11.1/avalanchego","numNodes":1,"logLevel":"INFO","pluginDir":"/home/ubuntu/config/plugins","blockchainSpecs":[{"vm_name":"m1","genesis":"/home/ubuntu/config/genesis.json"}]}'
```
>Note down the value of `output.chainIds[0]` in the output, for example, `LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f`.

```json
{
    "clusterInfo": {
        "nodeNames": [
            "node1"
        ],
        "nodeInfos": {
            "node1": {
                "name": "node1",
                "execPath": "/home/ubuntu/avalanchego-v1.11.1/avalanchego",
                "uri": "http://127.0.0.1:9650",
                "id": "NodeID-7Xhw2mDxuDS44j42TCB6U5579esbSt3Lg",
                "logDir": "/tmp/network-runner-root-data/network_20240423_125557/node1/logs",
                "dbDir": "/tmp/network-runner-root-data/network_20240423_125557/node1/db",
                "pluginDir": "/home/ubuntu/config/plugins",
                "whitelistedSubnets": "2c1CbR7FGYdeFPB4WaeWphHZrChLH7TQ92FRW6U4mCWTnaxVsB",
                "config": "",
                "paused": false
            }
        },
        "pid": 261376,
        "rootDataDir": "/tmp/network-runner-root-data/network_20240423_125557",
        "healthy": true,
        "attachedPeerInfos": {

        },
        "customChainsHealthy": true,
        "customChains": {
            "LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f": {
                "chainName": "m1",
                "vmId": "q69acQzi35gi6ppPAuRowDV2EwUJaAwzMoCd9bwCGm3KwFknK",
                "subnetId": "2c1CbR7FGYdeFPB4WaeWphHZrChLH7TQ92FRW6U4mCWTnaxVsB",
                "chainId": "LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f"
            }
        },
        "subnets": {
            "2c1CbR7FGYdeFPB4WaeWphHZrChLH7TQ92FRW6U4mCWTnaxVsB": {
                "isElastic": false,
                "elasticSubnetId": "11111111111111111111111111111111LpoYY",
                "subnetParticipants": {
                    "nodeNames": [
                        "node1"
                    ]
                }
            }
        },
        "networkId": 1337
    },
    "chainIds": [
        "LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f"
    ]
}
```

8. Start the Aptos SDK compatible server:
> Make sure *LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f* come from step 7, this will start server at `http://127.0.0.1:3001`

```bash
cd ~/movement-v2/infrastructure/subnet-proxy
# this is subnet server
echo "URL=http://127.0.0.1:9650/ext/bc/LHYzmqQ1vCmymoHvkkjC6A5CPDZ9TWNXbdhjyK1ESL4vfbn3f/rpc" > .env
npm i
npm start
```

9. Start the EVM-RPC:
> this will start server at `http://127.0.0.1:3044`, EVM chainId is 336

```bash
    cd ~/movement-v2/infrastructure/evm-rpc
    # This is the private key of the move account, used to send evm transactions to the subnet, the corresponding address is       `0xf8be0c08312090f3f9f17ec76d1575d94c032c78c235c3eee562cc5c7b332fcd`
    echo "EVM_SENDER =0xf238ff22567c56bdaa18105f229ac0dacc2d9f73dfc5bf08a2a2a4a0fac4d221" > .env
    # This is the private key of the move account, used to exchange move gas token for eth gas token to the eth account
    echo "FAUCET_SENDER =0xf238ff22567c56bdaa18105f229ac0dacc2d9f73dfc5bf08a2a2a4a0fac4d221" >> .env
    # This is subnet proxy server
    echo "NODE_URL=http://127.0.0.1:3001/v1" >> .env
    npm start
```

10.  Faucet test tokens to your account:

```bash
# Get move test tokens to your move address
curl http://127.0.0.1:3001/v1/mint?address=0xf8be0c08312090f3f9f17ec76d1575d94c032c78c235c3eee562cc5c7b332fcd
# Get move-evm test token to your eth address, please ensure the FAUCET_SENDER account has move tokens
curl http://127.0.0.1:3044/v1/eth_faucet?address=0x8661398C5fC7C55237E18134f53C4314fE563b28
```

11.  Deploy the browser:
> this will start the server at `http://127.0.0.1:3000` 
```bash
cd ~/movement-v2/infrastructure/explorer
npm install --legacy-peer-deps
echo "REACT_APP_MOVE_ENDPOINT=http://127.0.0.1:3001">.env.development
pnpm run start
```
12.  Deploy the faucet web page
> this will start the server at `http://127.0.0.1:3100` ,if the port is used ,you can refer [vue-cli config](https://cli.vuejs.org/guide/cli-service.html#vue-cli-service-serve) to change it
```bash
cd ~/move-dest-v13/infrastructure/bridge-faucet
npm i -g pnpm
pnpm i
echo "VUE_APP_MOVE_RPC=http://127.0.0.1:3001/v1">.env.development
echo "VUE_APP_MOVE_SYMBOL=MOVE">>.env.development
echo "VUE_APP_EXPLORER=http://127.0.0.1:3000">>.env.development
echo "VUE_APP_EVM_RPC=http://127.0.0.1:3044">>.env.development
echo "VUE_APP_CHAINID=336">>.env.development
echo "VUE_APP_SYMBOL=METH">>.env.development
pnpm run start:dev

```