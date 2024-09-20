use crate::natives::evm_natives::{
    helpers::{evm_u256_to_move_u256}
};
use move_binary_format::errors::PartialVMError;
use aptos_types::{vm_status::StatusCode};
use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeError, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use ethers::types::{Transaction};
use ethers::types::transaction::eip2930::AccessList;
use ethers::utils::rlp::{Rlp, Decodable};
use ethers::types::{U256};
use hex;
use std::io::{Write};

fn native_revert(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());

	let message_bytes = safely_pop_arg!(args, Vec<u8>);
	return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message(hex::encode(message_bytes))));
}

fn encode_access_list(access_lists: &AccessList) -> Vec<u8> {
    let mut buf = Vec::new();
    let access_list_size = access_lists.0.len();
    if access_list_size > 0 {
        buf.write_all(&access_list_size.to_be_bytes()).expect("Failed to write list size");
        for item in access_lists.0.iter() {
            buf.write_all(&item.address.as_bytes()).expect("Failed to write item address");
            let item_size = item.storage_keys.len();
            buf.write_all(&item_size.to_be_bytes()).expect("Failed to write keys size");
            for key in item.storage_keys.iter() {
                buf.write_all(&key.as_bytes()).expect("Failed to write item key");
            }
        }
    }
    
    buf
}

fn native_decode_raw_tx(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(args.len() == 1);

    let tx_bytes = safely_pop_arg!(args, Vec<u8>);
    let d = Rlp::new(&tx_bytes);
    let tx = Transaction::decode(&d);

    if tx.is_err() {
        return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message("Fail to decode raw tx".to_string())));
    } else {
        let data = tx.unwrap();
        let from = data.recover_from().unwrap().as_bytes().to_vec();
        let to = match data.to {
            Some(a) => a.as_bytes().to_owned(),
            None => vec![],
        };
        let chain_id = match data.chain_id {
            Some(a) => U256::as_u64(&a),
            None => 0,
        };
        let gas_price = match data.gas_price {
            Some(a) => a,
            None => U256::zero(),
        };

        let max_fee_per_gas = match data.max_fee_per_gas {
            Some(a) => a,
            None => U256::zero(),
        };

        let max_priority_fee_per_gas = match data.max_priority_fee_per_gas {
            Some(a) => a,
            None => U256::zero(),
        };

        let tx_type = match data.transaction_type {
            Some(a) => a.as_u64(),
            None => 0,
        };

        let access_lists = match data.access_list { 
            Some(a) => encode_access_list(&a),
            None => vec![]
        };

        Ok(smallvec![
            Value::u64(chain_id),
            Value::vector_u8(from),
            Value::vector_u8(to),
            Value::u256(evm_u256_to_move_u256(&data.nonce)),
            Value::u256(evm_u256_to_move_u256(&data.value)),
            Value::vector_u8(data.input),
            Value::u256(evm_u256_to_move_u256(&data.gas)),
            Value::u256(evm_u256_to_move_u256(&gas_price)),
            Value::u256(evm_u256_to_move_u256(&max_fee_per_gas)),
            Value::u256(evm_u256_to_move_u256(&max_priority_fee_per_gas)),
            Value::vector_u8(access_lists),
            Value::u64(tx_type)
        ])
    }
}


/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("revert", native_revert as RawSafeNative),
        ("decode_raw_tx", native_decode_raw_tx as RawSafeNative),
    ];

    builder.make_named_natives(natives)
}