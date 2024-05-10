import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import JsonRpc from 'json-rpc-2.0';
import { rpc } from './rpc.js';
import { SERVER_PORT } from './const.js';
const { JSONRPCServer, createJSONRPCErrorResponse } = JsonRpc;
const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const server = new JSONRPCServer();
for (const [key, value] of Object.entries(rpc)) {
    server.addMethod(key, value);
}
// error handler
server.applyMiddleware(async function (next, request, serverParams) {
    try {
        return await next(request, serverParams);
    } catch (error) {
        const message = typeof error === 'string' ? error : error?.message || 'Internal error';
        const err = createJSONRPCErrorResponse(request.id, error?.code || -32000, message, {
            message,
        });
        return err;
    }
});

function faucet_limiter(req, res, next) {
    if (req.method.toLowerCase() === 'post' && req.body?.method === 'eth_faucet') {
        const faucet_ip2 = req.headers['x-real-ip'];
        if (!canRequest(faucet_ip2)) {
            console.log('request faucet limit ', faucet_ip2);
            res.status(400).json({
                error: 'rate limit, please try after 1 day',
            });
            return;
        }
    }
    next();
}

app.use('/', faucet_limiter, async function (req, res, next) {
    const context = { ip: req.headers['x-real-ip'] };
    console.log('>>> %s %s', context.ip, req.body.method);
    let str_req = `<<< ${JSON.stringify(req.body)}`;
    server.receive(req.body).then(jsonRPCResponse => {
        if (jsonRPCResponse.error) {
            // console.error(str_req, jsonRPCResponse);
        } else {
            // console.log(str_req, jsonRPCResponse);
        }
        if (Array.isArray(req.body) && req.body.length === 1) {
            res.json([jsonRPCResponse]);
        } else {
            res.json(jsonRPCResponse);
        }
    });
});

app.set('trust proxy', true);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
});
