import { random } from 'radash';

export function postJsonRpc(url, method, params = [], headers = {}) {
    return fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            ...headers,
        },
        body: JSON.stringify({
            id: random(1, 100000),
            jsonrpc: '2.0',
            method,
            params,
        }),
    }).then(response => response.json());
}
