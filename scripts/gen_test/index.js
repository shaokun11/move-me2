const fs = require('fs');

function generateModule(tests, name) {
    const header = `#[test_only]
    module aptos_framework::evm_${name} {
    use aptos_framework::evm::{pre, test_run};\n`;
    const footer = `\n}`;

    const testFunctions = tests.map(test => generateEvmTestFunction(
        test.funName,
        test.addresses,
        test.codes,
        test.balances,
        test.nonces,
        test.tx
    )).join('\n');

    return header + testFunctions + footer;
}

function generateEvmTestFunction(funName, addresses, codes, balances, nonces, tx) {
    return `
    #[test]
    fun ${funName}() {
        pre(vector[${addresses.map(addr => `x"${addr.slice(2)}"`).join(', ')}],
            vector[${codes.map(code => `x"${code.slice(2)}"`).join(', ')}],
            vector[${balances.join(', ')}],
            vector[${nonces.join(', ')}]);
        test_run(
            x"${tx.sender.slice(2)}",
            x"${tx.to.slice(2)}",
            x"${tx.input.slice(2)}",
            ${tx.nonce},
            ${tx.value});
    }`;
}


function read(json_path) {
    let content = JSON.parse(fs.readFileSync(json_path).toString());
    let funName = Object.keys(content);
    let pre = content[funName].pre;
    let addresses = Object.keys(pre);
    let codes = []
    let balances = []
    let nonces = []
    for(let item of addresses) {
        codes.push(pre[item].code)
        balances.push(pre[item].balance)
        nonces.push(pre[item].nonce)
    }
    
    let outputs = [];
    console.log(codes)
    console.log(balances)
    content[funName].tests.Cancun.map(test => {
        let tx = test.tx.transaction;
        outputs.push({
            funName: test.id,
            addresses,
            codes,
            balances,
            nonces,
            tx
        })
    })
    let output = generateModule(outputs, funName);
    fs.writeFileSync(`output/evm_${funName}.move`, output);
}

read("src/add.json")