
### Move Evm Infrastructure
```bash
├── evm-indexer
├── evm-rpc 
├── explorer 
├── move-faucet-server
├── faucet-web
```
The Move Evm infrastructure consists of the following components:

- **evm-indexer**: Used to synchronize Move data to the indexer, in coordination to implement EVM functionality.
- **evm-rpc**: A service that offers RPC capabilities for the Move Subnet. It can be used by projects in the EVM ecosystem, such as Metamask, ethers, and others.
- **explorer**: An explorer specifically designed for the Move Chain, allowing users to explore and navigate through its functionalities.
- **move-faucet-server**: Server implementation of the Move faucet.
- **faucet-web**: Web page for the Move faucet.

