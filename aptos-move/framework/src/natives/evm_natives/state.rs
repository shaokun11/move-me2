// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0
use std::{
    boxed::Box,
    collections::{BTreeMap, BTreeSet},
    vec::Vec,
};
use aptos_native_interface::SafeNativeContext;
use ethers::utils::rlp::{RlpStream, Encodable};
use std::collections::HashMap;
use trie;
use core::mem;
use primitive_types::{H160, H256, U256};
use move_core_types::u256::U256 as move_u256;
use ethers::utils::keccak256;
use crate::log_debug;
use move_vm_types::values::{StructRef, Value, Reference};
use aptos_table_natives::{NativeTableContext, get_table_handle};

use move_core_types::account_address::AccountAddress;
use move_vm_types::loaded_data::runtime_types::Type;


fn rlp_encode(balance: U256, code: Vec<u8>, nonce: U256, storage_root: H256) -> Vec<u8> {
	let mut stream = RlpStream::new_list(4);
	let code_hash = keccak256(&code).to_vec();
	stream.append(&nonce);
	stream.append(&balance);
	stream.append(&storage_root);
	stream.append(&code_hash);
	stream.out().to_vec()
}


fn calculate_storage_root(storages: &BTreeMap<U256, U256>) -> H256 {
	let mut m = HashMap::new();
	for key in storages.keys() {
	    let mut key_bytes: [u8; 32] = [0; 32];
	    key.to_big_endian(&mut key_bytes);
	    let value = *storages.get(key).unwrap();
	    if value != U256::zero(){
	        let value_rlp_bytes = value.rlp_bytes().to_vec();
	        m.insert(keccak256(key_bytes).to_vec(), value_rlp_bytes);
	    }
	}

	H256::from_slice(&trie::build(&m).0)
}

fn to_move_address(evm_address: H160) -> AccountAddress {
	let mut padded_address = [0u8; 32];
    padded_address[12..32].copy_from_slice(evm_address.as_bytes());
	AccountAddress::from_bytes(padded_address).unwrap()
}

#[derive(Default)]
pub struct State {
    pub substate: Box<Substate>,
    accessed: BTreeSet<(H160, Option<U256>)>,
	storage_type: Option<Type>,
	value_box_type: Option<Type>
}
impl State {
	pub fn new() -> Self {
        Self {
            substate: Box::new(Substate::new()),
            accessed: BTreeSet::new(),
			storage_type: None,
			value_box_type: None
        }
    }

	pub fn read_table(
		&self,
		state_ref: &StructRef,
		key: Value,
		context: &mut Option<&mut SafeNativeContext>
	) -> U256 {
		if let Some(context) = context.as_deref_mut() {
			let table_context = context.extensions().get::<NativeTableContext>();
			let mut table_data = table_context.table_data.borrow_mut();
			
			let handle = match get_table_handle(state_ref) {
				Ok(h) => h,
				Err(err) => {
					log_debug!("err1 {:?}", err);
					return U256::zero()
				},
			};
			
			let table = match table_data.get_or_create_table(context, handle, &Type::U256, self.value_box_type.as_ref().unwrap()) {
				Ok(t) => t,
				Err(err) => {
					log_debug!("err2 {:?}", err);
					return U256::zero()
				},
			};
		
			let key_bytes = key.simple_serialize(&table.key_layout).unwrap_or_default();
		
			let (gv, _) = match table.get_or_create_global_value(table_context, key_bytes) {
				Ok(v) => v,
				Err(err) => {
					log_debug!("err3 {:?}", err);
					return U256::zero()
				},
			};
	
			if !gv.exists().unwrap_or(false) {
				return U256::zero();
			}
		
			match gv.borrow_global() {
				Ok(ref_val) => {
					let slot_ref = ref_val.value_as::<StructRef>().unwrap();
					return slot_ref.borrow_field(0).unwrap().value_as::<Reference>().unwrap().read_ref().unwrap().value_as::<move_u256>().unwrap().to_ethers_u256();
				}
				Err(err) => {
					log_debug!("err4 {:?}", err);
					return U256::zero()
				},
			}
		} else {
			return U256::zero()
		}
	
		
	}

