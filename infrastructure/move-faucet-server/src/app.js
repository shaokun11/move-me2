import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { createHash } from "node:crypto"
import { SERVER_PORT, FAUCET_AMOUNT, FAUCET_NODE_URL, ENV_IS_PRO } from './const.js';
const app = express();
import axios from 'axios';
import { canRequest, setRequest } from './rate.js';
import { addToFaucetTask, startFaucetTask } from './task_faucet.js';
import { googleRecaptcha } from './provider.js';
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
    if(ENV_IS_PRO) {
        throw "Please use web page to request faucet"
    }
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
        url: FAUCET_NODE_URL + req.path,
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
    if(ENV_IS_PRO) {
        throw "Please use web page to request faucet"
    }
    const response = await axios({
        method: req.method,
        url: FAUCET_NODE_URL + req.path,
        params: {
            ...req.query,
            // reset the faucet amount
            amount: "" + parseInt(FAUCET_AMOUNT) * 1e8,
        },
    });
    res.status(response.status);
    res.send(response.data);
});



const GOOGLE_TOKEN_SET = new Set();
app.get('/batch_mint', async function (req, res) {
    res.status(200);
    const ip = req.headers['cf-connecting-ip'] || req.headers['x-real-ip'] || req.ip;
    const address = req.query.address;
    if (address.length !== 66) {
        res.json({
            error_message: `invalid address`,
        });
        return;
    }
    const token = req.headers['token'];
    if ((await googleRecaptcha(token)) === false) {
        res.json({
            error_message: `invalid recaptcha`,
        });
        return;
    }
    const t1 = createHash("sha256").update(token).digest("hex")
    if (GOOGLE_TOKEN_SET.has(t1)) {
        res.json({
            error_message: `repeat recaptcha`,
        });
        return;
    }
    GOOGLE_TOKEN_SET.add(t1);
    let ret = await addToFaucetTask({ addr: address, ip });
    if (ret.error) {
        GOOGLE_TOKEN_SET.delete(t1);
        res.json({
            error_message: ret.error,
        });
        return;
    }
    res.json([ret.data]);
});

app.set('trust proxy', 1);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
    startFaucetTask()
});
