import { NODE_URL, RECAPTCHA_SECRET } from './const.js';
import { keccak256 } from 'ethers';
import fetch from 'node-fetch';
export function request(method, ...params) {
    const rpcData = {
        jsonrpc: '2.0',
        method: method,
        params: [...params],
        id: 1,
    };
    const body = JSON.stringify(rpcData);
    return fetch(NODE_URL, {
        method: 'POST',
        body,
        headers: { 'Content-Type': 'application/json' },
    }).then(response => response.json());
}

export function getRequest(query) {
    return fetch(NODE_URL + query, {
        method: 'get',
    }).then(response => response.json());
}
const FAUCET_TOKEN_SET = new Set();
export async function googleRecaptcha(token) {
    if (!RECAPTCHA_SECRET) return true;
    if (!token) return false;
    const t = keccak256(Buffer.from(token, 'utf8'));
    if (FAUCET_TOKEN_SET.has(t)) {
        throw 'recaptcha token has been used';
    }
    FAUCET_TOKEN_SET.add(t);
    setTimeout(() => {
        FAUCET_TOKEN_SET.delete(t);
    }, 10 * 1000);
    const keys = process.env.RECAPTCHA_SECRET.split(',');
    for (const key of keys) {
        const pass = await fetch('https://www.google.com/recaptcha/api/siteverify', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: `secret=${key}&response=${token}`,
        })
            .then(response => response.json())
            .then(res => res.success)
            .catch(() => false);
        if (pass) return true;
    }
    return false;
}
