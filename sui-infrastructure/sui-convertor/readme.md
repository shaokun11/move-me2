
Please follow the instructions below to convert SUI's Counter contract to APTOS SUI's contract.

### Prerequisites

- Node.js and npm should be installed on your system.

### Installation

1. Install the dependencies.

```bash
npm install
```

### Conversion

1. Execute the conversion command. The counter contract from `https://github.com/MystenLabs/sui/blob/main/sui_programmability/examples/basics/sources/counter.move`

```bash
node index.js
```

This command will convert the Counter contract from SUI to APTOS SUI and save it in the "counter-apt" directory.

2. Navigate to the "counter-apt" directory.

```bash
cd counter-apt
```

3. Generate bytecode and metadata for deployment on the APTOS chain.

```bash
aptos move compile
```

The bytecode and metadata files will be generated, which can be used to deploy the contract on the APTOS chain.

### Conclusion

By following these instructions, you will be able to convert SUI's Counter contract to APTOS SUI's contract and generate the necessary files for deployment on the APTOS chain.