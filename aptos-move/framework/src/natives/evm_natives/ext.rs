use ethers::types::{U256, H256, Address, Bytes};
use std::collections::{HashMap, HashSet};
use super::schedule::Schedule;
use super::env_info::EnvInfo;
use std::sync::Arc;

pub struct LogEntry {
	pub topics: Vec<H256>,
	pub data: Bytes
}

#[derive(Copy, Clone, PartialEq, Eq, Debug, Hash)]
pub enum CreateContractAddress {
	/// Address is calculated from sender and nonce. pWASM `create` scheme.
	FromSenderAndNonce,
	/// Address is calculated from sender, salt and code hash. pWASM `create2` scheme and EIP-1014 CREATE2 scheme.
	FromSenderSaltAndCodeHash(H256),
	/// Address is calculated from code hash and sender. Used by pwasm create ext.
	FromSenderAndCodeHash,
}

#[derive(PartialEq, Eq, Hash, Debug)]
pub enum CallType {
	Call, Create
}

#[derive(PartialEq, Eq, Hash, Debug)]
pub struct Call {
	pub call_type: CallType,
	pub create_scheme: Option<CreateContractAddress>,
	pub gas: U256,
	pub sender_address: Option<Address>,
	pub receive_address: Option<Address>,
	pub value: Option<U256>,
	pub data: Bytes,
	pub code_address: Option<Address>,
}


#[derive(Default)]
pub struct Ext {
	pub store: HashMap<H256, H256>,
	pub suicides: HashSet<Address>,
	pub calls: HashSet<Call>,
	pub sstore_clears: i128,
	pub depth: usize,
	pub blockhashes: HashMap<U256, H256>,
	pub codes: HashMap<Address, Arc<Bytes>>,
	pub logs: Vec<LogEntry>,
	pub info: EnvInfo,
	pub schedule: Schedule,
	pub balances: HashMap<Address, U256>,
	pub tracing: bool,
	pub is_static: bool,

	chain_id: u64,
}

impl Ext {
    pub fn new() -> Self {
		Ext::default()
	}
	
}