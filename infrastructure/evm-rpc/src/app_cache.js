import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import http from 'node:http';
import LevelDBWrapper from './leveldb_wrapper.js';

let DB_TX = new LevelDBWrapper('db/tx');
const app = express();
const httpServer = http.createServer(app);
httpServer.setTimeout(100 * 1000);
app.use(cors());
app.use(express.json({ limit: '100mb' }));

// curl http://localhost:8898?key=key1
app.get('/', (req, res) => {
    console.log(req.query);
    DB_TX.get(req.query.key).then(value => {
        res.send(value || '');
    });
});

// curl -X POST -H "Content-Type: application/json" -d '{"key":"key1","value":"value1"}' http://localhost:8898
app.post('/', (req, res) => {
    console.log(req.body);
    DB_TX.put(req.body.key, req.body.value).then(() => {
        res.send('ok');
    });
});

app.listen(8898, () => {
    console.log(`Cache server listening at http://localhost:8898`);
});
