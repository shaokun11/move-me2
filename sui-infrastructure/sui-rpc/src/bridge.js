import { AptosClient, AptosAccount } from 'aptos-sui';
import { NODE_URL, SENDER_KEY } from './const.js';
import { AbiParse } from './abi_parse.js';
import { bcs } from '@mysten/bcs';
import { execa } from 'execa';
const client = new AptosClient(NODE_URL);
import 'dotenv/config';

const SENDER_ACCOUNT = AptosAccount.fromAptosAccountObject({
    privateKeyHex: SENDER_KEY,
});
const SENDER_ADDRESS = SENDER_ACCOUNT.address().hexString;

export const Bridge = {
    async faucet() {
        await execa('aptos account fund-with-faucet --account', [address]).catch(e => {});
        return 'success';
    },
    async getBalance(acc) {
        return {
            coinType: '0x2::sui::SUI',
            coinObjectCount: 1,
            totalBalance: '1000000000',
            lockedBalance: {},
        };
    },
    sender: SENDER_ADDRESS,
    async sendTx(payload) {
        const txnRequest = await client.generateTransaction(SENDER_ADDRESS, payload);
        const signedTxn = await client.signTransaction(SENDER_ACCOUNT, txnRequest);
        const transactionRes = await client.submitTransaction(signedTxn);
        await client.waitForTransaction(transactionRes.hash);
        return transactionRes.hash;
    },

    async simulateTx(payload) {
        const txnRequest = await client.generateTransaction(SENDER_ADDRESS, payload);
        const res = await client.simulateTransaction(SENDER_ACCOUNT, txnRequest);
        return res[0];
    },
    async checkTxResult(tx) {
        return client.getTransactionByHash(tx);
    },

    async view(payload) {
        return client.view(payload);
    },

    async getModuleAbi(object_id, mod, function_name) {
        try {
            const res = await client.getAccountModule(object_id, mod);
            const abi = AbiParse.aptToSui(res.abi);
            let ret = abi.exposedFunctions[function_name];
            if (ret) return ret;
            return ret;
        } catch (e) {
            throw 'object_id not found';
        }
    },

    async getObject(object_id) {
        let sources = await client.getAccountResources(object_id);
        if (!sources) throw 'object not found';
        // now we think the object only have one resource
        return sources[1];
    },

    async toAptPayload(tx_data) {
        if (tx_data.V1.kind['ProgrammableTransaction']) {
            const tx = tx_data.V1.kind['ProgrammableTransaction'];
            // TODO support more commands in one tx
            const call = tx.commands[0].MoveCall;
            let { package: pkg, module: mod, function: fun, type_arguments, arguments: args } = call;
            const abi = await this.getModuleAbi(pkg, mod, fun);
            if (abi.parameters.length !== args.length) throw 'params not fit';
            args = args.map((arg, i) => {
                const input = tx.inputs[i];
                if (input.Pure) {
                    const fn = bcs[abi.parameters[0].toLowerCase()].call();
                    return fn.parse(new Uint8Array(input.Pure));
                } else {
                    return Object.values(input.Object)[i].id;
                }
            });

            return {
                payload: {
                    function: `${pkg}::${mod}::${fun}`,
                    type_arguments: type_arguments,
                    arguments: args,
                },
                abi,
            };
        }
        throw 'unsupported tx data format';
    },
};
