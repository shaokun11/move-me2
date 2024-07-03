const fs = require('fs');

function generateEvmTest(addresses, codes, balances, nonces, storages, transaction, env, index) {
    // 读取模板文件
    const templateFilePath = './template_file.move';  // 请将此路径替换为实际文件路径
    let templateCode = fs.readFileSync(templateFilePath, 'utf8');
    let envContent = generateEnv(env);
    let storageContent = generateStorage(storages)
    let gas_price = transaction.maxPriorityFeePerGas ? toData(`${env.currentBaseFee} + ${transaction.maxPriorityFeePerGas}`): toData(transaction.gasPrice)

    // 替换占位符
    templateCode = templateCode.replace('$env', `vector[${envContent}]`);
    templateCode = templateCode.replace('$storages', storageContent);
    templateCode = templateCode.replace('$addresses', `vector[${addresses.map(addr => toBytes(addr)).join(', ')}]`);
    templateCode = templateCode.replace('$codes', `vector[${codes.join(', ')}]`);
    templateCode = templateCode.replace('$balances', `vector[${balances.join(', ')}]`);
    templateCode = templateCode.replace('$nonces', `vector[${nonces.join(', ')}]`);
    templateCode = templateCode.replace('$from', toBytes(transaction.sender));
    templateCode = templateCode.replace('$to', toBytes(transaction.to));
    templateCode = templateCode.replace('$data', toBytes(transaction.data[index]));
    templateCode = templateCode.replace('$gas_limit', toData(transaction.gasLimit[0]));
    templateCode = templateCode.replace('$gas_price', gas_price);
    templateCode = templateCode.replace('$value', toData(transaction.value[0]));

    // 保存到新文件
    const newFilePath = '../../aptos-move/framework/aptos-framework/tests/evm/evm_test.move';  // 请将此路径替换为保存文件的路径
    fs.writeFileSync(newFilePath, templateCode);

    console.log('代码生成完成并保存到新文件');
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

function read(json_path, index) {
    let content = JSON.parse(fs.readFileSync(json_path).toString());
    let funName = Object.keys(content)[0];
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

    generateEvmTest(addresses, codes, balances, nonces, storages, transactions, env, index);
}

read("src/GeneralStateTests/Cancun/stEIP1153-transientStorage/transStorageOK.json", 6)