	pub fn get_resource(
		&self,
		context: &mut Option<&mut SafeNativeContext>,
		address: H160,
	) -> Option<Value> {
		if let Some(storage_type) = &self.storage_type {
			if let Some(context) = context.as_deref_mut() {
				let account_address = to_move_address(address);
				match context.load_resource(account_address, storage_type) {
					Ok((global_value, _)) => {
						if global_value.exists().unwrap_or(false) {
							match global_value.borrow_global() {
								Ok(value) => Some(value),
								Err(_) => None,
							}
						} else {
							None
						}
					},
					Err(_) => {
						None
					},
				}
			} else {
				None
			}
		} else {
			None
		}
	}

	fn exist_account_storage(&mut self, evm_address: H160, context: &mut Option<&mut SafeNativeContext>) -> bool {
		if let Some(storage_type) = &self.storage_type  {
			if let Some(context) = context {
				match context.load_resource(to_move_address(evm_address), storage_type) {
					Ok((value, _)) => {
						value.exists().unwrap_or(false)
					},
					Err(_) => {
						false
					},
				}
			} else {
				false
			}
		} else {
            false
        }
	}

	pub fn get_state_storage(
		&mut self,
		address: H160,
		key: U256,
		context: &mut Option<&mut SafeNativeContext>,
	) -> U256 {
		if let Some(resource) = self.get_resource(context, address) {
			if let Ok(account_ref) = resource.value_as::<StructRef>() {
				if let Ok(field) = account_ref.borrow_field(3) {
					if let Ok(table_ref) = field.value_as::<StructRef>() {
						let value = self.read_table(&table_ref, Value::u256(move_u256::from( key)), context);
						self.set_storage(address, key, value);
						return value;
					}
				}
			}
		}
		return U256::zero()
	}

	pub fn get_balance_storage(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>,
	) -> U256 {
		match self.get_resource(context, address) {
			Some(resource) => {
				let account_ref = resource.value_as::<StructRef>().unwrap();
				match account_ref.borrow_field(0).unwrap().value_as::<Reference>().unwrap().read_ref() {
					Ok(value) => {
						let balance = value.value_as::<move_u256>().unwrap().to_ethers_u256();
						self.set_balance(address, balance);
						return balance;
					}
					Err(err) => {
						log_debug!("err {:?}", err);
						return U256::zero()
					}
				}
			}
			None => {
				return U256::zero()
			}
		};
	}

	pub fn get_nonce_storage(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>,
	) -> U256 {
		match self.get_resource(context, address) {
			Some(resource) => {
				let account_ref = resource.value_as::<StructRef>().unwrap();
				match account_ref.borrow_field(2).unwrap().value_as::<Reference>().unwrap().read_ref() {
					Ok(value) => {
						let nonce = value.value_as::<move_u256>().unwrap().to_ethers_u256();
						self.set_nonce(address, nonce);
						return nonce;
					}
					Err(err) => {
						log_debug!("err {:?}", err);
						return U256::zero()
					}
				}
			}
			None => {
				return U256::zero()
			}
		};
	}

	pub fn get_code_storage(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>,
	) -> Vec<u8> {
		match self.get_resource(context, address) {
			Some(resource) => {
				let account_ref = resource.value_as::<StructRef>().unwrap();
				match account_ref.borrow_field(1).unwrap().value_as::<Reference>().unwrap().read_ref() {
					Ok(value) => {
						let code = value.value_as::<Vec<u8>>().unwrap();
						self.set_code(address, code.clone());
						return code;
					}
					Err(err) => {
						log_debug!("err {:?}", err);
						return vec![]
					}
				}
			}
			None => {
				return vec![]
			}
		};
	}

	pub fn add_log(&mut self, address: H160, topics: Vec<Vec<u8>>, data: Vec<u8>) {
        if topics.len() <= 4 {
            let log = Log { address, topics, data };
            self.substate.add_log(log);
        } else {
            log_debug!("Attempted to add a log with more than 4 topics");
        }
    }

	pub fn new_account(
		&mut self,
		contract: H160,
		code: Vec<u8>,
		balance: U256,
		nonce: U256,
		context: &mut Option<&mut SafeNativeContext>
	) {
		if self.exist(contract, context) {
			self.set_nonce(contract, U256::one());
		} else {
			self.set_code(contract, code);
			self.set_balance(contract, balance);
			self.set_nonce(contract, nonce);
		}
	}

	pub fn set_value_box_type(
		&mut self,
		value_box_type: Type
	) {
		self.value_box_type = Some(value_box_type);
	}

