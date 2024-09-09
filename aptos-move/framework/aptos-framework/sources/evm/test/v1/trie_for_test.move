module aptos_framework::evm_trie_for_test {
    use std::vector;
    use aptos_framework::evm_util::{to_u256};
    use aptos_framework::evm_context;


    struct Log has copy, drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topics: vector<vector<u8>>
    }


    public fun add_checkpoint() {
        evm_context::push_substate();
    }

    // fun get_lastest_checkpoint_mut(trie: &mut Trie): &mut Checkpoint {
    //     let len = vector::length(&trie.context);
    //     vector::borrow_mut(&mut trie.context, len - 1)
    // }
    //
    // fun get_lastest_checkpoint(trie: &Trie): &Checkpoint {
    //     let len = vector::length(&trie.context);
    //     vector::borrow(&trie.context, len - 1)
    // }

    // fun empty_account(): TestAccount {
    //     TestAccount {
    //         balance: 0,
    //         code: x"",
    //         nonce: 0,
    //         storage: btree_map::new()
    //     }
    // }

    // fun load_account_storage(trie: &Trie, contract: u256): TestAccount {
    //     *simple_map::borrow(&trie.storage, &contract)
    // }
    //
    // fun load_account_checkpoint(trie: &Trie, contract: u256) {
    //     if(!evm_context::exist(contract)) {
    //         if(simple_map::contains_key(&trie.storage, &contract)) {
    //             let account = *simple_map::borrow(&trie.storage, &contract);
    //             evm_context::set_account(contract, account.balance, account.code, account.nonce);
    //         } else {
    //             evm_context::set_account(contract, 0, x"", 0);
    //         }
    //     };
    // }
    //
    // fun load_account_checkpoint_mut(trie: &mut Trie, contract: u256): &mut TestAccount {
    //     let len = vector::length(&trie.context);
    //     let checkpoint = &mut vector::borrow_mut(&mut trie.context, len - 1).state;
    //     if(btree_map::contains_key(checkpoint, contract)) {
    //         btree_map::borrow_mut(checkpoint, contract)
    //     } else {
    //         if(!btree_map::contains_key(&trie.storage, contract)) {
    //             new_account(contract, vector::empty(), 0, 0, trie);
    //             return load_account_checkpoint_mut(trie, contract)
    //         };
    //         let account = btree_map::borrow(&mut trie.storage, contract);
    //         btree_map::add(checkpoint, contract, *account);
    //         btree_map::borrow_mut(checkpoint, contract)
    //     }
    // }

    public fun add_log(_contract: vector<u8>, _data: vector<u8>, _topics: vector<vector<u8>>) {
        // let checkpoint = get_lastest_checkpoint_mut(trie);
        // vector::push_back(&mut checkpoint.logs, Log {
        //     contract,
        //     data,
        //     topics
        // });
    }

    public fun get_transient_storage(contract: vector<u8>, key: u256): u256 {
        evm_context::get_transient_storage(contract, key)
    }

    public fun put_transient_storage(contract: vector<u8>, key: u256, value: u256) {
        evm_context::set_transient_storage(contract, key, value)
    }

    public fun set_code(contract: vector<u8>, code: vector<u8>) {
        evm_context::set_code(contract, code);
    }

    public fun set_state(contract: vector<u8>, key: u256, value: u256) {
        evm_context::set_storage(contract, key, value)
    }

    public fun add_nonce(contract: vector<u8>) {
        evm_context::inc_nonce(contract)
    }

    public fun add_balance(contract: vector<u8>, value: u256) {
        evm_context::add_balance(contract, value)
    }

    public fun sub_balance(contract: vector<u8>, value: u256): bool {
        evm_context::sub_balance(contract, value)
    }

    public fun transfer(from: vector<u8>, to: vector<u8>, amount: u256): bool {
        if(amount > 0) {
            let success = sub_balance(from, amount);
            if(success) {
                add_balance(to, amount);
            };
            success
        } else {
            true
        }
    }

    public fun commit_latest_checkpoint() {
        evm_context::commit_substate()
    }

    public fun revert_checkpoint() {
        evm_context::revert_substate()
    }

    public fun new_account(contract: vector<u8>, code: vector<u8>, balance: u256, nonce: u256) {
        if(!exist_account(contract)) {
            evm_context::set_account(contract, balance, code, nonce);
        } else {
            evm_context::set_nonce(contract, 1);
        }
    }

    public fun is_contract_or_created_account(contract: vector<u8>): bool {
        if(!exist_account(contract)) {
            false
        } else {
            get_code_length(contract) > 0 || get_nonce(contract) > 0 || !evm_context::storage_empty(contract)
        }
    }

    public fun exist_contract(contract: vector<u8>): bool {
        if(!exist_account(contract)) {
            false
        } else {
            get_code_length(contract) > 0
        }
    }

    public fun exist_account(address: vector<u8>): bool {
        let (_exist_in_context, exist) = evm_context::exist(address);
        exist
    }

    public fun get_nonce(contract: vector<u8>): u256 {
        let (_exist, nonce) = evm_context::get_nonce(contract);
        nonce
    }

    public fun get_code(contract: vector<u8>): vector<u8> {
        let (_exist, code) = evm_context::get_code(contract);
        code
    }

    public fun get_code_length(contract: vector<u8>): u256 {
        (vector::length(&get_code(contract)) as u256)
    }

    public fun get_balance(contract: vector<u8>): u256 {
        let (_exist, balance) = evm_context::get_balance(contract);
        balance
    }

    public fun get_state(contract: vector<u8>, key: u256): u256 {
        let (_exist, value) = evm_context::get_storage(contract, key);
        value
    }

    public fun pre_init(addresses: vector<vector<u8>>,
                        codes: vector<vector<u8>>,
                        nonces: vector<vector<u8>>,
                        balances: vector<vector<u8>>,
                        storage_keys: vector<vector<vector<u8>>>,
                        storage_values: vector<vector<vector<u8>>>,
                        access_addresses: vector<vector<u8>>,
                        access_keys: vector<vector<vector<u8>>>): (u256, u256) {

        let pre_len = vector::length(&addresses);
        assert!(pre_len == vector::length(&codes), 3);
        assert!(pre_len == vector::length(&storage_keys), 3);
        assert!(pre_len == vector::length(&storage_values), 3);
        let i = 0;
        while(i < pre_len) {
            let key_datas = *vector::borrow(&storage_keys, i);
            let value_datas = *vector::borrow(&storage_values, i);
            let data_len = vector::length(&key_datas);
            assert!(data_len == vector::length(&value_datas), 4);
            let address = *vector::borrow(&addresses, i);

            let j = 0;
            while (j < data_len) {
                let key = *vector::borrow(&key_datas, j);
                let value = *vector::borrow(&value_datas, j);
                evm_context::set_storage(address, to_u256(key), to_u256(value));
                j = j + 1;
            };
            evm_context::set_account(address, to_u256(*vector::borrow(&balances, i)), *vector::borrow(&codes, i), to_u256(*vector::borrow(&nonces, i)));
            i = i + 1;
        };

        i = 0;
        let access_slot_count = 0;
        let access_list_len = vector::length(&access_addresses);
        assert!(access_list_len == vector::length(&access_keys), 3);
        while (i < access_list_len) {
            let access_data = *vector::borrow(&access_keys, i);
            let contract = *vector::borrow(&access_addresses, i);
            let j = 0;
            let data_len = vector::length(&access_data);
            while (j < data_len) {
                let key = *vector::borrow(&access_data, j);
                evm_context::add_always_hot_slot(contract, to_u256(key));
                j = j + 1;
                access_slot_count = access_slot_count + 1;
            };

            evm_context::add_always_hot_address(contract);

            i = i + 1;
        };

        ((access_list_len as u256), access_slot_count)
    }

    // public fun get_storage_copy(trie: &Trie): BTreeMap<TestAccount> {
    //     trie.storage
    // }

    // public fun get_trie_accounts(trie: &Trie): (vector<u256>, vector<TestAccount>) {
    //     to_vec_pair(&trie.storage)
    // }

    public fun save() {
        // let checkpoint = vector::pop_back(&mut trie.context).state;
        // let (keys, values) = btree_map::to_vec_pair(&checkpoint);
        // let i = 0;
        // let len = vector::length(&keys);
        // while(i < len) {
        //     let address = *vector::borrow(&keys, i);
        //     let account = *vector::borrow(&values, i);
        //     btree_map::upsert(&mut trie.storage, address, account);
        //     i = i + 1;
        // };

        // debug::print(trie)
    }

    public fun add_warm_address(address: vector<u8>) {
        evm_context::add_hot_address(address)
    }

    public fun is_cold_address(address: vector<u8>): bool {
        evm_context::is_cold_address(address)
    }

    public fun get_cache(address: vector<u8>,
                         key: u256): (bool, u256) {
        evm_context::get_origin(address, key)
    }
}