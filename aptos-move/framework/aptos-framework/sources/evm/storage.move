module aptos_framework::evm_storage {
    use aptos_std::simple_map::SimpleMap;
    use aptos_std::simple_map;
    use std::vector;
    use aptos_framework::evm_util::{to_32bit, to_u256};

    struct TestAccount has store, copy, drop {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SimpleMap<u256, u256>
    }

    public fun new_account(contract_addr: vector<u8>, balance: u256, code: vector<u8>, nonce: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        simple_map::add(trie, contract_addr, TestAccount {
            balance,
            code,
            nonce,
            storage: simple_map::new<u256, u256>(),
        })
    }

    public fun exist_account(address: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): bool {
        simple_map::contains_key(trie, &address)
    }

    public fun get_code(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): vector<u8> {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).code
        } else {
            x""
        }
    }

    public fun get_nonce(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).nonce
        } else {
            0
        }
    }

    public fun get_balance(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).balance
        } else {
            0
        }
    }

    public fun get_storage(contract_addr: vector<u8>, key: u256, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(!simple_map::contains_key(trie, &contract_addr)) {
            return 0
        };
        let account = simple_map::borrow(trie, &contract_addr);
        if(simple_map::contains_key(&account.storage, &key)) {
            *simple_map::borrow( &account.storage, &key)
        } else {
            0
        }
    }

    public fun add_nonce(contract_addr: vector<u8>, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account =  simple_map::borrow_mut(trie, &contract_addr);
        account.nonce = account.nonce + 1;
    }

    public fun set_storage(contract_addr: vector<u8>, key: u256, value: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account =  simple_map::borrow_mut(trie, &contract_addr);
        if(value == 0) {
            if(simple_map::contains_key(&mut account.storage, &key)) {
                simple_map::remove(&mut account.storage, &key);
            }
        } else {
            simple_map::upsert(&mut account.storage, key, value);
        };
    }

    public fun exist_contract(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): bool {
        if(exist_account(contract_addr, trie)) {
            let account =  simple_map::borrow(trie, &contract_addr);
            return vector::length(&account.code) > 0
        };

        false
    }

    public fun sub_balance(contract_addr: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account = simple_map::borrow_mut(trie, &contract_addr);
        assert!(account.balance >= amount, 2);
        account.balance = account.balance - amount;
    }

    public fun add_balance(contract_addr: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account = simple_map::borrow_mut(trie, &contract_addr);
        account.balance = account.balance + amount;
    }

    public fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        sub_balance(from, amount, trie);
        if(!exist_account(to, trie) && amount > 0) {
            new_account(to, 0, x"", 0, trie);
        };
        if(amount > 0) {
            add_balance(to, amount, trie);
        };
    }

    public fun pre_init(addresses: vector<vector<u8>>,
                 codes: vector<vector<u8>>,
                 nonces: vector<u64>,
                 balances: vector<vector<u8>>): SimpleMap<vector<u8>, TestAccount> {
        let trie = simple_map::new<vector<u8>, TestAccount>();
        let pre_len = vector::length(&addresses);
        assert!(pre_len == vector::length(&codes), 3);
        let i = 0;
        while(i < pre_len) {
            simple_map::add(&mut trie, to_32bit(*vector::borrow(&addresses, i)), TestAccount {
                balance: to_u256(*vector::borrow(&balances, i)),
                code: *vector::borrow(&codes, i),
                nonce: (*vector::borrow(&nonces, i) as u256),
                storage: simple_map::new<u256, u256>(),
            });
            i = i + 1;
        };
        trie
    }
}

