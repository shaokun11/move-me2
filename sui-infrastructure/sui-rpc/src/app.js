import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { SERVER_PORT } from './const.js';
import { initRouter } from './router.js';
const app = express();
app.use(
    cors({
        origin: function (origin, callback) {
            callback(null, origin || '*');
        },
        credentials: true,
    }),
);
app.use(express.json({ limit: '10mb' }));
initRouter(app);
app.set('trust proxy', 1);
app.listen(SERVER_PORT, () => {
    console.log('server start at http://127.0.0.1:' + SERVER_PORT);
});
