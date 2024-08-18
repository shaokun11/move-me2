use crate::natives::evm_natives::{
    helpers::{bytes_to_h160, move_u256_to_evm_u256, evm_u256_to_move_u256}
};

use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};

use move_core_types::{u256::U256 as move_u256};
use move_vm_runtime::native_functions::NativeFunction;
use smallvec::{smallvec, SmallVec};
use ethers::types::{H160, U256, H256};
use ethers::utils::keccak256;
use ethers::utils::rlp::{RlpStream, Encodable};
use better_any::{Tid, TidAble};
use std::{
    boxed::Box,
    collections::{BTreeMap, BTreeSet},
    vec::Vec,
};
use core::mem;
use std::collections::{VecDeque, HashMap};
use trie;

/// Cached emitted module events.
#[derive(Default, Tid)]
pub struct NativeEvmContext {
    substate: Box<Substate>,
    accessed: BTreeSet<(H160, Option<U256>)>,
}

impl NativeEvmContext {
    pub fn new() -> Self {
        Self {
            substate: Box::new(Substate::new()),
            accessed: BTreeSet::new()
        }
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
    transient_storage: BTreeMap<(H160, U256), U256>,
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
            transient_storage: Default::default(),
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
        if let Some(value) = self.transient_storage.get(&(address, key)) {
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

    pub fn deleted(&self, address: H160) -> bool {
        if self.deletes.contains(&address) {
            true
        } else if let Some(parent) = self.parent.as_ref() {
            parent.deleted(address)
        } else {
            false
        }
    }

    pub fn known_is_cold_address(&self, address: H160, index: Option<U256>) -> bool {
        if self.origin.contains_key(&address) {
            false
        } else if let Some(parent) = self.parent.as_ref() {
            parent.known_is_cold_address(address, index)
        } else {
            true
        }
    }
}

fn is_in_range(address: H160) -> bool {
    let lower_bound = H160::from_low_u64_be(1);  // 0x1
    let upper_bound = H160::from_low_u64_be(16); // 0x10

    address >= lower_bound && address <= upper_bound
}

fn native_set_account(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let nonce = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let code = safely_pop_arg!(args, Vec<u8>);
    let balance = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.codes.insert(address, code);
    ctx.substate.balances.insert(address, balance);
    ctx.substate.nonces.insert(address, nonce);



    Ok(smallvec![])
}


fn native_set_code(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let code = safely_pop_arg!(args, Vec<u8>);
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.codes.insert(address, code);

    Ok(smallvec![])
}

fn native_set_storage(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.storages.entry(address)
            .or_insert_with(BTreeMap::new)
            .insert(index, value);

    Ok(smallvec![])
}

fn native_set_transient_storage (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.transient_storage.insert((address, index), value);

    Ok(smallvec![])
}

fn native_add_balance (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let target = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    if value != U256::zero() {
        let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
        let current_balance = match ctx.substate.known_balance(target) {
            Some(value) => value,
            None => U256::zero()
        };
        ctx.substate.balances.insert(target, current_balance.saturating_add(value)); 
    }

    Ok(smallvec![])
}

fn native_sub_balance (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let target = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    if value != U256::zero() {
        let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
        let current_balance = match ctx.substate.known_balance(target) {
            Some(value) => value,
            None => U256::zero()
        };
        if current_balance < value {
            return Ok(smallvec![Value::bool(false)])
        };
        ctx.substate.balances.insert(target,  current_balance - value); 
    }

    Ok(smallvec![Value::bool(true)])
}

fn native_inc_nonce (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let current_nonce = match ctx.substate.known_nonce(address) {
        Some(value) => value,
        None => U256::zero()
    };
    let new_nonce = current_nonce.saturating_add(U256::from(1));
    ctx.substate.nonces.insert(address, new_nonce);

    Ok(smallvec![])
}

fn native_set_nonce (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let nonce = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.nonces.insert(address, nonce);

    Ok(smallvec![])
}

fn native_add_always_hot_address (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.accessed.insert((address, None));

    Ok(smallvec![])
}

fn native_add_always_hot_slot (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.accessed.insert((address, Some(index)));

    Ok(smallvec![])
}

fn native_add_hot_address (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    ctx.substate.origin.insert(address, BTreeMap::new());

    Ok(smallvec![])
}

fn native_exist (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();

    match ctx.substate.known_exists(address) {
        Some(value) => Ok(smallvec![Value::bool(true), Value::bool(value)]),
        None => Ok(smallvec![Value::bool(false), Value::bool(false)])
    }
}

fn native_storage_empty (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();

    Ok(smallvec![Value::bool(ctx.substate.known_storage_empty(address))])
}

fn native_is_cold_address (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    if is_in_range(address) {
        return Ok(smallvec![Value::bool(false)])
    } 
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let is_cold = !ctx.accessed.contains(&(address, None)) && ctx.substate.known_is_cold_address(address, None);
    if is_cold {
        ctx.substate.origin.insert(address, BTreeMap::new());
    }
    

    Ok(smallvec![Value::bool(is_cold)])
}

fn native_get_transient_storage (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();
    match ctx.substate.known_transient_storage(address, index) {
        Some(value) => Ok(smallvec![Value::u256(evm_u256_to_move_u256(&value))]),
        None => Ok(smallvec![Value::u256(move_u256::zero())])
    }
}

fn native_get_origin (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));

    
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let mut is_cold_slot = !ctx.accessed.contains(&(address, Some(index)));
    let result;

