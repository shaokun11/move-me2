import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { NODE_URL, SERVER_PORT, FAUCET_AMOUNT } from './const.js';
const app = express();
import axios from 'axios';
import { canRequest, setRequest } from './rate.js';
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const get_ip = (req) => {
    return req.headers['cf-connecting-ip'] ||
        req.headers['x-real-ip'] ||
        req.header('x-forwarded-for') ||
        req.ip;
}

// for petra wallet faucet
app.post('/fund', async function (req, res) {
    const ip = get_ip(req);
    const [pass, time] = await canRequest(ip)
    if (!pass) {
        res.status(200)
        res.json({
            error_message: `Too Many Requests, please try after ${time} seconds`,
        });
        return
    }
    const opt = {
        url: NODE_URL + req.path,
        headers: {
            'content-type': req.headers['content-type'],
            'accept': req.headers['accept'],
        },
        method: req.method,
        data: req.body
    };
    opt.data.amount = parseInt(FAUCET_AMOUNT) * 1e8;
    const response = await axios(opt);
    if (response.status === 200) {
        await setRequest(ip);
    }
    res.status(response.status);
    res.json(response.data);
});

// for aptos cli faucet
app.post('/mint', async function (req, res) {
    const response = await axios({
        method: req.method,
        url: NODE_URL + req.path,
        params: {
            ...req.query,
            // reset the faucet amount
            amount: "" + parseInt(FAUCET_AMOUNT) * 1e8,
        },
    });
    res.status(response.status);
    res.send(response.data);
});

app.set('trust proxy', true);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
});
