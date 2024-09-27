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
        const thisLogs = [];
        const events = JSON.parse(line);
        for (let item of events) {
            const info = {
                hash: item.hash,
                logs: [],
            };
            const logs = item.event.logs;
            for (let index = 0; index < logs.length; index++) {
                const log = logs[index];
                if (log.data.length > 66) {
                    info.logs.push({
                        data: log.data,
                        index: index,
                    });
                }
            }
            if (info.logs.length > 0) {
                thisLogs.push(info);
            }
        }
        // console.log('thisLogs', thisLogs);
        appendFile('logs.txt', JSON.stringify(thisLogs) + '\n');
    }
}

main('0correct-tx.txt');
