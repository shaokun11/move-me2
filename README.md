## Title
This branch is used to demonstrate compiling the SUI Counter contract and deploying it on Aptos.

## Steps

1. Clone this repository and switch to the branch.

2. Execute `cargo build -p aptos --release` to obtain the `aptos` binary file in the `target/release` directory. Add it to the environment variables and ensure it can be accessed globally.

3. Start the test network by running `aptos node run-local-testnet --with-faucet`.

4. Open a new terminal window and use `aptos init` to select the local network and create a new account.

5. Replace the `0x1` in the `Move.toml` file of the [SUI Counter](sui-contract/counter/Move.toml) contract with the created account (Please note that the account must start with *0x* at *Move.toml*).

6. Navigate to the root directory of the [SUI Counter](sui-contract/counter) contract and compile it using `aptos move compile --package-dir sui-counter --save-metadata`.

7. Execute `aptos move publish` in the root directory of [SUI Counter](sui-contract/counter).
