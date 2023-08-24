// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0

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
use std::{collections::VecDeque, hash::Hasher, sync::Arc};
use tiny_keccak::{Hasher as KeccakHasher, Keccak};

/***************************************************************************************************
 * native fun sip_hash
 *
 *   gas cost: base_cost + unit_cost * data_length
 *
 **************************************************************************************************/

#[derive(Debug, Clone)]
pub struct ChainIdGasParameters {
    pub base: InternalGas,
}

fn native_chain_id(
    gas_params: &ChainIdGasParameters,
    context: &mut SafeNativeContext,
    mut _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    debug_assert!(args.is_empty());
    context.charge(gas_params.base)?;
    println!("native_chain_id call gas_params.base {} ",gas_params.base,);
    Ok(smallvec![Value::u256(10)])
}

/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
#[derive(Debug, Clone)]
pub struct GasParameters {
    pub chain_id: ChainIdGasParameters,
}

pub fn make_all(
    gas_params: GasParameters,
    timed_features: TimedFeatures,
    features: Arc<Features>,
) -> impl Iterator<Item = (String, NativeFunction)> {
    let natives = [
        (
            "chain_id",
            make_safe_native(
                gas_params.chain_id,
                timed_features.clone(),
                features.clone(),
                native_chain_id,
            ),
        ),
    ];

    crate::natives::helpers::make_module_natives(natives)
}
