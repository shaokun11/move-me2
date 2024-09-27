import 'dotenv/config';
import express from 'express';
import http from 'node:http';
import { createReadStream } from 'fs';
import readline from 'readline';
const app = express();
const httpServer = http.createServer(app);
httpServer.setTimeout(100 * 1000);
app.use(express.json({ limit: '100mb' }));
const DB = new Map();
const logs_path = 'script/error-block/static/logs.txt';
async function loadLogs() {
    const fileStream = createReadStream(logs_path);
    const rl = readline.createInterface({
        input: fileStream,
        crlfDelay: Infinity,
    });
    for await (const line of rl) {
        if (!line) {
            continue;
        }
        const item = JSON.parse(line);
        DB.set(item.hash, item.logs);
    }
}
await loadLogs();
// // curl http://localhost:8897?hash=hash
app.get('/', (req, res) => {
    // console.log(req.query);
    const hash = req.query.hash;
    const logs = DB.get(hash);
    res.json(logs || []);
});
app.listen(8897, () => {
    console.log(`logs server listening at http://localhost:8897`);
});
