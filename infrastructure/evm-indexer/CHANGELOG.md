## Synchronizing the MEVM-related Indexer

> In the future, this can be implemented in Rust and automatically synchronized when the chain is started.

### Usage

1. Clone this repository.

2. Install the dependencies:
   ```bash
   npm install
   ```

3. Set up the environment variables, please refer to the [config.yaml](./config.yaml) file:
   ```yaml
   chain_id: 4
   grpc_data_stream_endpoint: localhost:50051
   grpc_data_stream_api_key: ""
   starting_version: 1
   db_connection_uri: "postgres://postgres@127.0.0.1:5433/local_testnet"
   ```

4. Start the server:
   ```bash
   npm run start
   ```