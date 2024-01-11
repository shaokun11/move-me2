use move_binary_format::errors::{PartialVMError, PartialVMResult};
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
use substrate_bn::{Fq, AffineG1, G1, Group};


fn read_point(x: &[u8], y: &[u8]) -> PartialVMResult<(G1)>  {
    let px = Fq::from_slice(bytes1).ok_or("Invalid input for point x");
    let py = Fq::from_slice(bytes2).ok_or("Invalid input for point y");
    Ok(AffineG1::new(px, py).ok_or("Invalid curve point")?.into())
}


fn native_bn_add(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
	let x1 = safely_pop_arg!(args, Vec<u8>);
    let y1 = safely_pop_arg!(args, Vec<u8>);
    let x2 = safely_pop_arg!(args, Vec<u8>);
    let y2 = safely_pop_arg!(args, Vec<u8>);

    let p1 = match read_point(Fq::from_slice(&x1), Fq::from_slice(&y1)) {
        Ok(p1) => p1,
        Err(err) => {
            return Err()
        }
    }

    // let p2 = match Fq::from_slice(&x1) {
    //     Ok(msg) => msg,
    //     Err(_) => {
    //         return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message("curve p1x")));
    //     },
    // };
    // let p1y = match Fq::from_slice(&y1) {
    //     Ok(msg) => msg,
    //     Err(_) => {
    //         return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message("curve p1y")));
    //     },
    // };
    // let p2x = match Fq::from_slice(&x2) {
    //     Ok(msg) => msg,
    //     Err(_) => {
    //         return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message("curve p2x")));
    //     },
    // };
    // let p2y = match Fq::from_slice(&y2) {
    //     Ok(msg) => msg,
    //     Err(_) => {
    //         return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message("curve p2y")));
    //     },
    // };


	let message_string = String::from_utf8(message_bytes).unwrap();
	return Err(SafeNativeError::InvariantViolation(PartialVMError::new(StatusCode::EVM_CONTRACT_ERROR).with_message(message_string)));
}


/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [("bn_add", native_bn_add as RawSafeNative)];

    builder.make_named_natives(natives)
}