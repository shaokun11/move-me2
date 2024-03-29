import { upperFirst } from 'lodash-es';
const BASE_TYPE = ['address', 'u8', 'u16', 'u32', 'u64', 'u128', 'u256', 'bool', 'string'];

export class AbiParse {
    static aptToSui(apt_abi) {
        const sui_abi = {
            fileFormatVersion: 6,
            address: '0x1',
            name: 'counter',
            friends: [],
            structs: {},
            exposedFunctions: {},
        };
        sui_abi.address = apt_abi.address;
        sui_abi.name = apt_abi.name;
        for (const fun of apt_abi.exposed_functions) {
            const sui_fun = {
                visibility: fun.visibility,
                isEntry: fun.is_entry,
                typeParameters: fun.generic_type_params,
                parameters: [],
                return: fun.return,
            };
            sui_fun.parameters = parse_fun_params(fun.params);
            sui_abi.exposedFunctions[fun.name] = sui_fun;
        }

        for (const struct of apt_abi.structs) {
            const sui_struct = {
                abilities: { abilities: struct.abilities },
                typeParameters: [],
                fields: [],
            };
            sui_struct.fields = parse_struct(struct.fields);
            sui_abi.structs[struct.name] = sui_struct;
        }
        return sui_abi;
    }
    static parseSuiTxInput(sui_tx_data, apt_payload, sui_abi) {
        let messageVersion;
        if (sui_tx_data.V1) {
            messageVersion = 'v1';
        } else {
            throw 'messageVersion not supported';
        }
        let transactionKind;
        if (sui_tx_data.V1.kind['ProgrammableTransaction']) {
            transactionKind = 'ProgrammableTransaction';
        } else {
            throw 'transactionKind not supported';
        }
        const transaction = sui_tx_data.V1.kind['ProgrammableTransaction'];

        const inputs = transaction.inputs.map((arg, i) => {
            if (arg.Pure) {
                return {
                    type: 'pure',
                    valueType: sui_abi.parameters[i].toLowerCase(),
                    value: apt_payload.arguments[i],
                };
            } else {
                return {
                    type: 'object',
                    objectType: arg.Object.SharedObject ? 'sharedObject' : 'sharedObject',
                    objectId: arg.Object.SharedObject.id,
                    initialSharedVersion: arg.Object.SharedObject.initial_shared_version,
                    mutable: arg.Object.SharedObject.mutable,
                };
            }
        });
        return {
            messageVersion,
            transaction: {
                kind: transactionKind,
                inputs: inputs,
                transactions: transaction,
            },
            sender: sui_tx_data.V1.sender,
            gasData: sui_tx_data.V1.gas_data,
        };
    }
}

function parse_struct(fields) {
    const ret = [];
    for (const field of fields) {
        const outputField = {
            name: field.name,
            type: parseType(field.type),
        };
        ret.push(outputField);
    }
    return ret;
}

function parse_fun_params(fields) {
    const ret = [];
    for (const field of fields) {
        if (field === 'signer' || field === '&signer' || field.includes('0x1::tx_context::TxContext')) {
            continue;
        }
        const outputField = parseType(field);
        ret.push(outputField);
    }
    return ret;
}

function parseType(type) {
    if (BASE_TYPE.includes(type)) {
        return upperFirst(type);
    } else {
        const [address, module, name] = type.split('::');
        if (address.startsWith('&mut')) {
            return {
                MutableReference: {
                    Struct: { address: address.split(' ')[1], module: module, name: name, typeArguments: [] },
                },
            };
        } else if (address.startsWith('&')) {
            return {
                Reference: {
                    Struct: { address: address.slice(1), module: module, name: name, typeArguments: [] },
                },
            };
        } else {
            return {
                Struct: { address: address, module: module, name: name, typeArguments: [] },
            };
        }
    }
}
