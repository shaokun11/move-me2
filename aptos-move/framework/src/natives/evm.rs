use move_binary_format::errors::PartialVMError;
use aptos_types::{vm_status::StatusCode};
use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeError, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};
use move_core_types::{u256::U256 as move_u256};
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use ethers::types::{Transaction};
use ethers::utils::rlp::{Rlp, Decodable};
use ethers::types::U256;

fn native_revert(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());

	let message_bytes = safely_pop_arg!(args, Vec<u8>);
	let message_string = String::from_utf8(message_bytes).unwrap();
	return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message(message_string)));
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

        Ok(smallvec![
            Value::u64(chain_id),
            Value::u64(U256::as_u64(&data.nonce)),
            Value::vector_u8(from),
            Value::vector_u8(to),
            Value::u256(move_u256::from_str_radix(&data.value.to_string(), 10).unwrap()),
            Value::vector_u8(data.input)
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
        ("decode_raw_tx", native_decode_raw_tx as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}