use crate::{log_debug, natives::evm_natives::{
    constants::TxType,
    executor::new_tx, 
    state::State,
    types::{Environment, RunArgs, TransactArgs},
    utils::bytes_to_h160
}};

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
use std::collections::VecDeque;
use ethers::utils::get_contract_address;
use std::time::Instant;

use better_any::{Tid, TidAble};

#[derive(Default, Tid)]
pub struct NativeEvmContext {
    pub state: State,
}

impl NativeEvmContext {
    pub fn new() -> Self {
        Self {
            state: State::new(),
        }
    }
}


fn native_set_code(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let code = safely_pop_arg!(args, Vec<u8>);
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.set_code(address, code);

    Ok(smallvec![])
}

fn native_set_account(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let nonce = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let code = safely_pop_arg!(args, Vec<u8>);
    let balance = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.set_code(address, code);
    ctx.state.set_balance(address, balance);
    ctx.state.set_nonce(address, nonce);

    Ok(smallvec![])
}

fn native_set_storage(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let value = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let index = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.set_storage(address, index, value);

    Ok(smallvec![])
}

fn native_set_nonce (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let nonce = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.set_nonce(address, nonce);

    Ok(smallvec![])
}

fn native_add_always_warm_address (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.add_always_warm_slot(address, None);

    Ok(smallvec![])
}

fn native_add_always_warm_slot (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let index = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state.add_always_warm_slot(address, Some(index));

    Ok(smallvec![])
}

fn native_calculate_root(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let ctx = context.extensions().get::<NativeEvmContext>();
    let state_root =  ctx.state.calculate_test_state_root();
    Ok(smallvec![Value::vector_u8(state_root)])
}

fn parse_env(env_data: Struct) -> Environment {
    let mut fields: Vec<Value> = env_data.unpack().unwrap().collect();
    let chain_id: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let _block_excess_blob_gas: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_base_fee_per_gas: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_gas_limit: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_random = fields.pop().unwrap().value_as::<Vec<u8>>().unwrap();
    let block_difficulty: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_timestamp: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    let block_coinbase = H160::from_slice(&fields.pop().unwrap().value_as::<Vec<u8>>().unwrap());
    let block_number: U256 = fields.pop().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
    
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
    mut ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let chain_id = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let block_coinbase = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let block_number: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let block_timestamp: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let skip_block_gas_limit_validation = safely_pop_arg!(args, bool);
    let skip_balance = safely_pop_arg!(args, bool);
    let skip_nonce = safely_pop_arg!(args, bool);
    let tx_type = safely_pop_arg!(args, u64);
    let access_list_slot_len = safely_pop_arg!(args, u64);
    let access_list_address_len = safely_pop_arg!(args, u64);
    let max_priority_fee_per_gas: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let max_fee_per_gas: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let mut gas_price: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let gas_limit: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let data = safely_pop_arg!(args, Vec<u8>);
    let nonce: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let value: U256 = safely_pop_arg!(args, move_u256).to_ethers_u256();
    let to = safely_pop_arg!(args, Vec<u8>);
    let from = safely_pop_arg!(args, Vec<u8>);
    
    let type_ = ty_args.pop().unwrap();
    let env = Environment::env_for_mainnet(block_number, block_timestamp, block_coinbase, chain_id);
    let code: Vec<u8>;
    let mut ctx_state = State::new();
    ctx_state.set_storage_type(type_);

    if TxType::from(tx_type) == TxType::Eip1559 {
        gas_price = env.block_base_fee_per_gas + max_priority_fee_per_gas;
        gas_price = if gas_price > max_fee_per_gas {max_fee_per_gas} else {gas_price}
    };


    let caller = H160::from_slice(&from);
    let (is_create, address, calldata) = if to.len() == 0 {
        code = data;
        (true, get_contract_address(caller, ctx_state.get_nonce(caller, &mut Some(context))), vec![])
    } else {
        let addr = H160::from_slice(&to);
        code = ctx_state.get_code(addr, &mut Some(context));
            
        (false, addr, data)
    };

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
        nonce: nonce,
        gas_limit,
        gas_price,
        max_priority_fee_per_gas,
        max_fee_per_gas,
        tx_type,
        skip_balance,
        skip_nonce,
        skip_block_gas_limit_validation
    };

    let start_time = Instant::now();

    let (result, gas_usage, ret_value, created_address) = new_tx(&mut ctx_state, &mut Some(context), run_args, &tx_args, &env, TxType::from(tx_type), access_list_address_len, access_list_slot_len);
    log_debug!("result {:?}", result);
    let elapsed = start_time.elapsed();
    log_debug!("run time: {:?}", elapsed);

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.state = ctx_state;

    Ok(smallvec![Value::u64(result as u64), Value::u256(move_u256::from(gas_usage)), Value::vector_u8(ret_value), Value::vector_u8(created_address)])
}

