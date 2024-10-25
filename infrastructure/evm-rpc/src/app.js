import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import JsonRpc from 'json-rpc-2.0';
import { rpc } from './rpc.js';
import { SERVER_PORT } from './const.js';
import { startBotTask } from './task_bot.js';
import { startFaucetTask } from './task_faucet.js';
import http from 'node:http';
import { inspect } from 'util';
import { initTxPoolTask } from './bridge.js';
import logger from './logger.js';
const { JSONRPCServer, createJSONRPCErrorResponse, JSONRPCErrorException } = JsonRpc;

const app = express();
const httpServer = http.createServer(app);
httpServer.setTimeout(100 * 1000);
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
        logger.error('rpc error:%s', error);
        if (error instanceof JSONRPCErrorException) {
            return createJSONRPCErrorResponse(request.id, error?.code || -32000, error.message, error.data);
        }
        let message = typeof error === 'string' ? error : error?.message || 'Internal error';
        let data = serverParams.params;
        const err = createJSONRPCErrorResponse(request.id, error?.code || -32000, message, data);
        return err;
    }
});

app.use('/', async function (req, res) {
    const context = {
        ip:
            req.headers['cf-connecting-ip'] ||
            req.headers['x-real-ip'] ||
            req.header('x-forwarded-for') ||
            req.ip,
        token: req.headers['token'] || null, // for faucet google recaptcha token
    };
    let startTs = Date.now();
    let str_req = `<<< ${JSON.stringify(req.body)}`;
    server.receive(req.body, context).then(jsonRPCResponse => {
        logger.debug(
            'ts:%s,req:%s,res:%s',
            Date.now() - startTs,
            str_req,
            inspect(jsonRPCResponse, { depth: null }),
        );
        if (Array.isArray(req.body) && req.body.length === 1) {
            res.json([jsonRPCResponse]);
        } else {
            res.json(jsonRPCResponse);
        }
    });
});

app.set('trust proxy', true);
initTxPoolTask().then(() => {
    app.listen(SERVER_PORT, () => {
        logger.info('server start at http://127.0.0.1:' + SERVER_PORT);
        startBotTask();
        startFaucetTask();
    });
});
