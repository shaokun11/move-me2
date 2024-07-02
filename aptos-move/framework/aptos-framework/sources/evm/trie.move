module aptos_framework::evm_trie {
    use std::vector;
    use aptos_framework::evm_util::{to_32bit, to_u256};
    use aptos_std::simple_map::{SimpleMap};
    use aptos_std::simple_map;
    use aptos_std::debug;

    struct Trie has drop {
        context: vector<Checkpoint>,
        storage: SimpleMap<vector<u8>, TestAccount>,
        origin: SimpleMap<vector<u8>, SimpleMap<u256, u256>>,
    }

    struct Checkpoint has copy, drop {
        state: SimpleMap<vector<u8>, TestAccount>,
        transient: SimpleMap<vector<u8>, SimpleMap<u256, u256>>,
        self_destruct: SimpleMap<vector<u8>, bool>
    }

    struct TestAccount has drop, copy, store {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SimpleMap<u256, u256>
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

    fun load_account_storage(trie: &Trie, contract_addr: vector<u8>): TestAccount {
        *simple_map::borrow(&trie.storage, &contract_addr)
    }

    fun load_account_checkpoint(trie: &Trie, contract_addr: &vector<u8>): &TestAccount {
        let checkpoint = get_lastest_checkpoint(trie);
        if(simple_map::contains_key(&checkpoint.state, contract_addr)) {
            simple_map::borrow(&checkpoint.state, contract_addr)
        } else {
            simple_map::borrow(&trie.storage, contract_addr)
        }
    }

    fun load_account_checkpoint_mut(trie: &mut Trie, contract_addr: &vector<u8>): &mut TestAccount {
        let len = vector::length(&trie.context);
        let checkpoint = &mut vector::borrow_mut(&mut trie.context, len - 1).state;
        if(simple_map::contains_key(checkpoint, contract_addr)) {
            simple_map::borrow_mut(checkpoint, contract_addr)
        } else {
            if(!simple_map::contains_key(&trie.storage, contract_addr)) {
                new_account(*contract_addr, vector::empty(), 0, 0, trie);
                return load_account_checkpoint_mut(trie, contract_addr)
            };
            let account = simple_map::borrow(&mut trie.storage, contract_addr);
            simple_map::add(checkpoint, *contract_addr, *account);
            simple_map::borrow_mut(checkpoint, contract_addr)
        }
    }

    public fun get_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256): u256{
        let checkpoint = get_lastest_checkpoint(trie);
        if(!simple_map::contains_key(&checkpoint.transient, &contract_addr)) {
            0
        } else {
            let data = simple_map::borrow(&checkpoint.transient, &contract_addr);
            if(!simple_map::contains_key(data, &key)) {
                0
            } else {
                *simple_map::borrow(data, &key)
            }
        }
    }

    public fun put_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256, value: u256) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!simple_map::contains_key(&checkpoint.transient, &contract_addr)) {
            simple_map::add(&mut checkpoint.transient, contract_addr, simple_map::new())
        };
        let data = simple_map::borrow_mut(&mut checkpoint.transient, &contract_addr);
        simple_map::upsert(data, key, value);
    }

    fun set_balance(trie: &mut Trie, contract_addr: vector<u8>, balance: u256) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.balance = balance;
    }

    fun set_code(trie: &mut Trie, contract_addr: vector<u8>, code: vector<u8>) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.code = code;
    }

    fun set_nonce(trie: &mut Trie, contract_addr: vector<u8>, nonce: u256) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.nonce = nonce;
    }

    public fun set_state(contract_addr: vector<u8>, key: u256, value: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        if(value == 0) {
            if(simple_map::contains_key(&mut account.storage, &key)) {
                simple_map::remove(&mut account.storage, &key);
            }
        } else {
            simple_map::upsert(&mut account.storage, key, value);
        };
    }

    public fun new_account(contract_addr: vector<u8>, code: vector<u8>, balance: u256, nonce: u256, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        simple_map::add(&mut checkpoint.state, contract_addr, TestAccount {
            code,
            balance,
            nonce,
            storage: simple_map::new()
        });
    }

    public fun sub_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        assert!(account.balance >= amount, 2);
        account.balance = account.balance - amount;
    }

    public fun add_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.balance = account.balance + amount;
    }

    public fun add_nonce(contract_addr: vector<u8>, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.nonce = account.nonce + 1;
    }

    public fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: &mut Trie) {
        if(amount > 0) {
            sub_balance(from, amount, trie);
            add_balance(to, amount, trie);
        };
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
        let checkpoint = vector::borrow(&trie.context, len - 1).state;
        if(!simple_map::contains_key(&checkpoint, &address)) {
            return simple_map::contains_key(&trie.storage, &address)
        };

        true
    }

    public fun get_nonce(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, &contract_addr);
        account.nonce
    }

    public fun get_code(contract_addr: vector<u8>, trie: &Trie): vector<u8> {
        let account = load_account_checkpoint(trie, &contract_addr);
        account.code
    }

    public fun get_code_length(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, &contract_addr);
        (vector::length(&account.code) as u256)
    }

    public fun get_balance(contract_addr: vector<u8>, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, &contract_addr);
        account.balance
    }

    public fun get_state(contract_addr: vector<u8>, key: u256, trie: &Trie): u256 {
        let account = load_account_checkpoint(trie, &contract_addr);
        if(simple_map::contains_key(&account.storage, &key)) {
            *simple_map::borrow(&account.storage, &key)
        } else {
            0
        }
    }

    public fun pre_init(addresses: vector<vector<u8>>,
                        codes: vector<vector<u8>>,
                        nonces: vector<u64>,
                        balances: vector<vector<u8>>,
                        storage_keys: vector<vector<vector<u8>>>,
                        storage_values: vector<vector<vector<u8>>>): Trie {
        let trie = Trie {
            context: vector::empty(),
            storage: simple_map::new(),
            origin: simple_map::new()
        };

        let pre_len = vector::length(&addresses);
        assert!(pre_len == vector::length(&codes), 3);
        assert!(pre_len == vector::length(&storage_keys), 3);
        assert!(pre_len == vector::length(&storage_values), 3);
        let i = 0;
        while(i < pre_len) {
            let storage = simple_map::new<u256, u256>();
            let key_datas = *vector::borrow(&storage_keys, i);
            let value_datas = *vector::borrow(&storage_values, i);
            let data_len = vector::length(&key_datas);
            assert!(data_len == vector::length(&value_datas), 4);

            let j = 0;
            while (j < data_len) {
                let key = *vector::borrow(&key_datas, j);
                let value = *vector::borrow(&value_datas, j);
                simple_map::add(&mut storage, to_u256(key), to_u256(value));
                j = j + 1;
            };
            simple_map::add(&mut trie.storage, to_32bit(*vector::borrow(&addresses, i)), TestAccount {
                balance: to_u256(*vector::borrow(&balances, i)),
                code: *vector::borrow(&codes, i),
                nonce: (*vector::borrow(&nonces, i) as u256),
                storage,
            });
            i = i + 1;
        };
        vector::push_back(&mut trie.context, Checkpoint {
            state: simple_map::new(),
            self_destruct: simple_map::new(),
            transient: simple_map::new()
        });
        trie
    }

    public fun revert_checkpoint(trie: &mut Trie) {
        vector::pop_back(&mut trie.context);
    }

    public fun get_storage_copy(trie: &Trie): SimpleMap<vector<u8>, TestAccount> {
        trie.storage
    }

    public fun save(trie: &mut Trie) {
        let checkpoint = vector::pop_back(&mut trie.context).state;
        let (keys, values) = simple_map::to_vec_pair(checkpoint);
        let i = 0;
        let len = vector::length(&keys);
        while(i < len) {
            let address = *vector::borrow(&keys, i);
            let account = *vector::borrow(&values, i);
            simple_map::upsert(&mut trie.storage, address, account);
            i = i + 1;
        };
    }

    public fun commit_latest_checkpoint(trie: &mut Trie) {
        let new_checkpoint = vector::pop_back(&mut trie.context);
        let old_checkpoint = get_lastest_checkpoint_mut(trie);

        let (keys, values) = simple_map::to_vec_pair(new_checkpoint.state);
        let i = 0;
        let len = vector::length(&keys);
        while(i < len) {
            let address = *vector::borrow(&keys, i);
            let account = *vector::borrow(&values, i);
            simple_map::upsert(&mut old_checkpoint.state, address, account);
            i = i + 1;
        };

        old_checkpoint.transient = new_checkpoint.transient;
    }

    public fun add_warm_address(address: vector<u8>, trie: &mut Trie) {
        simple_map::upsert(&mut trie.origin, address, simple_map::new<u256, u256>());
    }

    public fun is_cold_address(address: vector<u8>, trie: &mut Trie): bool {
        let is_cold = !simple_map::contains_key(&trie.origin, &address);
        if(is_cold) {
            simple_map::add(&mut trie.origin, address, simple_map::new<u256, u256>());
        };

        is_cold
    }

    public fun get_cache(address: vector<u8>,
                         key: u256, trie: &mut Trie): (bool, bool, u256) {
        let is_cold_address = false;
        if(simple_map::contains_key(&trie.origin, &address)) {
            let storage = simple_map::borrow(&trie.origin, &address);
            if(simple_map::contains_key(storage, &key)) {
                return (false, false, *simple_map::borrow(storage, &key))
            }
        } else {
            is_cold_address = true;
        };

        let value = get_state(address, key, trie);
        put(address, key, value, trie);


        (is_cold_address, true, value)
    }

    fun put(address: vector<u8>, key: u256, value: u256, trie: &mut Trie) {

        if(!simple_map::contains_key(&trie.origin, &address)) {
            let new_table = simple_map::new<u256, u256>();
            simple_map::add(&mut trie.origin, address, new_table);
        };
        let table = simple_map::borrow_mut(&mut trie.origin, &address);
        simple_map::upsert(table, key, value);

    }

}