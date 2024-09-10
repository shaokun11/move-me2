const fs = require('fs');

function generateEvmTest(addresses, codes, balances, nonces, storages, transaction, env, dataIndex, gasIndex, valueIndex) {

    const templateFilePath = './template_file.move';
    let templateCode = fs.readFileSync(templateFilePath, 'utf8');
    let envContent = generateEnv(env);
    let storageContent = generateStorage(storages)
    let gas_price = transaction.maxPriorityFeePerGas ? `vector[${toData(transaction.maxFeePerGas)}, ${toData(transaction.maxPriorityFeePerGas)}]`: `vector[${toData(transaction.gasPrice)}]`
    let tx_type = transaction.maxPriorityFeePerGas ? 2: 1

    templateCode = templateCode.replace('$env', `vector[${envContent}]`);
    templateCode = templateCode.replace('$storages', storageContent);
    templateCode = templateCode.replace('$addresses', `vector[${addresses.map(addr => toBytes(addr)).join(', ')}]`);
    templateCode = templateCode.replace('$codes', `vector[${codes.join(', ')}]`);
    templateCode = templateCode.replace('$balances', `vector[${balances.join(', ')}]`);
    templateCode = templateCode.replace('$nonces', `vector[${nonces.join(', ')}]`);
    templateCode = templateCode.replace('$from', toBytes(transaction.sender));
    templateCode = templateCode.replace('$to', toBytes(transaction.to));
    templateCode = templateCode.replace('$data', toBytes(transaction.data[dataIndex]));
    templateCode = templateCode.replace('$gas_limit', toData(transaction.gasLimit[gasIndex]));
    templateCode = templateCode.replace('$gas_price', gas_price);
    templateCode = templateCode.replace('$value', toData(transaction.value[valueIndex]));
    templateCode = templateCode.replace('$tx_type', tx_type);

    let access_list = ''
    if(transaction.accessLists && transaction.accessLists[dataIndex] && transaction.accessLists[dataIndex].length > 0) {
        access_list = generateAccessList(transaction.accessLists[dataIndex])
    }
    templateCode = templateCode.replace('$access_list', access_list);

    const newFilePath = '../../aptos-move/framework/aptos-framework/tests/evm/evm_test.move';
    fs.writeFileSync(newFilePath, templateCode);

    console.log("gen complete")
}

function generateAccessList(accessList) {
    let content = ''
    for(let item of accessList) {
        content += `vector::push_back(&mut access_addresses, ${toBytes(item.address)});\n`
        content += `vector::push_back(&mut access_keys, vector[${item.storageKeys.map(i => toBytes(i))}]);\n`
    }

    return content
}

function generateStorage(storage) {
    let content = ''
    for(let item of storage) {
        content += `simple_map::add(&mut storage_maps, ${toBytes(item.addr)}, init_storage(vector[${Object.keys(item.content)}], vector[${Object.values(item.content)}]\n));`
    }

    return content
}

function generateEnv(env) {
    return [toData(env.currentBaseFee),
        toBytes(env.currentCoinbase),
        toData(env.currentDifficulty),
        toData(env.currentExcessBlobGas),
        toData(env.currentGasLimit),
        toData(env.currentNumber),
        toBytes(env.currentRandom),
        toData(env.currentTimestamp)
        ]
}

function toData(number) {
    return `u256_to_data(${number})`
}

function toBytes(str) {
    return `x"${str.slice(2)}"`
}

function read(json_path, key, dataIndex, gasIndex, valueIndex) {
    let content = JSON.parse(fs.readFileSync(json_path).toString());
    let funName = key.length > 0 ? key : Object.keys(content)[0];
    let pre = content[funName].pre;
    let transactions = content[funName].transaction;
    let env = content[funName].env;
    let addresses = Object.keys(pre);
    let codes = []
    let balances = []
    let nonces = []
    let storages = []
    for(let item of addresses) {
        codes.push(toBytes(pre[item].code))
        balances.push(pre[item].balance)
        nonces.push(pre[item].nonce)
        if(Object.keys(pre[item].storage).length > 0) {
            storages.push({addr: item, content: pre[item].storage})
        }
    }

    generateEvmTest(addresses, codes, balances, nonces, storages, transactions, env, dataIndex, gasIndex, valueIndex);
}

let key = "src/GeneralStateTestsFiller/Pyspecs/cancun/eip1153_tstore/test_tstorage_create_contexts.py::TestTransientStorageInContractCreation::test_contract_creation[fork_Cancun-state_test-across_constructor_and_deployed_code_v0-create2]"
read("./src/GeneralStateTests/Pyspecs/cancun/eip1153_tstore/contract_creation.json", key, 0, 0, 0)