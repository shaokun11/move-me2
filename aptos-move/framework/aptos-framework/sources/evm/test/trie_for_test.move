module aptos_framework::evm_trie_for_test {
    use std::vector;
    use aptos_framework::evm_util::{to_u256};
    use aptos_framework::evm_precompile::is_precompile_address;
    use aptos_std::debug;
    use aptos_framework::btree_map::{BTreeMap, is_empty, to_vec_pair};
    use aptos_framework::btree_map;

    struct Trie has drop {
        context: vector<Checkpoint>,
        storage: BTreeMap<TestAccount>,
        access_list: BTreeMap<BTreeMap<bool>>
    }

    struct Log has copy, drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topics: vector<vector<u8>>
    }

    struct Checkpoint has copy, drop {
        state: BTreeMap<TestAccount>,
        transient: BTreeMap<BTreeMap<u256>>,
        self_destruct: BTreeMap<bool>,
        origin: BTreeMap<BTreeMap<u256>>,
        logs: vector<Log>
    }

    struct TestAccount has drop, copy{
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: BTreeMap<u256>
    }

    public fun add_checkpoint(trie: &mut Trie) {
        let len = vector::length(&trie.context);
        let elem = *vector::borrow(&mut trie.context, len - 1);
        vector::push_back(&mut trie.context, elem);
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
            storage: btree_map::new()
        }
    }

    fun load_account_storage(trie: &Trie, contract: u256): TestAccount {
        *btree_map::borrow(&trie.storage, contract)
    }

    fun load_account_checkpoint(trie: &Trie, contract: u256): TestAccount {
        let checkpoint = get_lastest_checkpoint(trie);
        if(btree_map::contains_key(&checkpoint.state, contract)) {
            *btree_map::borrow(&checkpoint.state, contract)
        } else {
            if(btree_map::contains_key(&trie.storage, contract)) {
                *btree_map::borrow(&trie.storage, contract)
            } else {
                empty_account()
            }
        }
    }

    fun load_account_checkpoint_mut(trie: &mut Trie, contract: u256): &mut TestAccount {
        let len = vector::length(&trie.context);
        let checkpoint = &mut vector::borrow_mut(&mut trie.context, len - 1).state;
        if(btree_map::contains_key(checkpoint, contract)) {
            btree_map::borrow_mut(checkpoint, contract)
        } else {
            if(!btree_map::contains_key(&trie.storage, contract)) {
                new_account(contract, vector::empty(), 0, 0, trie);
                return load_account_checkpoint_mut(trie, contract)
            };
            let account = btree_map::borrow(&mut trie.storage, contract);
            btree_map::add(checkpoint, contract, *account);
            btree_map::borrow_mut(checkpoint, contract)
        }
    }

    public fun add_log(trie: &mut Trie, contract: vector<u8>, data: vector<u8>, topics: vector<vector<u8>>) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        vector::push_back(&mut checkpoint.logs, Log {
            contract,
            data,
            topics
        });
    }

    public fun get_transient_storage(trie: &mut Trie, contract: u256, key: u256): u256{
        let checkpoint = get_lastest_checkpoint(trie);
        if(!btree_map::contains_key(&checkpoint.transient, contract)) {
            0
        } else {
            let data = btree_map::borrow(&checkpoint.transient, contract);
            if(!btree_map::contains_key(data, key)) {
                0
            } else {
                *btree_map::borrow(data, key)
            }
        }
    }

    public fun put_transient_storage(trie: &mut Trie, contract: u256, key: u256, value: u256) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!btree_map::contains_key(&checkpoint.transient, contract)) {
            btree_map::add(&mut checkpoint.transient, contract, btree_map::new())
        };
        let data = btree_map::borrow_mut(&mut checkpoint.transient, contract);
        btree_map::upsert(data, key, value);
    }

    public fun set_balance(trie: &mut Trie, contract: u256, balance: u256) {
        let account = load_account_checkpoint_mut(trie, contract);
        account.balance = balance;
    }

    public fun set_code(trie: &mut Trie, contract: u256, code: vector<u8>) {
        let account = load_account_checkpoint_mut(trie, contract);
        account.code = code;
    }

    fun set_nonce(trie: &mut Trie, contract: u256, nonce: u256) {
        let account = load_account_checkpoint_mut(trie, contract);
        account.nonce = nonce;
    }

    public fun set_state(contract: u256, key: u256, value: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract);
        if(value == 0) {
            // if(btree_map::contains_key(&mut account.storage, key)) {
            //     simple_map::remove(&mut account.storage, &key);
            // }
        } else {
            btree_map::upsert(&mut account.storage, key, value);
        };
    }

    public fun new_account(contract: u256, code: vector<u8>, balance: u256, nonce: u256, trie: &mut Trie) {
        if(!exist_account(contract, trie)) {
            let checkpoint = get_lastest_checkpoint_mut(trie);
            btree_map::add(&mut checkpoint.state, contract, TestAccount {
                code,
                balance,
                nonce,
                storage: btree_map::new()
            });
        } else {
            set_nonce(trie, contract, 1);
        }
    }

    public fun sub_balance(contract: u256, amount: u256, trie: &mut Trie): bool {
        let account = load_account_checkpoint_mut(trie, contract);
        debug::print(account);
        if(account.balance >= amount) {
            account.balance = account.balance - amount;
            true
        } else {
            false
        }
    }

    public fun add_balance(contract: u256, amount: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract);
        account.balance = account.balance + amount;
    }

    public fun add_nonce(contract: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, contract);
        account.nonce = account.nonce + 1;
    }


    public fun transfer(from: u256, to: u256, amount: u256, trie: &mut Trie): bool {
        debug::print(&from);
        debug::print(&to);
        debug::print(&amount);
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

    public fun is_contract_or_created_account(contract: u256, trie: &Trie): bool {
        if(!exist_account(contract, trie)) {
            false
        } else {
            let account = load_account_checkpoint(trie, contract);
            vector::length(&account.code) > 0 || account.nonce > 0 || !is_empty(&trie.storage)
        }
    }

    public fun exist_contract(contract: u256, trie: &Trie): bool {
        if(!exist_account(contract, trie)) {
            false
        } else {
            let code = get_code(contract, trie);
            vector::length(&code) > 0
        }
    }

    public fun exist_account(address: u256, trie: &Trie): bool {
        let len = vector::length(&trie.context);
        let checkpoint = vector::borrow(&trie.context, len - 1).state;
        if(!btree_map::contains_key(&checkpoint, address)) {
            return btree_map::contains_key(&trie.storage, address)
        };

        true
    }

    public fun get_nonce(contract: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract);
        account.nonce
    }

    public fun get_code(contract: u256, trie: &Trie): vector<u8> {
        let account = load_account_checkpoint(trie, contract);
        account.code
    }

    public fun get_code_length(contract: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract);
        (vector::length(&account.code) as u256)
    }

    public fun get_balance(contract: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract);
        account.balance
    }

    public fun get_state(contract: u256, key: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, contract);
        if(btree_map::contains_key(&account.storage, key)) {
            *btree_map::borrow(&account.storage, key)
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
            storage: btree_map::new(),
            access_list: btree_map::new()
        };

        let pre_len = vector::length(&addresses);
        assert!(pre_len == vector::length(&codes), 3);
        assert!(pre_len == vector::length(&storage_keys), 3);
        assert!(pre_len == vector::length(&storage_values), 3);
        let i = 0;
        while(i < pre_len) {
            let storage = btree_map::new<u256>();
            let key_datas = *vector::borrow(&storage_keys, i);
            let value_datas = *vector::borrow(&storage_values, i);
            let data_len = vector::length(&key_datas);
            assert!(data_len == vector::length(&value_datas), 4);

            let j = 0;
            while (j < data_len) {
                let key = *vector::borrow(&key_datas, j);
                let value = *vector::borrow(&value_datas, j);
                btree_map::add(&mut storage, to_u256(key), to_u256(value));
                j = j + 1;
            };
            btree_map::add(&mut trie.storage, to_u256(*vector::borrow(&addresses, i)), TestAccount {
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
            let address_u256 = to_u256(*vector::borrow(&access_addresses, i));
            if(!btree_map::contains_key(&trie.access_list, address_u256)) {
                let access = btree_map::new<bool>();
                let j = 0;
                let data_len = vector::length(&access_data);
                while (j < data_len) {
                    let key = *vector::borrow(&access_data, j);
                    btree_map::upsert(&mut access, to_u256(key), true);
                    j = j + 1;
                    access_slot_count = access_slot_count + 1;
                };

                btree_map::add(&mut trie.access_list, address_u256, access);
            } else {
                let j = 0;
                let data_len = vector::length(&access_data);
                let access = btree_map::borrow_mut(&mut trie.access_list, address_u256);
                while (j < data_len) {
                    let key = *vector::borrow(&access_data, j);
                    btree_map::upsert(access, to_u256(key), true);
                    j = j + 1;
                    access_slot_count = access_slot_count + 1;
                };
            };

            i = i + 1;
        };

        vector::push_back(&mut trie.context, Checkpoint {
            state: btree_map::new(),
            self_destruct: btree_map::new(),
            transient: btree_map::new(),
            origin: btree_map::new(),
            logs: vector::empty()
        });
        (trie, (access_list_len as u256), access_slot_count)
    }

    public fun revert_checkpoint(trie: &mut Trie) {
        vector::pop_back(&mut trie.context);
    }

    // public fun get_storage_copy(trie: &Trie): BTreeMap<TestAccount> {
    //     trie.storage
    // }

    public fun get_trie_accounts(trie: &Trie): (vector<u256>, vector<TestAccount>) {
        to_vec_pair(&trie.storage)
    }

    public fun save(trie: &mut Trie) {
        let checkpoint = vector::pop_back(&mut trie.context).state;
        let (keys, values) = btree_map::to_vec_pair(&checkpoint);
        let i = 0;
        let len = vector::length(&keys);
        while(i < len) {
            let address = *vector::borrow(&keys, i);
            let account = *vector::borrow(&values, i);
            btree_map::upsert(&mut trie.storage, address, account);
            i = i + 1;
        };

        debug::print(trie)
    }

    public fun commit_latest_checkpoint(trie: &mut Trie) {
        let new_checkpoint = vector::pop_back(&mut trie.context);
        let old_checkpoint = get_lastest_checkpoint_mut(trie);
        *old_checkpoint = new_checkpoint;
    }

    public fun add_warm_address(address: u256, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!btree_map::contains_key(&checkpoint.origin, address)) {
            btree_map::upsert(&mut checkpoint.origin, address, btree_map::new<u256>());
        }
    }

    fun is_access_address(address: u256, trie: &mut Trie): bool {
        btree_map::contains_key(&trie.access_list, address)
    }

    fun is_access_slot(address: u256, key: u256, trie: &Trie): bool {
        if(!btree_map::contains_key(&trie.access_list, address)) {
            return false
        };

        let data = btree_map::borrow(&trie.access_list, address);
        btree_map::contains_key(data, key)
    }

    public fun is_cold_address(address: u256, trie: &mut Trie): bool {
        if(is_precompile_address(address) || is_access_address(address, trie)) {
            return false
        };
        let checkpoint = get_lastest_checkpoint_mut(trie);
        let is_cold = !btree_map::contains_key(&checkpoint.origin, address);
        if(is_cold) {
            btree_map::add(&mut checkpoint.origin, address, btree_map::new<u256>());
        };

        is_cold
    }

    public fun get_cache(address: u256,
                         key: u256, trie: &mut Trie): (bool, u256) {
        let is_access_slot = !is_access_slot(address, key, trie);
        let checkpoint = get_lastest_checkpoint(trie);
        if(btree_map::contains_key(&checkpoint.origin, address)) {
            let storage = btree_map::borrow(&checkpoint.origin, address);
            if(btree_map::contains_key(storage, key)) {
                return (false, *btree_map::borrow(storage, key))
            }
        };

        let value = get_state(address, key, trie);
        put(address, key, value, trie);

        (is_access_slot, value)
    }

    fun put(address: u256, key: u256, value: u256, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!btree_map::contains_key(&checkpoint.origin, address)) {
            let new_table = btree_map::new<u256>();
            btree_map::add(&mut checkpoint.origin, address, new_table);
        };
        let table = btree_map::borrow_mut(&mut checkpoint.origin, address);
        btree_map::upsert(table, key, value);
    }

}