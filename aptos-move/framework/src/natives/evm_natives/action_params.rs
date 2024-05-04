// Copyright 2015-2020 Parity Technologies (UK) Ltd.
// This file is part of Parity Ethereum.

// Parity Ethereum is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Parity Ethereum is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Parity Ethereum.  If not, see <http://www.gnu.org/licenses/>.

//! Evm input params.
use ethers::types::{U256, H256, Address};
use ethers::utils::rlp::{Encodable, Decodable, DecoderError, RlpStream, Rlp};
use parity_bytes::{Bytes};
use std::sync::Arc;


/// The type of the instruction.
#[derive(Debug, PartialEq, Clone)]
pub enum ActionType {
	/// CREATE.
	Create,
	/// CALL.
	Call,
	/// CALLCODE.
	CallCode,
	/// DELEGATECALL.
	DelegateCall,
	/// STATICCALL.
	StaticCall,
	/// CREATE2.
	Create2
}

impl Encodable for ActionType {
	fn rlp_append(&self, s: &mut RlpStream) {
		let v = match *self {
			ActionType::Create => 0u32,
			ActionType::Call => 1,
			ActionType::CallCode => 2,
			ActionType::DelegateCall => 3,
			ActionType::StaticCall => 4,
			ActionType::Create2 => 5,
		};
		Encodable::rlp_append(&v, s);
	}
}

impl Decodable for ActionType {
	fn decode(rlp: &Rlp) -> Result<Self, DecoderError> {
		rlp.as_val().and_then(|v| Ok(match v {
			0u32 => ActionType::Create,
			1 => ActionType::Call,
			2 => ActionType::CallCode,
			3 => ActionType::DelegateCall,
			4 => ActionType::StaticCall,
			5 => ActionType::Create2,
			_ => return Err(DecoderError::Custom("Invalid value of ActionType item")),
		}))
	}
}



/// Transaction value
#[derive(Clone, Debug)]
pub enum ActionValue {
	/// Value that should be transfered
	Transfer(U256),
	/// Apparent value for transaction (not transfered)
	Apparent(U256)
}

/// Type of the way parameters encoded
#[derive(Clone, Debug)]
pub enum ParamsType {
	/// Parameters are included in code
	Embedded,
	/// Parameters are passed in data section
	Separate,
}

impl ActionValue {
	/// Returns action value as U256.
	pub fn value(&self) -> U256 {
		match *self {
			ActionValue::Transfer(x) | ActionValue::Apparent(x) => x
		}
	}

	/// Returns the transfer action value of the U256-convertable raw value
	pub fn transfer<T: Into<U256>>(transfer_value: T) -> ActionValue {
		ActionValue::Transfer(transfer_value.into())
	}

	/// Returns the apparent action value of the U256-convertable raw value
	pub fn apparent<T: Into<U256>>(apparent_value: T) -> ActionValue {
		ActionValue::Apparent(apparent_value.into())
	}
}

// TODO: should be a trait, possible to avoid cloning everything from a Transaction(/View).
/// Action (call/create) input params. Everything else should be specified in Externalities.
#[derive(Clone, Debug)]
pub struct ActionParams {
	/// Address of currently executed code.
	pub code_address: Address,
	/// Hash of currently executed code.
	pub code_hash: Option<H256>,
	/// Receive address. Usually equal to code_address,
	/// except when called using CALLCODE.
	pub address: Address,
	/// Sender of current part of the transaction.
	pub sender: Address,
	/// Transaction initiator.
	pub origin: Address,
	/// Gas paid up front for transaction execution
	pub gas: U256,
	/// Gas price.
	pub gas_price: U256,
	/// Transaction value.
	pub value: ActionValue,
	/// Code being executed.
	pub code: Option<Arc<Bytes>>,
	/// Code version being executed.
	pub code_version: U256,
	/// Input data.
	pub data: Option<Bytes>,
	/// Type of action (e.g. CALL, DELEGATECALL, CREATE, etc.)
	pub action_type: ActionType,
	/// Param types encoding
	pub params_type: ParamsType,
}

impl Default for ActionParams {
	/// Returns default ActionParams initialized with zeros
	fn default() -> ActionParams {
		ActionParams {
			code_address: Address::zero(),
			code_hash: None,
			address: Address::zero(),
			sender: Address::zero(),
			origin: Address::zero(),
			gas: U256::zero(),
			gas_price: U256::zero(),
			value: ActionValue::Transfer(U256::zero()),
			code: None,
			code_version: U256::zero(),
			data: None,
			action_type: ActionType::Create,
			params_type: ParamsType::Separate,
		}
	}
}

