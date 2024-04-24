import { BigNumber } from "bignumber.js";
import { AptosClient } from "aptos";
import { trace } from "./tools";
import {hexToUint8Array} from './sdk'

BigNumber.config({ ROUNDING_MODE: 1 });
BigNumber.config({ EXPONENTIAL_AT: 1e+9 });

export function convertNormalToBigNumber(number, decimals = 18, fix = 0) {
    return new BigNumber(number).multipliedBy(new BigNumber(Math.pow(10, decimals))).minus(fix).toFixed(0);
}
export function convertBigNumberToNormal(_number, decimals = 18, fix = 10) {
    let number = _number;
    if (typeof _number !== "string")
        number = _number.toString();
    let result = new BigNumber(number).dividedBy(new BigNumber(Math.pow(10, decimals)));
    return result.toFixed(fix);
}

const isPetraInstalled = window.aptos;
const getAptosWallet = () => {
    if ('aptos' in window) {
        return window.aptos;
    } else {
        window.open('https://petra.app/', `_blank`);
    }
};
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
export async function getMov(puk_key) {
    const env = process.env;
    const p = (puk_key + '').slice(2)
    const url = env.VUE_APP_MOVE_RPC+'/mint?address=' + puk_key;
    const res = await post(url)
    return res
}


const wallet = getAptosWallet();
export async function petraConnect(callback) {
    let res = { address: "", network: "",publicKey:''};
    try {
        await wallet.connect();
        const account = await wallet.account();
        console.log('account=',account);
        res.address = account.address;
        res.publicKey = account.publicKey;
        res.network = await wallet.network();
        wallet.onAccountChange(async newAccount => {
            // console.log('newAccount=',newAccount,account.address,account.publicKey);
            await wallet.connect()
            let network = await wallet.network()
            if (newAccount) {
                if(callback) callback({ address: newAccount.address, network, publicKey: newAccount.publicKey})
            }
        })
        wallet.onNetworkChange(async network => {
            // console.log('network=',network)
            let account = await wallet.account()
            if (account) {
                if(callback) callback({ address: account.address, network, publicKey: account.publicKey })
            }
        })
    } catch (error) {
        res = { code: 4001, message: error }
    }
    return res;
}

export async function petraDisconnect() {
    await wallet.disconnect();
}

const contractAddress = "0x1";
export async function petraSend(amount, address, callback) {
    let aa = hexToUint8Array((address.slice(2)))
    
    let payload = {
        function: contractAddress + `::evm::deposit`,
        type_arguments: [],
        arguments: [aa,hexToUint8Array(addr_even((amount*1e18).toString(16)))],
    };
    // trace('aa=',aa,payload);
    const otherOptions = {
        max_gas_amount: '1000',
    }
    //@ts-ignore
    if (!isPetraInstalled) {
        callback(-1, "check aptos wallet!")
        return;
    }
    //@ts-ignore
    window['aptos'].signAndSubmitTransaction(payload, otherOptions)
        .then((tx) => {
            callback(1, tx.hash)
        })
        .catch((error) => callback(-1, error.message));
}

function formatEthAddress(addr) {
    addr = addr.toLowerCase();
    return addr.slice(2).padStart(64, "0");
}

function addr_even(addr) {
    if (addr.length % 2 == 1) {
        addr = "0" + addr;
    }
return addr;    
}



export async function getHashDetail(hash) {
    const client = new AptosClient('https://devnet.m1.movementlabs.xyz');
    const txn = await client.waitForTransactionWithResult(hash);
    return txn;
}

export async function petraGetbalance(symbol, user) {
    const client = new AptosClient('https://devnet.m1.movementlabs.xyz');
    var resources;
    try{
        resources = await client.getAccountResources(user);
    }
    catch(e){
        trace(e)
        return 0;
    }
    if (symbol === "APT")
        symbol = "AptosCoin";
    const isExist = resources.some(element => element.type.includes(symbol));
    if (!isExist) {
        return 0;
    }
    let type_arguments = ["0x1::aptos_coin::AptosCoin"];
    switch (symbol) {
        case "USDC":
            type_arguments = [`${contractAddress}::usdc::USDC`];
            break;
        default: break;
    }
    const payload = {
        function: "0x1::coin::balance",
        type_arguments: type_arguments,
        arguments: [user],
    };
    let amount = await client.view(payload);
    return convertBigNumberToNormal(amount, 8);
}