    match ctx.substate.known_origin(address, index) {
        Some(value) => {
            is_cold_slot = false;

            result = evm_u256_to_move_u256(&value);
        },
        None => {
            let value = match ctx.substate.known_storage(address, index) {
                Some(value) => value,
                None => U256::zero()
            };
            ctx.substate.origin.entry(address)
            .or_insert_with(BTreeMap::new)
            .insert(index, value);
            result = evm_u256_to_move_u256(&value);
        }
    }

    Ok(smallvec![Value::bool(is_cold_slot), Value::u256(result)])
}

fn native_get_code (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();
    match ctx.substate.known_code(address) {
        Some(value) => Ok(smallvec![Value::bool(true), Value::vector_u8(value)]),
        None => Ok(smallvec![Value::bool(false), Value::vector_u8(vec![])])
    }
}

fn native_get_balance (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();
    match ctx.substate.known_balance(address) {
        Some(value) => Ok(smallvec![Value::bool(true), Value::u256(evm_u256_to_move_u256(&value))]),
        None => Ok(smallvec![Value::bool(false), Value::u256(move_u256::zero())])
    }
}

fn native_get_nonce (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();
    match ctx.substate.known_nonce(address) {
        Some(value) => Ok(smallvec![Value::bool(true), Value::u256(evm_u256_to_move_u256(&value))]),
        None => Ok(smallvec![Value::bool(false), Value::u256(move_u256::zero())])
    }
}

fn native_get_storage (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let index = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let address = bytes_to_h160(&safely_pop_arg!(args, Vec<u8>));
    let ctx = context.extensions().get::<NativeEvmContext>();
    match ctx.substate.known_storage(address, index) {
        Some(value) => Ok(smallvec![Value::bool(true), Value::u256(evm_u256_to_move_u256(&value))]),
        None => Ok(smallvec![Value::bool(false), Value::u256(move_u256::zero())])
    }
}

fn native_push_substate (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let mut parent = Box::new(Substate::new());
    mem::swap(&mut parent, &mut ctx.substate);
    ctx.substate.parent = Some(parent);

    Ok(smallvec![])
}

fn native_revert_substate (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let mut child = ctx.substate.parent.take().expect("uneven substate pop");
    mem::swap(&mut child, &mut ctx.substate);

    Ok(smallvec![])
}

