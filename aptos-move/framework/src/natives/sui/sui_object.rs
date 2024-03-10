use aptos_native_interface::{
    safely_pop_arg, RawSafeNative, SafeNativeBuilder, SafeNativeContext, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{StructRef, Value}
};

use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};

fn native_borrow_uid(
    _context: &mut SafeNativeContext,
    ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(ty_args.len() == 1);
    debug_assert!(args.len() == 1);

    let obj = safely_pop_arg!(args, StructRef);
    let id_field = obj.borrow_field(0)?;

    Ok(smallvec![
        id_field
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
        ("borrow_uid", native_borrow_uid  as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}