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

fn native_revert(
<<<<<<< HEAD
    context: &mut SafeNativeContext,
=======
    _context: &mut SafeNativeContext,
>>>>>>> move-v13-kun-v2
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
	let message_bytes = safely_pop_arg!(args, Vec<u8>);
	let message_string = String::from_utf8(message_bytes).unwrap();
<<<<<<< HEAD
	println!("native_revert:${:?}", message_string);
	return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message(message_string)));
	Ok(smallvec![])
=======
	return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message(message_string)));
>>>>>>> move-v13-kun-v2
}


/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [("revert", native_revert as RawSafeNative)];

    builder.make_named_natives(natives)
}