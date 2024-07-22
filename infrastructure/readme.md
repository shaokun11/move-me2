## Move EVM Infrastructure

The Move Subnet infrastructure consists of the following components:

### Components

- **evm-rpc**: 
  A service that offers RPC capabilities for move chain. It can be used by projects in the EVM ecosystem, such as Metamask, ethers, and others.
  
- **explorer**: 
  An explorer specifically designed for move chain, allowing users to explore and navigate through its functionalities.
  
- **evm-indexer**: 
  Collects EVM transaction data for use by evm-rpc.
  
- **faucet-web**: 
  Web interface for the faucet.

- **move-faucet-server**: 
  A server that provides gas tokens for move chain.
