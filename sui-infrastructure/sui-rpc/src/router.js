import JsonRpc from 'json-rpc-2.0';
const { JSONRPCServer, createJSONRPCErrorResponse } = JsonRpc;
import { rpc } from './rpc.js';

const server = new JSONRPCServer();
for (const [key, value] of Object.entries(rpc)) {
    server.addMethod(key, value);
}

// error handler
server.applyMiddleware(async function (next, request, serverParams) {
    try {
        return await next(request, serverParams);
    } catch (error) {
        console.log('error', error);
        const message = typeof error === 'string' ? error : error?.message || 'Internal Error';
        const err = createJSONRPCErrorResponse(request.id, error?.code || -32000, message, {
            message,
        });
        return err;
    }
});

export const initRouter = function (app) {
    app.use('/', async function (req, res, next) {
        const context = { ip: req.ip };
        console.log('>>> %s %s', context.ip, req.body.method);
        const str_req = `<<< ${JSON.stringify(req.body)} \n`;
        server.receive(req.body, context).then(jsonRPCResponse => {
            if (jsonRPCResponse.error) {
                console.error(str_req, jsonRPCResponse);
            } else {
                console.log(str_req, jsonRPCResponse);
            }
            if (Array.isArray(req.body) && req.body.length === 1) {
                res.json([jsonRPCResponse]);
            } else {
                res.json(jsonRPCResponse);
            }
        });
    });
};
