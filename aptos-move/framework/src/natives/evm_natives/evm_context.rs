use crate::natives::evm_natives::{
    state::State,
    types::{Environment, RunArgs, TransactArgs},
    constants::TxType,
    executor::new_tx,
};

use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value, Struct}
};
use move_vm_runtime::native_functions::NativeFunction;
use smallvec::{smallvec, SmallVec};
use move_core_types::u256::U256 as move_u256;
use primitive_types::{H160, U256};
use better_any::{Tid, TidAble};
use std::collections::VecDeque;


/// Cached emitted module events.
#[derive(Default, Tid)]
pub struct NativeEvmContext {
    state: State
}

impl NativeEvmContext {
    pub fn new() -> Self {
        Self {
            state: State::new()
        }
    }
}

fn parse_env(env_data: Struct) -> Environment {
    let mut fields: Vec<Value> = env_data.unpack().unwrap().collect();
    let _block_excess_blob_gas: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_base_fee_per_gas: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_gas_limit: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_random = fields.pop().unwrap().value_as::<Vec<u8>>().unwrap();
    let block_difficulty: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_timestamp: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_coinbase = H160::from_slice(&fields.pop().unwrap().value_as::<Vec<u8>>().unwrap());
    let block_number: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let chain_id: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    Environment {
        block_number,
        block_coinbase,
        block_timestamp,
        block_difficulty,
        block_random,
        block_gas_limit,
        block_base_fee_per_gas,
        chain_id
    }
}

fn native_execute_tx(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let tx_type = safely_pop_arg!(args, u8);
    let access_list_address_len = safely_pop_arg!(args, u64);
    let access_list_slot_len = safely_pop_arg!(args, u64);
    let max_priority_fee_per_gas: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let max_fee_per_gas: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let gas_price: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let gas_limit: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let data = safely_pop_arg!(args, Vec<u8>);
    let value: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let to = safely_pop_arg!(args, Vec<u8>);
    let from = safely_pop_arg!(args, Vec<u8>);
    let env_data = safely_pop_arg!(args, Struct);

    let env = parse_env(env_data);
    let code;
    let calldata;
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();

    let (is_create, address) = if args.len() == 0 {
        code = data;
        calldata = vec![];
        (true, H160::zero())
    } else {
        let addr = H160::from_slice(&to);
        code = ctx.state.get_code(addr);
        calldata = data;
        (false, addr)
    };
    let caller = H160::from_slice(&from);

    let run_args = RunArgs {
        origin: caller,
        caller,
        address,
        gas_price,
        value,
        data: calldata,
        code,
        is_create,
        transfer_eth: true,
        depth: 0
    };
    let tx_args = TransactArgs {
        gas_limit,
        gas_price,
        max_priority_fee_per_gas,
        max_fee_per_gas,
        tx_type,
    };

    
    new_tx(&mut ctx.state, run_args, &tx_args, &env, TxType::from(tx_type), access_list_address_len, access_list_slot_len);

    Ok(smallvec![])
}



// fn native_get_balance_change_set(
//     context: &mut SafeNativeContext,
//     _ty_args: Vec<Type>,
//     _args: VecDeque<Value>,
// ) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
//     let ctx = context.extensions().get::<NativeEvmContext>();

//     let len = ctx.substate.balances.len();
//     let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
//     let mut value_list: Vec<move_u256> = Vec::new();

//     for (address, value) in ctx.substate.balances.iter() {
//         let mut padded_address = vec![0u8; 12]; // 12 个前置零
//         padded_address.extend_from_slice(address.as_bytes());

//         address_list.extend_from_slice(&padded_address);

//         value_list.push(evm_u256_to_move_u256(value));
//     }

//     Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u256(value_list)])
// }

// fn native_get_nonce_change_set(
//     context: &mut SafeNativeContext,
//     _ty_args: Vec<Type>,
//     _args: VecDeque<Value>,
// ) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
//     let ctx = context.extensions().get::<NativeEvmContext>();

//     let len = ctx.substate.nonces.len();
//     let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
//     let mut value_list: Vec<move_u256> = Vec::new();

//     for (address, value) in ctx.substate.nonces.iter() {
//         let mut padded_address = vec![0u8; 12]; 
//         padded_address.extend_from_slice(address.as_bytes());

//         address_list.extend_from_slice(&padded_address);

//         value_list.push(evm_u256_to_move_u256(value));
//     }

//     Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u256(value_list)])
// }

// fn native_get_code_change_set(
//     context: &mut SafeNativeContext,
//     _ty_args: Vec<Type>,
//     _args: VecDeque<Value>,
// ) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
//     let ctx = context.extensions().get::<NativeEvmContext>();

//     let len = ctx.substate.codes.len();
//     let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
//     let mut code_list: Vec<u8> = Vec::new();
//     let mut code_lengths: Vec<u64> = Vec::new();

//     for (address, code) in ctx.substate.codes.iter() {
//         let mut padded_address = vec![0u8; 12]; 
//         padded_address.extend_from_slice(address.as_bytes());

//         address_list.extend_from_slice(&padded_address);

//         code_lengths.push(code.len() as u64);
//         code_list.extend_from_slice(code);
//     }

//     Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u64(code_lengths), Value::vector_u8(code_list)])
// }

// fn native_get_address_change_set(
//     context: &mut SafeNativeContext,
//     _ty_args: Vec<Type>,
//     _args: VecDeque<Value>,
// ) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
//     let ctx = context.extensions().get::<NativeEvmContext>();

//     let len = ctx.substate.storages.len();
//     let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);

//     for address in ctx.substate.storages.keys() {
//         let mut padded_address = vec![0u8; 12]; 
//         padded_address.extend_from_slice(address.as_bytes());

//         address_list.extend_from_slice(&padded_address);
//     }

//     Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list)])
// }

// fn native_get_storage_change_set(
//     context: &mut SafeNativeContext,
//     _ty_args: Vec<Type>,
//     mut args: VecDeque<Value>,
// ) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
//     let target_address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
//     let ctx = context.extensions().get::<NativeEvmContext>();

//     let mut keys: Vec<move_u256> = Vec::new();
//     let mut values: Vec<move_u256> = Vec::new();

//     if let Some(storage_map) = ctx.substate.storages.get(&target_address) {
//         for (key, value) in storage_map.iter() {
//             keys.push(evm_u256_to_move_u256(key));
//             values.push(evm_u256_to_move_u256(value));
//         }
//     }

//     Ok(smallvec![Value::vector_u256(keys), Value::vector_u256(values)])
// }

/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("execute_tx", native_execute_tx as RawSafeNative),
        // ("set_code", native_set_code as RawSafeNative),
        // ("set_account", native_set_account as RawSafeNative),
        // ("set_storage", native_set_storage as RawSafeNative),
        // ("sub_balance", native_sub_balance as RawSafeNative),
        // ("set_nonce", native_set_nonce as RawSafeNative),
        // ("add_always_hot_address", native_add_always_hot_address as RawSafeNative),
        // ("add_always_hot_slot", native_add_always_hot_slot as RawSafeNative),
        // ("calculate_root", native_calculate_root as RawSafeNative),
        // ("get_balance_change_set", native_get_balance_change_set as RawSafeNative),
        // ("get_nonce_change_set", native_get_nonce_change_set as RawSafeNative),
        // ("get_code_change_set", native_get_code_change_set as RawSafeNative),
        // ("get_address_change_set", native_get_address_change_set as RawSafeNative),
        // ("get_storage_change_set", native_get_storage_change_set as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}