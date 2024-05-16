import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { NODE_URL, SERVER_PORT } from './const.js';
const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const get_ip = (req) => {
    return req.headers['cf-connecting-ip'] ||
        req.headers['x-real-ip'] ||
        req.header('x-forwarded-for') ||
        req.ip;
}

const make_req_option = (req) => {
    const opt = {
        method: req.method,
        url: NODE_URL + req.path,
        params: req.query,
        headers: req.headers
    };
    if (req.method.toLowerCase() === 'post' || req.method.toLowerCase() === 'put') {
        opt.data = req.body;
    }
    delete opt.headers.host;
    console.log("req opt", opt)
    return opt
}

// for petra wallet faucet
app.post('/fund', async function (req, res) {
    opt.data.amount = parseInt(FAUCET_AMOUNT) * 1e8;
    await axios(make_req_option(req));
    res.send(response.data);
    res.status(response.status);
    res.setHeader('Content-Type', req.headers['Accept'])
});
// for aptos cli faucet
app.post('/mint', async function (req, res) {
    await axios(make_req_option(req));
    res.send(response.data);
    res.status(response.status);
    res.setHeader('Content-Type', req.headers['Accept'])
});

app.set('trust proxy', true);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
});
