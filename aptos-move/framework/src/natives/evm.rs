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
use ethers::types::{U256, U512};

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

fn native_mul(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = safely_pop_arg!(args, move_u256);
    let a = safely_pop_arg!(args, move_u256);

    let a_u256 = U256::from_little_endian(&a.to_le_bytes());
    let b_u256 = U256::from_little_endian(&b.to_le_bytes());
    let n_u256 = a_u256.overflowing_mul(b_u256).0;

    let mut array: [u8; 32] = [0; 32];
    n_u256.to_little_endian(&mut array);

    Ok(smallvec![
        Value::u256(move_u256::from_le_bytes(&array))
    ])
}

fn native_mul_mod(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let n = safely_pop_arg!(args, move_u256);
    let b = safely_pop_arg!(args, move_u256);
    let a = safely_pop_arg!(args, move_u256);

    let a_u256 = U256::from_little_endian(&a.to_le_bytes());
    let b_u256 = U256::from_little_endian(&b.to_le_bytes());
    let n_u256 = U256::from_little_endian(&n.to_le_bytes());

    let a_512 = U512::from(a_u256);
    let b_512 = U512::from(b_u256);
    let n_512 = U512::from(n_u256);

    let r;
    if a_512.is_zero() {
        r = U256::zero();
    } else {
        r = U256::try_from((a_512 * b_512) % n_512).unwrap();
    }
    let mut array: [u8; 32] = [0; 32];
    r.to_little_endian(&mut array);

    Ok(smallvec![
        Value::u256(move_u256::from_le_bytes(&array))
    ])
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
        ("decode_raw_tx", native_decode_raw_tx as RawSafeNative),
        ("mul", native_mul as RawSafeNative),
        ("mul_mod", native_mul_mod as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}