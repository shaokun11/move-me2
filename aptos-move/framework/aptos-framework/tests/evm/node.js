const fs = require('fs');

function generateEvmTest(funName, addresses, codes, balances, nonces, from, to, data, nonce, value) {
    // 读取模板文件
    const templateFilePath = './template_file.move';  // 请将此路径替换为实际文件路径
    let templateCode = fs.readFileSync(templateFilePath, 'utf8');

    // 替换占位符
    templateCode = templateCode.replace('$fun_name', funName);
    templateCode = templateCode.replace('$addresses', `vector[${addresses.map(addr => `x"${addr}"`).join(', ')}]`);
    templateCode = templateCode.replace('$codes', `vector[${codes.map(code => `x"${code}"`).join(', ')}]`);
    templateCode = templateCode.replace('$balances', `vector[${balances.join(', ')}]`);
    templateCode = templateCode.replace('$nonces', `vector[${nonces.join(', ')}]`);
    templateCode = templateCode.replace('$from', `x"${from}"`);
    templateCode = templateCode.replace('$to', `x"${to}"`);
    templateCode = templateCode.replace('$data', `x"${data}"`);
    templateCode = templateCode.replace('$nonce', nonce);
    templateCode = templateCode.replace('$value', value);

    // 保存到新文件
    const newFilePath = fun_name + '.move';  // 请将此路径替换为保存文件的路径
    fs.writeFileSync(newFilePath, templateCode);

    console.log('代码生成完成并保存到新文件');
}

function read(json_path) {
    let content = JSON.parse(fs.readFileSync(json_path).toString());
    console.log(content);
}

read("add.json")