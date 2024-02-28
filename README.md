## Title
This branch is used to demonstrate compiling the SUI Counter contract and deploying it on Aptos.

## Steps

1. Clone this repository and switch to the branch.

2. Go to the root directory and execute `cargo run -p aptos-node -- --test` to start the node. You will see the output with the necessary information.Note the following values: **Aptos root key path**
```
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

4. Open a new terminal window. Replace the `0x1` in the `Move.toml` file of the [SUI Counter](sui-contract/counter/Move.toml) contract with the created account. Please note that the account must start with `0x`, as specified in the `Move.toml` file.

5. Execute `yes | cargo run -p aptos -- move publish` in the root directory of [SUI Counter](sui-contract/counter).
```
{
  "Result": {
    "transaction_hash": "0x803bfae0b82ca06e99fb44eafe7caa394939685a50a5ead65bd52e8c2dad7d49",
    "gas_used": 255,
    "gas_unit_price": 100,
    "sender": "99ea09721d9c0209284139bb0c1eeb9ab358c45176b60bc321b52fa6c280a265",
    "sequence_number": 3,
    "success": true,
    "timestamp_us": 1709134318410205,
    "version": 2546,
    "vm_status": "Executed successfully"
  }
}
```