	pub fn set_storage_type(
		&mut self,
		storage_type: Type
	) {
		self.storage_type = Some(storage_type);
	}

	pub fn set_code (
	    &mut self,
	    address: H160,
	    code: Vec<u8>
	) {
	    self.substate.codes.insert(address, code);
	}

	pub fn set_storage (
	    &mut self,
	    address: H160,
	    index: U256,
	    value: U256
	) {
	    self.substate.storages.entry(address)
            .or_insert_with(BTreeMap::new)
            .insert(index, value);
	}

	pub fn set_transient_storage(
		&mut self,
		address: H160,
		index: U256,
	    value: U256
	) {
	    self.substate.transient_storages.insert((address, index), value);
	}

	pub fn transfer(
		&mut self,
		from: H160,
		to: H160,
		value: U256, 
		context: &mut Option<&mut SafeNativeContext>
	) -> bool {
		if value != U256::zero() {
			let success = self.sub_balance(from, value, context);
			if success {
				self.add_balance(to, value, context);
			}
			return success
		}

		true
	}

	pub fn add_balance(
		&mut self,
		address: H160,
		value: U256,
		context: &mut Option<&mut SafeNativeContext>
	) {
		if value != U256::zero() {
        let current_balance = match self.substate.known_balance(address) {
	            Some(value) => value,
	            None => self.get_balance_storage(address, context)
	        };
	        self.substate.balances.insert(address, current_balance.overflowing_add(value).0); 
	    }
	}

	pub fn sub_balance(
		&mut self,
		address: H160,
		value: U256,
		context: &mut Option<&mut SafeNativeContext>
	) -> bool {
		if value != U256::zero() {
	        let current_balance = match self.substate.known_balance(address) {
	            Some(value) => value,
	            None => self.get_balance_storage(address, context)
	        };
	        if current_balance < value {
	            return false
	        };
	        self.substate.balances.insert(address,  current_balance - value); 
	    }

	    true
	}

	pub fn set_balance(
		&mut self,
		address: H160,
		value: U256
	) {
		self.substate.balances.insert(address, value); 
	}

	pub fn inc_nonce(
		&mut self,
		address: H160
	) {
		let current_nonce = match self.substate.known_nonce(address) {
	        Some(value) => value,
	        None => U256::zero()
	    };
	    let new_nonce = current_nonce.overflowing_add(U256::from(1)).0;
	    self.substate.nonces.insert(address, new_nonce);
	}

	pub fn set_nonce(
		&mut self,
		address: H160,
		nonce: U256
	) {
		self.substate.nonces.insert(address, nonce);
	}

	pub fn add_always_warm_slot(
		&mut self,
		address: H160,
		index: Option<U256>
	) {
		self.accessed.insert((address, index));
	}

	pub fn add_warm_address(
		&mut self,
		address: H160
	) {
		if !self.substate.origin.contains_key(&address) {
	        self.substate.origin.insert(address, BTreeMap::new());
	    }
	}

