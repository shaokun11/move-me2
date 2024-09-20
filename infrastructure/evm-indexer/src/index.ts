import { Config } from "./config";
import { Worker } from "./worker";
const configPath = ".config.yaml";
import { EvmErrorHash, EvmHash, EvmLogs } from "./models/evm";
import { EvmProcessor } from "./evm-processor";

async function main() {
  const config = Config.from_yaml_file(configPath);
  const processor = new EvmProcessor();
  const worker = new Worker({
    config,
    processor,
    models: [EvmLogs, EvmHash,EvmErrorHash],
  });
  await worker.run();
}
main();
