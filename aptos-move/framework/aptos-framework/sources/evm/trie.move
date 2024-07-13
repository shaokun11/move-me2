module aptos_framework::evm_trie {
    use std::vector;
    use aptos_framework::evm_util::{to_32bit, to_u256};
    use aptos_framework::evm_precompile::is_precompile_address;
    use aptos_std::smart_table;
    use aptos_std::smart_table::{SmartTable, for_each_ref};
    use aptos_std::simple_map::SimpleMap;
    use aptos_std::debug;
    use aptos_std::simple_map;

    struct Trie has drop {
        context: vector<Checkpoint>,
        storage: SmartTable<vector<u8>, TestAccount>,
        access_list: SmartTable<vector<u8>, SmartTable<u256, bool>>
    }

    struct Checkpoint has drop {
        state: SmartTable<vector<u8>, TestAccount>,
        transient: SmartTable<vector<u8>, SmartTable<u256, u256>>,
        self_destruct: SmartTable<vector<u8>, bool>,
        origin: SmartTable<vector<u8>, SmartTable<u256, u256>>,
    }

    struct TestAccount has drop, store {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SmartTable<u256, u256>
    }

    struct TestAccountForRoot has drop, store {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SimpleMap<u256, u256>
    }

    public fun add_checkpoint(trie: &mut Trie) {
        let len = vector::length(&trie.context);
        let old_checkpoint = vector::borrow(&mut trie.context, len - 1);
        let new_checkpoint = Checkpoint {
            state: smart_table::new(),
            self_destruct: smart_table::new(),
            transient: smart_table::new(),
            origin: smart_table::new()
        };

        for_each_ref(&old_checkpoint.state, |k, v| {
            add_account_to_table(&mut new_checkpoint.state, *k, v);
        });

        for_each_ref(&old_checkpoint.self_destruct, |k, v| {
            smart_table::add(&mut new_checkpoint.self_destruct, *k, *v);
        });

        for_each_ref(&old_checkpoint.transient, |k, v| {
            let transient = smart_table::new<u256, u256>();
            copy_table(&mut transient, v);
        });

        for_each_ref(&old_checkpoint.transient, |k, v| {
            let origin = smart_table::new<u256, u256>();
            copy_table(&mut origin, v);
        });

        vector::push_back(&mut trie.context, new_checkpoint);
        // vector::push_back(&mut trie.context, elem);
    }

    fun copy_table<K: copy + drop, V: copy + drop>(table_a: &mut SmartTable<K, V>, table_b: &SmartTable<K, V>) {
        for_each_ref(table_b, |k, v| {
            smart_table::add(table_a, *k, *v);
        });
    }

    public fun get_storage_copy(trie: &Trie): SimpleMap<vector<u8>, TestAccountForRoot> {
        let map = simple_map::new<vector<u8>, TestAccountForRoot>();
        for_each_ref(&trie.storage, |k, v| {
            let account: &TestAccount = v;
            let storage = simple_map::new<u256, u256>();
            for_each_ref(&account.storage, |key, value| {
                simple_map::add(&mut storage, *key, *value);
            });
            simple_map::add(&mut map, *k, TestAccountForRoot {
                nonce: account.nonce,
                balance: account.balance,
                code: account.code,
                storage
            });
        });
        map
    }

    fun get_lastest_checkpoint_mut(trie: &mut Trie): &mut Checkpoint {
        let len = vector::length(&trie.context);
        vector::borrow_mut(&mut trie.context, len - 1)
    }

    fun get_lastest_checkpoint(trie: &Trie): &Checkpoint {
        let len = vector::length(&trie.context);
        vector::borrow(&trie.context, len - 1)
    }

    fun empty_account(): TestAccount {
        TestAccount {
            balance: 0,
            code: x"",
            nonce: 0,
            storage: smart_table::new()
        }
    }

    // fun load_account_storage(trie: &Trie, contract_addr: vector<u8>): &TestAccount {
    //     smart_table::borrow(&trie.storage, contract_addr)
    // }

    fun load_account_checkpoint(trie: &Trie, contract_addr: vector<u8>): &TestAccount {
        let checkpoint = get_lastest_checkpoint(trie);
        if(smart_table::contains(&checkpoint.state, contract_addr)) {
            smart_table::borrow(&checkpoint.state, contract_addr)
        } else {
            smart_table::borrow(&trie.storage, contract_addr)
        }
    }

    fun add_account_to_table(table: &mut SmartTable<vector<u8>, TestAccount>, address: vector<u8>, account: &TestAccount) {
        let storage = smart_table::new<u256, u256>();
        for_each_ref(&account.storage, |key, value| smart_table::add(&mut storage, *key, *value));
        smart_table::upsert(table, address, TestAccount {
            balance: account.balance,
            code: account.code,
            nonce: account.nonce,
            storage,
        });
    }

    fun load_account_checkpoint_mut(trie: &mut Trie, contract_addr: vector<u8>): &mut TestAccount {
        let len = vector::length(&trie.context);
        let checkpoint = vector::borrow_mut(&mut trie.context, len - 1);
        if(smart_table::contains(&checkpoint.state, contract_addr)) {
            smart_table::borrow_mut(&mut checkpoint.state, contract_addr)
        } else {
            if(!smart_table::contains(&trie.storage, contract_addr)) {
                new_account(contract_addr, vector::empty(), 0, 0, trie);
                return load_account_checkpoint_mut(trie, contract_addr)
            };
            let account = smart_table::borrow(&mut trie.storage, contract_addr);
            add_account_to_table(&mut checkpoint.state, contract_addr, account);
            smart_table::borrow_mut(&mut checkpoint.state, contract_addr)
        }
    }

    public fun get_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256): u256{
        let checkpoint = get_lastest_checkpoint(trie);
        if(!smart_table::contains(&checkpoint.transient, contract_addr)) {
            0
        } else {
            let data = smart_table::borrow(&checkpoint.transient, contract_addr);
            if(!smart_table::contains(data, key)) {
                0
            } else {
                *smart_table::borrow(data, key)
            }
        }
    }

    public fun put_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256, value: u256) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!smart_table::contains(&checkpoint.transient, contract_addr)) {
            smart_table::add(&mut checkpoint.transient, contract_addr, smart_table::new())
        };
        let data = smart_table::borrow_mut(&mut checkpoint.transient, contract_addr);
        smart_table::upsert(data, key, value);
    }

    public fun set_balance(trie: &mut Trie, contract_addr: vector<u8>, balance: u256) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.balance = balance;
    }

    public fun set_code(trie: &mut Trie, contract_addr: vector<u8>, code: vector<u8>) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.code = code;
    }

    fun set_nonce(trie: &mut Trie, contract_addr: vector<u8>, nonce: u256) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.nonce = nonce;
    }

    public fun set_state(contract_addr: vector<u8>, key: u256, value: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        if(value == 0) {
            if(smart_table::contains(&mut account.storage, key)) {
                smart_table::remove(&mut account.storage, key);
            }
        } else {
            smart_table::upsert(&mut account.storage, key, value);
        };
    }

    public fun new_account(contract_addr: vector<u8>, code: vector<u8>, balance: u256, nonce: u256, trie: &mut Trie) {
        if(!exist_account(contract_addr, trie)) {
            let checkpoint = get_lastest_checkpoint_mut(trie);
            smart_table::add(&mut checkpoint.state, contract_addr, TestAccount {
                code,
                balance,
                nonce,
                storage: smart_table::new()
            });
        } else {
            set_nonce(trie, contract_addr, 1);
        }
    }

    public fun remove_account(contract_addr: vector<u8>, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        smart_table::remove(&mut checkpoint.state, contract_addr);
    }

    public fun sub_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie): bool {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        if(account.balance >= amount) {
            account.balance = account.balance - amount;
            true
        } else {
            false
        }
    }

    public fun add_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.balance = account.balance + amount;
    }

    public fun add_nonce(contract_addr: vector<u8>, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.nonce = account.nonce + 1;
    }

    public fun clear_storage(contract_addr: vector<u8>, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract_addr);
        account.storage = smart_table::new<u256, u256>();
    }

    public fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: &mut Trie): bool {
        if(amount > 0) {
            let success = sub_balance(from, amount, trie);
            if(success) {
                add_balance(to, amount, trie);
            };
            success
        } else {
            true
        }
    }

    public fun is_contract_or_created_account(contract_addr: vector<u8>, trie: &Trie): bool {
        if(!exist_account(contract_addr, trie)) {
            false
        } else {
            let account = load_account_checkpoint(trie, contract_addr);
            vector::length(&account.code) > 0 || account.nonce > 0 || smart_table::length(&account.storage) > 0
        }
    }

    public fun exist_contract(contract_addr: vector<u8>, trie: &Trie): bool {
        if(!exist_account(contract_addr, trie)) {
            false
        } else {
            let code = get_code(contract_addr, trie);
            vector::length(&code) > 0
        }
    }

    public fun exist_account(address: vector<u8>, trie: &Trie): bool {
        let len = vector::length(&trie.context);
        let checkpoint = vector::borrow(&trie.context, len - 1);
        if(!smart_table::contains(&checkpoint.state, address)) {
            return smart_table::contains(&trie.storage, address)
        };

        true
    }

    public fun get_nonce(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract_addr);
        account.nonce
    }

    public fun get_code(contract_addr: vector<u8>, trie: &Trie): vector<u8> {
        let account = load_account_checkpoint(trie, contract_addr);
        account.code
    }

    public fun get_code_length(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract_addr);
        (vector::length(&account.code) as u256)
    }

    public fun get_balance(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract_addr);
        account.balance
    }

    public fun get_state(contract_addr: vector<u8>, key: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract_addr);
        if(smart_table::contains(&account.storage, key)) {
            *smart_table::borrow(&account.storage, key)
        } else {
            0
        }
    }

    public fun pre_init(addresses: vector<vector<u8>>,
                        codes: vector<vector<u8>>,
                        nonces: vector<vector<u8>>,
                        balances: vector<vector<u8>>,
                        storage_keys: vector<vector<vector<u8>>>,
                        storage_values: vector<vector<vector<u8>>>,
                        access_addresses: vector<vector<u8>>,
                        access_keys: vector<vector<vector<u8>>>): (Trie, u256, u256) {
        let trie = Trie {
            context: vector::empty(),
            storage: smart_table::new(),
            access_list: smart_table::new()
        };

        let pre_len = vector::length(&addresses);
        assert!(pre_len == vector::length(&codes), 3);
        assert!(pre_len == vector::length(&storage_keys), 3);
        assert!(pre_len == vector::length(&storage_values), 3);
        let i = 0;
        while(i < pre_len) {
            let storage = smart_table::new<u256, u256>();
            let key_datas = *vector::borrow(&storage_keys, i);
            let value_datas = *vector::borrow(&storage_values, i);
            let data_len = vector::length(&key_datas);
            assert!(data_len == vector::length(&value_datas), 4);

            let j = 0;
            while (j < data_len) {
                let key = *vector::borrow(&key_datas, j);
                let value = *vector::borrow(&value_datas, j);
                smart_table::add(&mut storage, to_u256(key), to_u256(value));
                j = j + 1;
            };
            smart_table::add(&mut trie.storage, to_32bit(*vector::borrow(&addresses, i)), TestAccount {
                balance: to_u256(*vector::borrow(&balances, i)),
                code: *vector::borrow(&codes, i),
                nonce: to_u256(*vector::borrow(&nonces, i)),
                storage,
            });
            i = i + 1;
        };

        i = 0;
        let access_slot_count = 0;
        let access_list_len = vector::length(&access_addresses);
        assert!(access_list_len == vector::length(&access_keys), 3);
        while (i < access_list_len) {
            let access_data = *vector::borrow(&access_keys, i);
            let address = to_32bit(*vector::borrow(&access_addresses, i));
            if(!smart_table::contains(&trie.access_list, address)) {
                let access = smart_table::new<u256, bool>();
                let j = 0;
                let data_len = vector::length(&access_data);
                while (j < data_len) {
                    let key = *vector::borrow(&access_data, j);
                    smart_table::upsert(&mut access, to_u256(key), true);
                    j = j + 1;
                    access_slot_count = access_slot_count + 1;
                };

                smart_table::add(&mut trie.access_list, address, access);
            } else {
                let j = 0;
                let data_len = vector::length(&access_data);
                let access = smart_table::borrow_mut(&mut trie.access_list, address);
                while (j < data_len) {
                    let key = *vector::borrow(&access_data, j);
                    smart_table::upsert(access, to_u256(key), true);
                    j = j + 1;
                    access_slot_count = access_slot_count + 1;
                };
            };

            i = i + 1;
        };

        vector::push_back(&mut trie.context, Checkpoint {
            state: smart_table::new(),
            self_destruct: smart_table::new(),
            transient: smart_table::new(),
            origin: smart_table::new()
        });
        (trie, (access_list_len as u256), access_slot_count)
    }

    public fun revert_checkpoint(trie: &mut Trie) {
        vector::pop_back(&mut trie.context);
    }

    public fun save(trie: &mut Trie) {
        let checkpoint = vector::pop_back(&mut trie.context);
        for_each_ref(&checkpoint.state, |k, v| {
            add_account_to_table(&mut trie.storage, *k, v)
        });
    }

    public fun commit_latest_checkpoint(trie: &mut Trie) {
        let new_checkpoint = vector::pop_back(&mut trie.context);
        let old_checkpoint = get_lastest_checkpoint_mut(trie);
        *old_checkpoint = new_checkpoint;
    }

    public fun add_warm_address(address: vector<u8>, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!smart_table::contains(&checkpoint.origin, address)) {
            smart_table::upsert(&mut checkpoint.origin, address, smart_table::new<u256, u256>());
        }
    }

    fun is_access_address(address: vector<u8>, trie: &mut Trie): bool {
        smart_table::contains(&trie.access_list, address)
    }

    fun is_access_slot(address: vector<u8>, key: u256, trie: &Trie): bool {
        if(!smart_table::contains(&trie.access_list, address)) {
            return false
        };

        let data = smart_table::borrow(&trie.access_list, address);
        smart_table::contains(data, key)
    }

    public fun is_cold_address(address: vector<u8>, trie: &mut Trie): bool {
        if(is_precompile_address(address) || is_access_address(address, trie)) {
            return false
        };
        let checkpoint = get_lastest_checkpoint_mut(trie);
        let is_cold = !smart_table::contains(&checkpoint.origin, address);
        if(is_cold) {
            smart_table::add(&mut checkpoint.origin, address, smart_table::new<u256, u256>());
        };

        is_cold
    }

    public fun get_cache(address: vector<u8>,
                         key: u256, trie: &mut Trie): (bool, u256) {
        let is_access_slot = !is_access_slot(address, key, trie);
        let checkpoint = get_lastest_checkpoint(trie);
        if(smart_table::contains(&checkpoint.origin, address)) {
            let storage = smart_table::borrow(&checkpoint.origin, address);
            if(smart_table::contains(storage, key)) {
                return (false, *smart_table::borrow(storage, key))
            }
        };

        let value = get_state(address, key, trie);
        put(address, key, value, trie);

        (is_access_slot, value)
    }

    fun put(address: vector<u8>, key: u256, value: u256, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!smart_table::contains(&checkpoint.origin, address)) {
            let new_table = smart_table::new<u256, u256>();
            smart_table::add(&mut checkpoint.origin, address, new_table);
        };
        let table = smart_table::borrow_mut(&mut checkpoint.origin, address);
        smart_table::upsert(table, key, value);
    }

}