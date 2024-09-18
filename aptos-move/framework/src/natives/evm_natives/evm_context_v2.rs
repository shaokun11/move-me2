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
use move_vm_runtime::data_cache::TransactionDataCache;
use move_vm_runtime::native_functions::NativeFunction;
use move_vm_runtime::native_functions::NativeContext;
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

impl<'a> NativeEvmContext {
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
    mut _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let tx_type = safely_pop_arg!(args, u8);
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

    // let type_ = ty_args.pop().unwrap();
    let env = parse_env(env_data);

    // let ctx_state = &mut State::new();

    // 现在可以安全地获取 `data_store_mut`
    // let data_store = context.data_store_mut(); // `extensions` 的可变借用在此结束

    // 现在可以安全地获取 `data_store`
    // let data_store = context.data_store();
 
    let ctx_state = &mut context.extensions_mut().get_mut::<NativeEvmContext>().state;// 获取 data_cache 的可变引用
    let code;

    // let ctx_state = &mut extensions.get_mut::<NativeEvmContext>().state;
    // drop(extensions);

    let caller = H160::from_slice(&from);
    let (is_create, address, calldata) = if to.len() == 0 {
        code = data.clone();
        (true, get_contract_address(caller, ctx_state.get_nonce(caller)), vec![])
    } else {
        let addr = H160::from_slice(&to);
        code = ctx_state.get_code(addr);
         
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
        gas_limit,
        gas_price,
        max_priority_fee_per_gas,
        max_fee_per_gas,
        tx_type,
    };

    let start_time = Instant::now();

    let result = new_tx(ctx_state, None, run_args, &tx_args, &env, TxType::from(tx_type), access_list_address_len, access_list_slot_len);
    log_debug!("result {:?}", result);
    let elapsed = start_time.elapsed();
    log_debug!("run time: {:?}", elapsed);
    let total_nanos = elapsed.as_secs()
        .saturating_mul(1_000_000_000)
        .saturating_add(u64::from(elapsed.subsec_nanos()));
    let elapsed_u256 = move_u256::from(total_nanos);
    
    Ok(smallvec![Value::u64(result as u64), Value::u256(elapsed_u256)])
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
        ("set_code", native_set_code as RawSafeNative),
        ("set_account", native_set_account as RawSafeNative),
        ("set_storage", native_set_storage as RawSafeNative),
        ("set_nonce", native_set_nonce as RawSafeNative),
        ("add_always_warm_address", native_add_always_warm_address as RawSafeNative),
        ("add_always_warm_slot", native_add_always_warm_slot as RawSafeNative),
        ("calculate_root", native_calculate_root as RawSafeNative)
        // ("calculate_root", native_calculate_root as RawSafeNative),
        // ("get_balance_change_set", native_get_balance_change_set as RawSafeNative),
        // ("get_nonce_change_set", native_get_nonce_change_set as RawSafeNative),
        // ("get_code_change_set", native_get_code_change_set as RawSafeNative),
        // ("get_address_change_set", native_get_address_change_set as RawSafeNative),
        // ("get_storage_change_set", native_get_storage_change_set as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}