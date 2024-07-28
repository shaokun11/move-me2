// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0

use move_core_types::{u256::U256 as move_u256};
use ethers::types::{U256 as evm_u256, H160};

pub(crate) fn move_u256_to_evm_u256(value: &move_u256) -> evm_u256 {
    evm_u256::from_little_endian(&value.to_le_bytes())
}

pub(crate) fn bytes_to_h160(bytes: &Vec<u8>) -> H160 {
	let end_slice = &bytes[bytes.len() - 20..];
    H160::from_slice(end_slice)
}

pub(crate) fn get_move_u256_bytes(value: &move_u256) -> Vec<u8> {
	let evm_value = evm_u256::from_little_endian(&value.to_le_bytes());
    let mut array: [u8; 32] = [0; 32];
    evm_value.to_big_endian(&mut array);
    array.to_vec()
}

pub(crate) fn evm_u256_to_move_u256(value: &evm_u256) -> move_u256 {
	let mut array: [u8; 32] = [0; 32];
    value.to_little_endian(&mut array);
    move_u256::from_le_bytes(&array)
}