fn native_execute_tx_for_test(
    context: &mut SafeNativeContext,
    mut _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let tx_type = safely_pop_arg!(args, u8) as u64;
    let access_list_slot_len = safely_pop_arg!(args, u64);
    let access_list_address_len = safely_pop_arg!(args, u64);
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
    let ctx_state = &mut context.extensions_mut().get_mut::<NativeEvmContext>().state;
    let code;

    let caller = H160::from_slice(&from);
    let (is_create, address, calldata) = if to.len() == 0 {
        code = data.clone();
        (true, get_contract_address(caller, ctx_state.get_nonce(caller, &mut None)), vec![])
    } else {
        let addr = H160::from_slice(&to);
        code = ctx_state.get_code(addr, &mut None);
         
        (false, addr, data)
    };

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
        nonce: ctx_state.get_nonce(caller, &mut None),
        gas_limit,
        gas_price,
        max_priority_fee_per_gas,
        max_fee_per_gas,
        tx_type,
        skip_balance: false,
        skip_block_gas_limit_validation: false,
        skip_nonce: false
    };

    let start_time = Instant::now();

    let result = new_tx(ctx_state, &mut None, run_args, &tx_args, &env, TxType::from(tx_type), access_list_address_len, access_list_slot_len);
    log_debug!("result {:?}", result);
    let elapsed = start_time.elapsed();
    log_debug!("run time: {:?}", elapsed);
    let total_nanos = elapsed.as_secs()
        .saturating_mul(1_000_000_000)
        .saturating_add(u64::from(elapsed.subsec_nanos()));
    let elapsed_u256 = move_u256::from(total_nanos);
    
    Ok(smallvec![Value::u64(result.0 as u64), Value::u256(elapsed_u256)])
}


fn native_get_balance_change_set(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let ctx = context.extensions().get::<NativeEvmContext>();

    let len = ctx.state.substate.balances.len();
    let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
    let mut value_list: Vec<move_u256> = Vec::new();

    for (address, value) in ctx.state.substate.balances.iter() {
        let mut padded_address = vec![0u8; 12]; // 12 个前置零
        padded_address.extend_from_slice(address.as_bytes());

        address_list.extend_from_slice(&padded_address);

        value_list.push(move_u256::from(*value));
    }

    Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u256(value_list)])
}

fn native_get_nonce_change_set(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let ctx = context.extensions().get::<NativeEvmContext>();

    let len = ctx.state.substate.nonces.len();
    let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
    let mut value_list: Vec<move_u256> = Vec::new();

    for (address, value) in ctx.state.substate.nonces.iter() {
        let mut padded_address = vec![0u8; 12]; 
        padded_address.extend_from_slice(address.as_bytes());

        address_list.extend_from_slice(&padded_address);

        value_list.push(move_u256::from(*value));
    }

    Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u256(value_list)])
}

fn native_get_code_change_set(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let ctx = context.extensions().get::<NativeEvmContext>();

    let len = ctx.state.substate.codes.len();
    let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);
    let mut code_list: Vec<u8> = Vec::new();
    let mut code_lengths: Vec<u64> = Vec::new();

    for (address, code) in ctx.state.substate.codes.iter() {
        let mut padded_address = vec![0u8; 12]; 
        padded_address.extend_from_slice(address.as_bytes());

        address_list.extend_from_slice(&padded_address);

        code_lengths.push(code.len() as u64);
        code_list.extend_from_slice(code);
    }

    Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list), Value::vector_u64(code_lengths), Value::vector_u8(code_list)])
}