fn native_commit_substate (
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let ctx = context.extensions_mut().get_mut::<NativeEvmContext>();
    let mut child = ctx.substate.parent.take().expect("uneven substate pop");
    mem::swap(&mut child, &mut ctx.substate);
    for (address, balance) in child.balances {
        ctx.substate.balances.insert(address, balance);
    }
    for (address, code) in child.codes {
        ctx.substate.codes.insert(address, code);
    }
    for (address, nonce) in child.nonces {
        ctx.substate.nonces.insert(address, nonce);
    }
    for (address, inner_map) in child.storages {
        for (key, value) in inner_map {
            ctx.substate.storages.entry(address)
            .or_insert_with(BTreeMap::new)
            .insert(key, value);
        }
    }
    for ((address, key), value) in child.transient_storage {
        ctx.substate.transient_storage.insert((address, key), value);
    }

    for (address, inner_map) in child.origin {
        for (key, value) in inner_map {
            ctx.substate.origin.entry(address)
            .or_insert_with(BTreeMap::new)
            .insert(key, value);
        }
    }

    for address in child.deletes {
        ctx.substate.deletes.insert(address);
    }

    Ok(smallvec![])
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

fn rlp_encode(balance: U256, code: Vec<u8>, nonce: U256, storage_root: H256) -> Vec<u8> {
    let mut stream = RlpStream::new_list(4);
    let code_hash = keccak256(&code).to_vec();
    stream.append(&nonce);
    stream.append(&balance);
    stream.append(&storage_root);
    stream.append(&code_hash);
    stream.out().to_vec()
}

fn native_calculate_root(
    context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    _args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let mut keys: Vec<H160> = Vec::new();

    let ctx = context.extensions().get::<NativeEvmContext>();
    // println!(" storage {:?}", ctx.substate.storages);

    keys.extend(ctx.substate.balances.keys().cloned());
    keys.extend(ctx.substate.codes.keys().cloned());
    keys.extend(ctx.substate.nonces.keys().cloned());
    keys.extend(ctx.substate.storages.keys().cloned());

    keys.sort();
    keys.dedup();

    let mut root_map = HashMap::new();

    for address in keys {
        let balance = match ctx.substate.known_balance(address) {
            Some(value) => value,
            None => U256::zero()
        };

        let nonce = match ctx.substate.known_nonce(address) {
            Some(value) => value,
            None => U256::zero()
        };

        let code = match ctx.substate.known_code(address) {
            Some(value) => value,
            None => vec![]
        };

        let storage_root = match ctx.substate.storages.get(&address) {
            Some(value) => calculate_storage_root(value),
            None => calculate_storage_root(&BTreeMap::new())
        };

        // println!("acconts {:?} {:?} {:?} {:?}", address, balance, nonce, storage_root);

        let hashed_addr = keccak256(&address.to_fixed_bytes());
        root_map.insert(hashed_addr.to_vec(), rlp_encode(balance, code, nonce, storage_root));
    };

    let state_root = trie::build(&root_map).0;
    Ok(smallvec![Value::vector_u8(state_root.to_vec())])
}


/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("exist", native_exist as RawSafeNative),
        ("storage_empty", native_storage_empty as RawSafeNative),
        ("is_cold_address", native_is_cold_address as RawSafeNative),
        ("get_origin", native_get_origin as RawSafeNative),
        ("get_transient_storage", native_get_transient_storage as RawSafeNative),
        ("get_code", native_get_code as RawSafeNative),
        ("get_balance", native_get_balance as RawSafeNative),
        ("get_nonce", native_get_nonce as RawSafeNative),
        ("get_storage", native_get_storage as RawSafeNative),
        ("set_code", native_set_code as RawSafeNative),
        ("set_account", native_set_account as RawSafeNative),
        ("set_storage", native_set_storage as RawSafeNative),
        ("set_transient_storage", native_set_transient_storage as RawSafeNative),
        ("add_balance", native_add_balance as RawSafeNative),
        ("sub_balance", native_sub_balance as RawSafeNative),
        ("inc_nonce", native_inc_nonce as RawSafeNative),
        ("set_nonce", native_set_nonce as RawSafeNative),
        ("add_always_hot_address", native_add_always_hot_address as RawSafeNative),
        ("add_always_hot_slot", native_add_always_hot_slot as RawSafeNative),
        ("add_hot_address", native_add_hot_address as RawSafeNative),
        ("push_substate", native_push_substate as RawSafeNative),
        ("revert_substate", native_revert_substate as RawSafeNative),
        ("commit_substate", native_commit_substate as RawSafeNative),
        ("calculate_root", native_calculate_root as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}