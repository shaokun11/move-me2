// Copyright © Aptos Foundation
// Parts of the project are originally copyright © Meta Platforms, Inc.
// SPDX-License-Identifier: Apache-2.0

//! Support for encoding transactions for common situations.

use crate::account::Account;
use aptos_cached_packages::aptos_framework_sdk_builder;
use aptos_cached_packages::aptos_stdlib;
use aptos_types::transaction::{Script, SignedTransaction};
use ethers::{
    core::{types::transaction, types::TransactionRequest, utils::Anvil},
    middleware::SignerMiddleware,
    providers::{Http, Middleware, Provider},
    signers::{LocalWallet, Signer},
    types::{
        transaction::{eip2718::TypedTransaction, eip712::Eip712},
        Address, Signature, H256, U256,
    },
};
use move_ir_compiler::Compiler;
use once_cell::sync::Lazy;
use std::fs;
use std::fs::File;
use std::fs::OpenOptions;
use std::io::prelude::*;
use std::io::{BufRead, BufReader, Write};
use std::str::FromStr;
pub static EMPTY_SCRIPT: Lazy<Vec<u8>> = Lazy::new(|| {
    let code = "
    main(account: signer) {
    label b0:
      return;
    }
";
    let modules = aptos_cached_packages::head_release_bundle().compiled_modules();
    let compiler = Compiler {
        deps: modules.iter().collect(),
    };
    compiler.into_script_blob(code).expect("Failed to compile")
});

pub fn empty_txn(
    sender: &Account,
    seq_num: u64,
    max_gas_amount: u64,
    gas_unit_price: u64,
) -> SignedTransaction {
    sender
        .transaction()
        .script(Script::new(EMPTY_SCRIPT.to_vec(), vec![], vec![]))
        .sequence_number(seq_num)
        .max_gas_amount(max_gas_amount)
        .gas_unit_price(gas_unit_price)
        .sign()
}

/// Returns a transaction to create a new account with the given arguments.
pub fn create_account_txn(
    sender: &Account,
    new_account: &Account,
    seq_num: u64,
) -> SignedTransaction {
    sender
        .transaction()
        .payload(aptos_stdlib::aptos_account_create_account(
            *new_account.address(),
        ))
        .sequence_number(seq_num)
        .sign()
}

/// Returns a transaction to transfer coin from one account to another (possibly new) one,
/// with the given arguments. Providing 0 as gas_unit_price generates transactions that
/// don't use an aggregator for total supply tracking (due to logic in coin.move that
/// doesn't generate a delta for total supply when gas is 0).
pub fn peer_to_peer_txn(
    sender: &Account,
    receiver: &Account,
    seq_num: u64,
    transfer_amount: u64,
    gas_unit_price: u64,
) -> SignedTransaction {
    // get a SignedTransaction
    sender
        .transaction()
        .payload(aptos_stdlib::aptos_coin_transfer(
            *receiver.address(),
            transfer_amount,
        ))
        .sequence_number(seq_num)
        .gas_unit_price(gas_unit_price)
        .sign()
}

pub fn peer_to_peer_evm_deposit_txn(
    sender: &Account,
    receiver: &Account,
    seq_num: u64,
    amount: u64,
    gas_unit_price: u64,
) -> SignedTransaction {
    let v = amount.to_be_bytes().to_vec();
    let to_addr = receiver.address().to_canonical_string();
    let bytes = to_addr.as_bytes();
    let len = bytes.len();
    // get the last 20 bytes of the address
    let end = len.saturating_sub(20);
    let to = bytes[end..].to_vec();
    // get a SignedTransaction
    sender
        .transaction()
        .payload(aptos_framework_sdk_builder::evm_deposit(to, v))
        .sequence_number(seq_num)
        .gas_unit_price(gas_unit_price)
        .sign()
}

pub fn peer_to_peer_evm_send_txn(
    sender: &Account,
    receiver: &Account,
    seq_num: u64,
    sender_evm_nonce: u64,
    gas_unit_price: u64,
) -> SignedTransaction {
    // let from_str = "0x50b4dd13ad5b34cd60b25470838cdeb61bfc3d3ecdcd356ed35469383ba2b302";
    // let to_str = "0x7a64ad988d27f66ebbe7d5ca3ea3cb49ef02c57d63b79b18f331dad46892fab1";
    // let from = LocalWallet::from_str(from_str).unwrap();
    // let to = LocalWallet::from_str(to_str).unwrap();
    let from = LocalWallet::from_bytes(&sender.privkey.to_bytes()).unwrap();
    let to = LocalWallet::from_bytes(&receiver.privkey.to_bytes()).unwrap();
    let mut file = OpenOptions::new()
        .write(true)
        .create(true)
        .append(true)
        .open("acc.txt")
        .unwrap();
    writeln!(file, "{}", hex::encode(from.address())).unwrap();
    writeln!(file, "{}", hex::encode(to.address())).unwrap();
    let tx = TransactionRequest::new()
        .from(from.address())
        .to(to.address())
        .value(1000000000)
        .gas_price(1000000000)
        .gas(1000000)
        .data(vec![])
        .chain_id(336)
        .nonce(sender_evm_nonce);
    let tx = TypedTransaction::Legacy(tx);
    let signature = from.sign_transaction_sync(&tx).unwrap();
    let bytes = tx.rlp_signed(&signature).to_vec();
    let evm_gas: u64 = 0;
    // get a SignedTransaction
    sender
        .transaction()
        .payload(aptos_framework_sdk_builder::evm_send_tx(
            vec![],
            bytes,
            evm_gas.to_be_bytes().to_vec(),
            1,
        ))
        .sequence_number(seq_num)
        .gas_unit_price(gas_unit_price)
        .sign()
}
