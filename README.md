## Title
This branch is used to demonstrate compiling the SUI Counter contract and deploying it on Aptos.

## Steps

1. Clone this repository and switch to the branch.

2. Go to the root directory and execute `cargo run -p aptos-node -- --test` to start the node. You will see the output with the necessary information.Note the following values: **Aptos root key path**
```txt
        Log file: "/tmp/7ae7a3ab45671ae51a009615442cb1b0/validator.log"
        Test dir: "/tmp/7ae7a3ab45671ae51a009615442cb1b0"
        Aptos root key path: "/tmp/7ae7a3ab45671ae51a009615442cb1b0/mint.key"
        Waypoint: 0:f034368c8bce67180f70ec2c943182e1f61633c9b28c18c23244b0ef11f05c2e
        ChainId: testing
        REST API endpoint: http://0.0.0.0:8080
        Metrics endpoint: http://0.0.0.0:9101/metrics
        Aptosnet fullnode network endpoint: /ip4/0.0.0.0/tcp/6181
```

3. Open a new terminal window and start the faucet service using the command: `cargo run -p aptos-faucet-service -- run-simple --key-file-path "/tmp/7ae7a3ab45671ae51a009615442cb1b0/mint.key" --node-url http://0.0.0.0:8080 --chain-id testing`. Make sure to replace the `--key-file-path` value with the actual path obtained in the previous step with **Aptos root key path**.
4. Open a new terminal window and use `cargo run -p aptos -- init` to select the local network and create a new account.(Please note that in the following text, replace **${0xa}** with the address you provided.)

5. Replace the `7fb9d233fce09d16df966695362cdafa102e355c6f05c2b4cab4dda9cf8d9084` in the `Move.toml` file of the [SUI Counter](sui-contract/counter/Move.toml) contract with **${0xa}**. 

6. Execute `cargo run -p aptos -- account fund-with-faucet && cargo run -p aptos -- move publish --assume-yes` in the root directory of [SUI Counter](sui-contract/counter).
```javascript
{
  "Result": {
    "transaction_hash": "0x58304df3402fe886dc43de6eaa08d2f59832b1751f2fe8b892b2f6eaed8dbf9f",
    "gas_used": 1316,
    "gas_unit_price": 100,
    "sender": "6fb6049c27df20d6e38fc3a3d928d211fac42652b585ef2b9077fda1194d815c",
    "sequence_number": 0,
    "success": true,
    "timestamp_us": 1710341152710829,
    "version": 578,
    "vm_status": "Executed successfully"
  }
}
```
7. Call counter create function with `cargo run -p aptos -- move run --function-id ${0xa}::counter::create --args u64:10`

```javascript
{
  "Result": {
    "transaction_hash": "0xe533a5e2ea29b386962d66131085f4277ae12866a0fec6ee3836d0e9ef1de93b",
    "gas_used": 505,
    "gas_unit_price": 100,
    "sender": "6fb6049c27df20d6e38fc3a3d928d211fac42652b585ef2b9077fda1194d815c",
    "sequence_number": 1,
    "success": true,
    "timestamp_us": 1710341167959551,
    "version": 611,
    "vm_status": "Executed successfully"
  }
}
```

8.Retrieve the object information using a Node.js script based on the previously obtained *transaction_hash*

```javascript
const aptos = require("aptos");
const util = require("node:util");
const NODE_URL = "http://127.0.0.1:8080";
const FAUCET_URL = "http://127.0.0.1:8081";
const client = new aptos.AptosClient(NODE_URL);
const faucetClient = new aptos.FaucetClient(NODE_URL, FAUCET_URL);
async function checkTxResult(tx) {
    const res = await client.getTransactionByHash(tx);
    // remember replace with **${0xa}**
    let counter_type = "0x6fb6049c27df20d6e38fc3a3d928d211fac42652b585ef2b9077fda1194d815c::counter::Counter";
    if (res.success) {
        const item = res.changes.filter((item) => {
            return item.data?.type == counter_type;
        });
        console.log(util.inspect(item[0], false, null, true /* enable colors */));
    }
}
checkTxResult("0xe533a5e2ea29b386962d66131085f4277ae12866a0fec6ee3836d0e9ef1de93b");
```
```javascript
{
  address: '0x76390ad4724ee3a9a8445830e4652125d228e82d358b37325f9b8241610e0b5f',
  state_key_hash: '0x402439921d1ca08b14eac6b623ba39768a0339f47a4e24acc24f5e664636f78e',
  data: {
    type: '0x6fb6049c27df20d6e38fc3a3d928d211fac42652b585ef2b9077fda1194d815c::counter::Counter',
    data: {
      id: {
        id: {
          bytes: '0x76390ad4724ee3a9a8445830e4652125d228e82d358b37325f9b8241610e0b5f'
        }
      },
      owner: '0x6fb6049c27df20d6e38fc3a3d928d211fac42652b585ef2b9077fda1194d815c',
      value: '10'
    }
  },
  type: 'write_resource'
}
```
9.Query object value with object id by run
 `cargo run -p aptos -- move view --function-id ${0xa}::counter::get_value --args address:0x76390ad4724ee3a9a8445830e4652125d228e82d358b37325f9b8241610e0b5f`.
>`0x76390ad4724ee3a9a8445830e4652125d228e82d358b37325f9b8241610e0b5f` based on the previously obtained by path *obj.data.data.id.id.bytes*

```javascript
{
  "Result": [
    "10"
  ]
}
```

10.Call counter increment function with object id by run `cargo run -p aptos -- move run --function-id ${0xa}::counter::increment --args address:0x76390ad4724ee3a9a8445830e4652125d228e82d358b37325f9b8241610e0b5f`

11.repeat `step 9`

```javascript
{
  "Result": [
    "11"
  ]
}
```