fn native_get_address_change_set(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let ctx = context.extensions().get::<NativeEvmContext>();

    let len = ctx.state.substate.storages.len();
    let mut address_list: Vec<u8> = Vec::with_capacity(len * 32);

    for address in ctx.state.substate.storages.keys() {
        let mut padded_address = vec![0u8; 12]; 
        padded_address.extend_from_slice(address.as_bytes());

        address_list.extend_from_slice(&padded_address);
    }

    Ok(smallvec![Value::u64(len as u64), Value::vector_u8(address_list)])
}

fn native_get_storage_change_set(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let target_address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();

    let mut keys: Vec<move_u256> = Vec::new();
    let mut values: Vec<move_u256> = Vec::new();

    if let Some(storage_map) = ctx.state.substate.storages.get(&target_address) {
        for (key, value) in storage_map.iter() {
            keys.push(move_u256::from(*key));
            values.push(move_u256::from(*value));
        }
    }

    Ok(smallvec![Value::vector_u256(keys), Value::vector_u256(values)])
}

fn native_get_logs(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> { 
    let ctx = context.extensions().get::<NativeEvmContext>();

    let mut addresses: Vec<u8> = Vec::new();
    let mut topics_data: Vec<Vec<u8>> = Vec::new();
    let mut data: Vec<Vec<u8>> = Vec::new();
    let mut topics_lengths: Vec<u64> = Vec::new();

    for log in ctx.state.substate.logs.iter() {
        let mut padded_address = vec![0u8; 12]; // 12 个前置零
        padded_address.extend_from_slice(log.address.as_bytes());
        addresses.extend_from_slice(&padded_address);
        
        let mut topics_bytes = Vec::new();
        for topic in &log.topics {
            topics_bytes.extend_from_slice(topic);
        }
        topics_data.push(topics_bytes);
        topics_lengths.push(log.topics.len() as u64);
        
        data.push(log.data.clone());
    }

    let topics_data_value = Value::vector_u8(topics_data.into_iter().flatten().collect::<Vec<u8>>());
    let data_value = Value::vector_u8(data.into_iter().flatten().collect::<Vec<u8>>());
    let topics_lengths_value = Value::vector_u64(topics_lengths);

    Ok(smallvec![
        Value::u64(ctx.state.substate.logs.len() as u64),
        Value::vector_u8(addresses),
        topics_data_value,
        data_value,
        topics_lengths_value
    ])
}
/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("execute_tx", native_execute_tx as RawSafeNative),
        ("execute_tx_for_test", native_execute_tx_for_test as RawSafeNative),
        ("set_code", native_set_code as RawSafeNative),
        ("set_account", native_set_account as RawSafeNative),
        ("set_storage", native_set_storage as RawSafeNative),
        ("set_nonce", native_set_nonce as RawSafeNative),
        ("add_always_warm_address", native_add_always_warm_address as RawSafeNative),
        ("add_always_warm_slot", native_add_always_warm_slot as RawSafeNative),
        ("calculate_root", native_calculate_root as RawSafeNative),
        ("get_balance_change_set", native_get_balance_change_set as RawSafeNative),
        ("get_nonce_change_set", native_get_nonce_change_set as RawSafeNative),
        ("get_code_change_set", native_get_code_change_set as RawSafeNative),
        ("get_address_change_set", native_get_address_change_set as RawSafeNative),
        ("get_storage_change_set", native_get_storage_change_set as RawSafeNative),
        ("get_logs", native_get_logs as RawSafeNative)
        // ("calculate_root", native_calculate_root as RawSafeNative),
        // ("get_balance_change_set", native_get_balance_change_set as RawSafeNative),
        // ("get_nonce_change_set", native_get_nonce_change_set as RawSafeNative),
        // ("get_code_change_set", native_get_code_change_set as RawSafeNative),
        // ("get_address_change_set", native_get_address_change_set as RawSafeNative),
        // ("get_storage_change_set", native_get_storage_change_set as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}