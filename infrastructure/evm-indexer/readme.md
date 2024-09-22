## Sync EVM Metadata

If the chain's data is reset, please follow the steps below to resync the EVM data. This data will be a dependency for `evm-rpc`.

### Steps to Resync EVM Data

1. Install the necessary packages:
    ```bash
    npm i
    ```

2. Build the project:
    ```bash
    npm run build
    ```

3. Run the index script:
    ```bash
    cp config.yaml .config.yaml
    node dist/index.js
    ```

4. Make the sync script executable:
    ```bash
    chmod +x sync.sh
    ```

5. Execute the sync script:
    ```bash
    ./sync.sh
    ```