	pub fn exist(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> bool {
		match self.substate.known_exists(address) {
	        Some(_) => true,
	        // to do get from storage
	        None => self.exist_account_storage(address, context)
	    }
	}

	pub fn storage_empty(
		&mut self,
		address: H160,
	) -> bool {
		// to do get from storage
		self.substate.known_storage_empty(address)
	}

	pub fn is_contract_or_created_account(&mut self, address: H160, context: &mut Option<&mut SafeNativeContext>) -> bool {
		if !self.exist(address, context) {
			false
		} else {
			self.get_code_length(address, context) > 0 
						|| self.get_nonce(address, context) > U256::zero() 
						|| !self.storage_empty(address)
		}
        
    }

	pub fn is_cold_address(
		&mut self,
		address: H160,
	) -> bool {
		let is_cold = !self.accessed.contains(&(address, None)) && self.substate.known_is_cold_address(address);
		if is_cold {
	        self.substate.origin.insert(address, BTreeMap::new());
	    }

	    is_cold
	}

	pub fn get_transient_storage(
		&mut self,
		address: H160,
		index: U256
	) -> U256 {
		match self.substate.known_transient_storage(address, index) {
	        Some(value) => value,
	        // to do get from storage
	        None => U256::zero()
	    }
	}

	pub fn get_origin(
		&mut self,
		address: H160,
		index: U256,
		context: &mut Option<&mut SafeNativeContext>
	) -> (bool, U256) {
		let mut is_cold_slot = !self.accessed.contains(&(address, Some(index)));
    	let result;

    	match self.substate.known_origin(address, index) {
	        Some(value) => {
	            is_cold_slot = false;

	            result = value;
	        },
	        None => {
	            let value = match self.substate.known_storage(address, index) {
	                Some(value) => value,
	                None => self.get_state_storage(address, index, context)
	            };
	            self.substate.origin.entry(address)
	            .or_insert_with(BTreeMap::new)
	            .insert(index, value);
	            result = value;
	        }
	    }
    	(is_cold_slot, result)
	}

	pub fn get_code(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> Vec<u8> {
		match self.substate.known_code(address) {
	        Some(value) => value,
	        None => self.get_code_storage(address, context)
	    }
	}

	pub fn get_code_length(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> u64 {
		self.get_code(address, context).len() as u64
	}

	pub fn get_code_hash(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> H256 {
		if !self.exist(address, context) {
			H256::zero()
		} else {
			let code = self.get_code(address, context);
			H256::from_slice(&keccak256(&code))
		}
	}

	pub fn get_balance(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> U256 {
		match self.substate.known_balance(address) {
	        Some(value) => value,
	        None => self.get_balance_storage(address, context)
	    }
	}

	pub fn get_nonce(
		&mut self,
		address: H160,
		context: &mut Option<&mut SafeNativeContext>
	) -> U256 {
		match self.substate.known_nonce(address) {
	        Some(value) => value,
	        None => self.get_nonce_storage(address, context)
	    }
	}

	pub fn get_storage(
		&mut self,
		address: H160,
		index: U256,
		context: &mut Option<&mut SafeNativeContext>
	) -> U256 {
		match self.substate.known_storage(address, index) {
	        Some(value) => value,
	        None => self.get_state_storage(address, index, context)
	    }
	}

	pub fn push_substate(&mut self) {
		let mut parent = Box::new(Substate::new());
		mem::swap(&mut parent, &mut self.substate);
		self.substate.parent = Some(parent);
	}

	pub fn revert_substate(&mut self) {
		let mut child = self.substate.parent.take().expect("unexpected substate pop");
    	mem::swap(&mut child, &mut self.substate);
	}

	pub fn commit_substate(&mut self) {
		let mut child = self.substate.parent.take().expect("uneven substate pop");
	    mem::swap(&mut child, &mut self.substate);
	    for (address, balance) in child.balances {
	        self.substate.balances.insert(address, balance);
	    }
	    for (address, code) in child.codes {
	        self.substate.codes.insert(address, code);
	    }
	    for (address, nonce) in child.nonces {
	        self.substate.nonces.insert(address, nonce);
	    }
	    for (address, inner_map) in child.storages {
	        for (key, value) in inner_map {
	            self.substate.storages.entry(address)
	            .or_insert_with(BTreeMap::new)
	            .insert(key, value);
	        }
	    }
	    for ((address, key), value) in child.transient_storages {
	        self.substate.transient_storages.insert((address, key), value);
	    }

	    for (address, inner_map) in child.origin {
	        let entry = self.substate.origin.entry(address)
	        .or_insert_with(BTreeMap::new);
	        for (key, value) in inner_map {
	            entry.insert(key, value);
	        }
	    }

	    for address in child.deletes {
	        self.substate.deletes.insert(address);
	    }

		for log in child.logs {
			self.substate.logs.push(log);
		}
	}

	pub fn calculate_test_state_root(&self) -> Vec<u8> {
	    let mut keys: Vec<H160> = Vec::new();

	    log_debug!(" storage {:?}", self.substate.storages);

	    keys.extend(self.substate.balances.keys().cloned());
	    keys.extend(self.substate.codes.keys().cloned());
	    keys.extend(self.substate.nonces.keys().cloned());
	    keys.extend(self.substate.storages.keys().cloned());

	    keys.sort();
	    keys.dedup();

	    let mut root_map = HashMap::new();

	    for address in keys {
	        let balance = match self.substate.known_balance(address) {
	            Some(value) => value,
	            None => U256::zero()
	        };

	        let nonce = match self.substate.known_nonce(address) {
	            Some(value) => value,
	            None => U256::zero()
	        };

	        let code = match self.substate.known_code(address) {
	            Some(value) => value,
	            None => vec![]
	        };

	        let storage_root = match self.substate.storages.get(&address) {
	            Some(value) => calculate_storage_root(value),
	            None => calculate_storage_root(&BTreeMap::new())
	        };

	        log_debug!("accounts {:?} {:?} {:?} {:?}", address, balance, nonce, storage_root);

	        let hashed_addr = keccak256(&address.to_fixed_bytes());
	        root_map.insert(hashed_addr.to_vec(), rlp_encode(balance, code, nonce, storage_root));
	    };

	    trie::build(&root_map).0.to_vec()
	}



}

#[derive(Clone, Debug, Default)]
pub struct Log {
    pub address: H160,
    pub topics: Vec<Vec<u8>>,
    pub data: Vec<u8>,
}

#[derive(Default)]
pub struct Substate {
    pub parent: Option<Box<Substate>>,
    pub balances: BTreeMap<H160, U256>,
    pub codes: BTreeMap<H160, Vec<u8>>,
    pub nonces: BTreeMap<H160, U256>,
    pub storages: BTreeMap<H160, BTreeMap<U256, U256>>,
    pub origin: BTreeMap<H160, BTreeMap<U256, U256>>,
    pub transient_storages: BTreeMap<(H160, U256), U256>,
    pub deletes: BTreeSet<H160>,
	pub logs: Vec<Log>
}

impl Substate {
    pub fn new() -> Self {
        Self {
            parent: None,
            balances: Default::default(),
            codes: Default::default(),
            nonces: Default::default(),
            storages: Default::default(),
            origin: Default::default(),
            transient_storages: Default::default(),
            deletes: Default::default(),
			logs: Default::default()
        }
    }
	
	pub fn add_log(&mut self, log: Log) {
        self.logs.push(log);
    }

    pub fn known_balance(&self, address: H160) -> Option<U256> {
        if let Some(balance) = self.balances.get(&address) {
            Some(*balance)
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_balance(address)
        } else {
            None
        }
    }

    pub fn known_code(&self, address: H160) -> Option<Vec<u8>> {
        if let Some(code) = self.codes.get(&address) {
            Some(code.clone())
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_code(address)
        } else {
            None
        }
    }

    pub fn known_nonce(&self, address: H160) -> Option<U256> {
        if let Some(nonce) = self.nonces.get(&address) {
            Some(*nonce)
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_nonce(address)
        } else {
            None
        }
    }

    pub fn known_storage(&self, address: H160, key: U256) -> Option<U256> {
        if let Some(inner_map) = self.storages.get(&address) {
            if let Some(value) = inner_map.get(&key) {
                return Some(*value)
            }
        }
        if let Some(parent) = self.parent.as_ref() {
            return parent.known_storage(address, key)
        }

        None
    }

    pub fn known_origin(&self, address: H160, key: U256) -> Option<U256> {
        if let Some(inner_map) = self.origin.get(&address) {
            if let Some(value) = inner_map.get(&key) {
                return Some(*value)
            }
        }
        if let Some(parent) = self.parent.as_ref() {
            return parent.known_origin(address, key)
        }

        None
    }

    pub fn known_storage_empty(&self, address: H160) -> bool {
        if self.storages.contains_key(&address) {
            false
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_storage_empty(address)
        } else {
            true
        }
    }

    pub fn known_transient_storage(&self, address: H160, key: U256) -> Option<U256> {
        if let Some(value) = self.transient_storages.get(&(address, key)) {
            Some(*value)
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_transient_storage(address, key)
        } else {
            None
        }
    }

    pub fn known_exists(&self, address: H160) -> Option<bool> {
        if self.balances.contains_key(&address)
            || self.nonces.contains_key(&address)
            || self.codes.contains_key(&address)
        {
            Some(true)
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_exists(address)
        } else {
            None
        }
    }

    // pub fn deleted(&self, address: H160) -> bool {
    //     if self.deletes.contains(&address) {
    //         true
    //     } else if let Some(parent) = self.parent.as_ref() {
    //         parent.deleted(address)
    //     } else {
    //         false
    //     }
    // }

    pub fn known_is_cold_address(&self, address: H160) -> bool {
        if self.origin.contains_key(&address) {
            false
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_is_cold_address(address)
        } else {
            true
        }
    }
}
