use aptos_native_interface::{
    safely_pop_arg, RawSafeNative, SafeNativeBuilder, SafeNativeContext, SafeNativeResult
};
use ark_serialize::Read;
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::Value
};

use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use move_core_types::account_address::AccountAddress;


fn native_sui_derive_id(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(args.len() == 2);
    let mut tx_hash = safely_pop_arg!(args, Vec<u8>);
    let ids_created = safely_pop_arg!(args, u64);
    let id_bytes = ids_created.to_le_bytes().to_vec();
    tx_hash.extend(&id_bytes);
    let seed = ethers::utils::keccak256(tx_hash);
    Ok(smallvec![
        Value::address(AccountAddress::new(seed))
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
        ("sui_derive_id", native_sui_derive_id  as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}