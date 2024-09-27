import readline from 'readline';
import { createReadStream } from 'fs';
import { appendFile } from 'fs/promises';

async function main(path) {
    const fileStream = createReadStream(path);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
    });
    for await (const line of rl) {
        const events = JSON.parse(line);
        for (let item of events) {
            const info = {
                hash: item.hash,
                logs: [],
            };
            const logs = item.event.logs;
            for (let index = 0; index < logs.length; index++) {
                const log = logs[index];
                // the only one  32bytes log is correct, so we can skip it
                if (log.data.length === 66) {
                    continue;
                }
                info.logs.push({
                    data: log.data,
                    index: index,
                });
            }
            if (info.logs.length > 0) {
                appendFile('logs.txt', JSON.stringify(info) + '\n');
            }
        }
    }
}

main('0correct-tx.txt');
