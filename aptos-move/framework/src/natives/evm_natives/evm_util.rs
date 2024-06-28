use crate::natives::evm_natives::{
    helpers::{move_u256_to_evm_u256, evm_u256_to_move_u256}
};

use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};
use move_core_types::{u256::U256 as move_u256};
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use ethers::types::{U256, U512};

fn native_new_fixed_length_vector(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let c = &safely_pop_arg!(args, u64);
    let v = vec![0; c.clone() as usize];
    Ok(smallvec![Value::vector_u8(v)])
}

fn native_vector_extend(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let mut a = safely_pop_arg!(args, Vec<u8>);
    let mut b = safely_pop_arg!(args, Vec<u8>);
    a.append(&mut b);
    Ok(smallvec![Value::vector_u8(a)])
}

fn native_vector_slice(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let size = safely_pop_arg!(args, u64);
    let pos = safely_pop_arg!(args, u64);
    let array = safely_pop_arg!(args, Vec<u8>);
    Ok(smallvec![Value::vector_u8(slice_with_default(&array, pos, size))])
}

fn slice_with_default(vec: &Vec<u8>, pos: u64, size: u64) -> Vec<u8> {
    let pos = pos as usize;
    let size = size as usize;
    let mut result = Vec::with_capacity(size);

    for i in pos..pos+size {
        if i < vec.len() {
            result.push(vec[i]);
        } else {
            result.push(0);
        }
    }

    result
}



/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("new_fixed_length_vector", native_new_fixed_length_vector as RawSafeNative),
        ("vector_extend", native_vector_extend as RawSafeNative),
        ("vector_slice", native_vector_slice as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}