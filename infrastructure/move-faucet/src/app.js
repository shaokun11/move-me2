import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { SERVER_PORT } from './const.js';
const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const get_ip = (req) => {
    return req.headers['cf-connecting-ip'] ||
        req.headers['x-real-ip'] ||
        req.header('x-forwarded-for') ||
        req.ip;
}

// app.post('/fund', async function (req, res) {
//     const address = req.body.address;
//     const result = await request('faucetWithCli', { ...option, is_bcs_format: true });
//     res.send(result.data);
// });

// app.post('/mint', async function (req, res) {
//     const address = req.query.auth_key;
//     const result = await request('faucetWithCli', { ...option, is_bcs_format: true });
//     res.send(result.data);
// });

app.set('trust proxy', true);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
});
