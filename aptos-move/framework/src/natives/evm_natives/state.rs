// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0
use std::{
    boxed::Box,
    collections::{BTreeMap, BTreeSet},
    vec::Vec,
};
use ethers::utils::rlp::{RlpStream, Encodable};
use std::collections::HashMap;
use trie;
use core::mem;
use primitive_types::{H160, H256, U256};
use ethers::utils::keccak256;
use crate::log_debug;

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

#[derive(Default, Debug)]
pub struct State {
	substate: Box<Substate>,
    accessed: BTreeSet<(H160, Option<U256>)>,
}

impl State {
	pub fn new() -> Self {
        Self {
            substate: Box::new(Substate::new()),
            accessed: BTreeSet::new()
        }
    }

	pub fn new_account(
		&mut self,
		contract: H160,
		code: Vec<u8>,
		balance: U256,
		nonce: U256
	) {
		if self.exist(contract) {
			self.set_nonce(contract, U256::one());
		} else {
			self.set_code(contract, code);
			self.set_balance(contract, balance);
			self.set_nonce(contract, nonce);
		}
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
		value: U256) -> bool {
		if value != U256::zero() {
			let success = self.sub_balance(from, value);
			if success {
				self.add_balance(to, value);
			}
			return success
		}

		true
	}

	pub fn add_balance(
		&mut self,
		address: H160,
		value: U256
	) {
		if value != U256::zero() {
        let current_balance = match self.substate.known_balance(address) {
	            Some(value) => value,
	            None => U256::zero()
	        };
	        self.substate.balances.insert(address, current_balance.overflowing_add(value).0); 
	    }
	}

	pub fn sub_balance(
		&mut self,
		address: H160,
		value: U256
	) -> bool {
		if value != U256::zero() {
	        let current_balance = match self.substate.known_balance(address) {
	            Some(value) => value,
	            None => U256::zero()
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
	) -> bool {
		match self.substate.known_exists(address) {
	        Some(_) => true,
	        // to do get from storage
	        None => false
	    }
	}

	pub fn storage_empty(
		&mut self,
		address: H160,
	) -> bool {
		// to do get from storage
		self.substate.known_storage_empty(address)
	}

	pub fn is_contract_or_created_account(&mut self, address: H160) -> bool {
        if !self.exist(address) {
            false
        } else {
            self.get_code_length(address) > 0 
                || self.get_nonce(address) > U256::zero() 
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
		index: U256
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
	                None => U256::zero()
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
		address: H160
	) -> Vec<u8> {
		match self.substate.known_code(address) {
	        Some(value) => value,
	        None => vec![]
	    }
	}

	pub fn get_code_length(
		&mut self,
		address: H160
	) -> u64 {
		match self.substate.known_code(address) {
	        Some(value) => value.len() as u64,
	        None => 0
	    }
	}

	pub fn get_code_hash(
		&mut self,
		address: H160
	) -> H256 {
		match self.substate.known_code(address) {
	        Some(value) => {
	            let hash = keccak256(&value);
	            H256::from_slice(&hash)
	        },
	        None => H256::zero()
	    }
	}

	pub fn get_balance(
		&mut self,
		address: H160
	) -> U256 {
		match self.substate.known_balance(address) {
	        Some(value) => value,
	        None => U256::zero()
	    }
	}

	pub fn get_nonce(
		&mut self,
		address: H160
	) -> U256 {
		match self.substate.known_nonce(address) {
	        Some(value) => value,
	        None => U256::zero()
	    }
	}

	pub fn get_storage(
		&mut self,
		address: H160,
		index: U256
	) -> U256 {
		match self.substate.known_storage(address, index) {
	        Some(value) => value,
	        None => U256::zero()
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

#[derive(Default, Debug)]
struct Substate {
    parent: Option<Box<Substate>>,
    balances: BTreeMap<H160, U256>,
    codes: BTreeMap<H160, Vec<u8>>,
    nonces: BTreeMap<H160, U256>,
    storages: BTreeMap<H160, BTreeMap<U256, U256>>,
    origin: BTreeMap<H160, BTreeMap<U256, U256>>,
    transient_storages: BTreeMap<(H160, U256), U256>,
    deletes: BTreeSet<H160>,
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
        }
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
