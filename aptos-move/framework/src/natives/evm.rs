use std::collections::VecDeque;

use ripemd::Digest as OtherDigest;
use sha2::Digest;
use smallvec::{smallvec, SmallVec};

use aptos_gas_schedule::gas_params::natives::aptos_framework::*;
use aptos_native_interface::{
    RawSafeNative, SafeNativeBuilder, SafeNativeContext, SafeNativeError, SafeNativeResult,
};
use move_binary_format::errors::PartialVMError;
use move_binary_format::file_format::{CodeOffset, FunctionDefinitionIndex};
use move_core_types::account_address::AccountAddress;
use move_core_types::gas_algebra::InternalGas;
use move_core_types::language_storage::ModuleId;
use move_core_types::vm_status::StatusCode;
use move_vm_runtime::native_functions::NativeFunction;
use move_vm_types::{loaded_data::runtime_types::Type, values::Value};

#[derive(Debug, Clone)]
pub struct MsgSenderGasParameters {
    pub base: InternalGas,
}

fn native_msg_sender(
    context: &mut SafeNativeContext,
    mut _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(args.is_empty());
    context.charge(EVM_MSG_SENDER_BASE)?;

    println!("--------1------");
    let mut address = AccountAddress::ONE;
    match context.stack_frames(1).stack_trace().first() {
        None => {
            println!("--------2------");
        },
        Some(model_id) => {
            println!("--------3------");
            address = *model_id.to_owned().0.unwrap().address();
        },
    }
    Ok(smallvec![Value::address(address)])
}

pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [("msg_sender", native_msg_sender as RawSafeNative)];
    builder.make_named_natives(natives)
}
