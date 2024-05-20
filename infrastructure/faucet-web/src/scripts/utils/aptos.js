import { AptosClient } from 'aptos'
const address =
  '0x7e95b0c90bf89fab82a8f98fbf8062f7bed3ca721aaa2d91dbb712a5b7e8ea6a'
export async function setAptos(str, callback) {
  const payload = {
    type: 'entry_function_payload',
    type_arguments: [],
    function: `${address}::message::set_message`,
    arguments: [str],
  }
  const otherOptions = {
    max_gas_amount: '1000',
  }
  if (!window['pontem']) {
    callback(-1, 'check aptos wallet!')
    return
  }
  window['pontem']
    .signAndSubmit(payload, otherOptions)
    .then(tx => {
      callback(1, tx.result.hash)
    })
    .catch(error => callback(-1, error.message))
}
export async function getAptos(str) {
  const client = new AptosClient('https://seed-node1.movementlabs.xyz/v1/')
  const payload = {
    function: `${address}::message::get_message`,
    type_arguments: [],
    arguments: [str.slice(2)],
  }
  let res = await client.view(payload)
  return res
}

export async function createAccount(puk_key) {
    console.log('puk_key=',puk_key)
  const p = (puk_key + '').slice(2)
  const url = 'https://seed-node1.movementlabs.xyz/v1/mint?puk_key=' + puk_key
  const res = await post(url)
  return res
}
export async function getBalance(address) {
  const url =
    'https://seed-node1.movementlabs.xyz/v1/accounts/' +
    address +
    '/resource/0x1::coin::CoinStore%3C0x1::aptos_coin::AptosCoin%3E'
  const res = await get(url)
  if (res.error_code) return 0
  return Number(res.data.coin.value) / 1e8
}

export async function post(url, query) {
  return fetch(url, {
    method: 'POST',
    redirect: 'follow',
    headers: {
      'Content-type': 'application/json',
    },
    // body: JSON.stringify(query),
  }).then(response => response.json())
}

export async function get(url) {
  return fetch(url, {
    method: 'GET',
    headers: {
      'Content-type': 'application/json',
    },
  }).then(response => response.json())
}
export async function connect() {
  let _pontem = window.petra
  if (!_pontem) {
    return ''
  }
  let { address, publicKey } = await _pontem.connect()
  // let isConnect = await _pontem.isConnected();
  // if (!isConnect) {
  //     await _pontem.connect();
  // }
  // return _pontem.account();
  return { address, publicKey }
}
