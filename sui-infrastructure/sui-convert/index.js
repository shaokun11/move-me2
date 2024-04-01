import fs from "node:fs/promises";
import path from "node:path";
import toml from "@iarna/toml"

const sui_contract_path = "counter"
const config_bytes = await fs.readFile(path.join(sui_contract_path, "Move.toml"))
const config = toml.parse(config_bytes);

// update dependencies
if (config?.dependencies?.Sui) {
    config.dependencies = {
        AptosFramework: { local: '../../../aptos-move/framework/aptos-framework' },
    };
    // delete this dependency, we'll not use it anymore
    delete config?.dependencies?.Sui
}

const dst_dir = `${sui_contract_path}-apt`
await fs.mkdir(`${dst_dir}/sources`, { recursive: true })
await fs.writeFile(`${dst_dir}/Move.toml`, toml.stringify(config))

// parse source code
const src_sources = path.join(sui_contract_path, "sources")
const sources = await load_files(src_sources)

for (const source of sources) {
    convert(source)
}
// convert sui source code to aptos sui
async function convert(p) {
    let content = await fs.readFile(p, 'utf-8')
    // replace sui to aptos_framework
    content = content.replace(/sui::transfer/g, "aptos_framework::sui_transfer")
    content = content.replace(/sui::object/g, "aptos_framework::sui_object")
    content = content.replace(/sui::tx_context/g, "aptos_framework::tx_context")
    content = content.replace(/transfer::share_object/g, "sui_transfer::share_object")
    content = content.replace(/object::new/g, "sui_object::new")
    // now we are not supporting test code
    content = content.replace(/#[\s]*\[test_only\][\s\S]*/g, '');
    // replace content output directory
    await fs.writeFile(p.replace(sui_contract_path, dst_dir), content)
}


async function load_files(dir) {
    const ret = []
    const run = async (directory) => {
        const files = await fs.readdir(directory);
        for (const file of files) {
            const filePath = path.join(directory, file);
            const stat = await fs.stat(filePath);
            if (await stat.isFile()) {
                ret.push(filePath);
            } else if (await stat.isDirectory()) {
                await run(filePath);
            }
        }
    }
    await run(dir)
    return ret
}



