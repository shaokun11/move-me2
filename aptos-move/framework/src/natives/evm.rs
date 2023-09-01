// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0

use std::collections::vec_deque::VecDeque;
use std::sync::Arc;
use crate::{
    natives::helpers::{make_safe_native, SafeNativeContext, SafeNativeResult},
    safely_assert_eq, safely_pop_arg,
};
use aptos_types::on_chain_config::{Features, TimedFeatures};
use move_core_types::gas_algebra::{InternalGas, InternalGasPerByte, NumBytes};
use move_vm_runtime::native_functions::NativeFunction;
use move_vm_types::{loaded_data::runtime_types::Type, values::Value};
use ripemd::Digest as OtherDigest;
use sha2::Digest;
use smallvec::{smallvec, SmallVec};
use move_core_types::account_address::AccountAddress;

/***************************************************************************************************
 * native fun sip_hash
 *
 *   gas cost: base_cost + unit_cost * data_length
 *
 **************************************************************************************************/


#[derive(Debug, Clone)]
pub struct AddressVectorGasParameters {
    pub base: InternalGas,
}

fn native_address_to_vector(
    gas_params: &AddressVectorGasParameters,
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(args.len() == 1);
    context.charge(gas_params.base)?;
    println!("call native_address_to_vector");
    let bytes = safely_pop_arg!(args, AccountAddress);
    Ok(smallvec![Value::vector_u8(bytes.to_vec())])
}

/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
#[derive(Debug, Clone)]
pub struct GasParameters {
    pub address_to_vector: AddressVectorGasParameters,
}

pub fn make_all(
    gas_params: GasParameters,
    timed_features: TimedFeatures,
    features: Arc<Features>,
) -> impl Iterator<Item=(String, NativeFunction)> {
    let natives = [
        (
            "address_to_vector",
            make_safe_native(
                gas_params.address_to_vector,
                timed_features.clone(),
                features.clone(),
                native_address_to_vector,
            ),
        ),
    ];

    crate::natives::helpers::make_module_natives(natives)
}
