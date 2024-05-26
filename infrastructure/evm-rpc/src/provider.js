import { NODE_URL } from './const.js';
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

export async function googleRecaptcha(token) {
    if (!process.env.RECAPTCHA_SECRET) return true;
    if (!token) return false;
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
