module aptos_framework::evm_trie {
    use std::vector;
    use aptos_std::simple_map::{SimpleMap, to_vec_pair};
    use aptos_std::simple_map;
    use aptos_framework::evm_precompile::is_precompile_address;
    use aptos_framework::evm_storage::{exist_account_storage, load_account_storage, get_state_storage, save_account_storage, save_account_state};
    use aptos_std::debug;

    friend aptos_framework::evm;
    friend aptos_framework::evm_gas;

    struct Trie has drop {
        context: vector<Checkpoint>,
        access_list: SimpleMap<vector<u8>, SimpleMap<u256, bool>>
    }

    struct Log has copy, drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topics: vector<vector<u8>>
    }

    struct AccountContext has copy, drop, store {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SimpleMap<u256, u256>
    }

    struct Checkpoint has copy, drop {
        state: SimpleMap<vector<u8>, AccountContext>,
        transient: SimpleMap<vector<u8>, SimpleMap<u256, u256>>,
        self_destruct: SimpleMap<vector<u8>, bool>,
        origin: SimpleMap<vector<u8>, SimpleMap<u256, u256>>,
        logs: vector<Log>
    }

    public fun init_new_trie(): Trie {
        let trie = Trie {
            context: vector::empty(),
            access_list: simple_map::new()
        };

        vector::push_back(&mut trie.context, Checkpoint {
            state: simple_map::new(),
            self_destruct: simple_map::new(),
            transient: simple_map::new(),
            origin: simple_map::new(),
            logs: vector::empty()
        });

        trie
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

    fun new_account(balance: u256, code: vector<u8>, nonce: u256): AccountContext {
        AccountContext {
            code,
            balance,
            nonce,
            storage: simple_map::new()
        }
    }

    fun load_account_checkpoint(trie: &Trie, contract_addr: &vector<u8>): AccountContext {
        let checkpoint = get_lastest_checkpoint(trie);
        if(simple_map::contains_key(&checkpoint.state, contract_addr)) {
            *simple_map::borrow(&checkpoint.state, contract_addr)
        } else {
            let (balance, code, nonce) = load_account_storage(*contract_addr);
            new_account(balance, code, nonce)
        }
    }

    fun load_account_checkpoint_mut(trie: &mut Trie, contract_addr: &vector<u8>): &mut AccountContext {
        let len = vector::length(&trie.context);
        let checkpoint = &mut vector::borrow_mut(&mut trie.context, len - 1).state;
        if(simple_map::contains_key(checkpoint, contract_addr)) {
            simple_map::borrow_mut(checkpoint, contract_addr)
        } else {
            if(!exist_account_storage(*contract_addr)) {
                create_account(*contract_addr, vector::empty(), 0, 0, trie);
                return load_account_checkpoint_mut(trie, contract_addr)
            };
            let (balance, code, nonce) = load_account_storage(*contract_addr);
            simple_map::add(checkpoint, *contract_addr, new_account(balance, code, nonce));
            simple_map::borrow_mut(checkpoint, contract_addr)
        }
    }

    public(friend) fun add_log(trie: &mut Trie, contract: vector<u8>, data: vector<u8>, topics: vector<vector<u8>>) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        vector::push_back(&mut checkpoint.logs, Log {
            contract,
            data,
            topics
        });
    }

    public fun get_logs(trie: &Trie): vector<Log> {
        let checkpoint = get_lastest_checkpoint(trie);
        checkpoint.logs
    }


    public(friend) fun get_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256): u256{
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

    public(friend) fun put_transient_storage(trie: &mut Trie, contract_addr: vector<u8>, key: u256, value: u256) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!simple_map::contains_key(&checkpoint.transient, &contract_addr)) {
            simple_map::add(&mut checkpoint.transient, contract_addr, simple_map::new())
        };
        let data = simple_map::borrow_mut(&mut checkpoint.transient, &contract_addr);
        simple_map::upsert(data, key, value);
    }

    public(friend) fun set_balance(trie: &mut Trie, contract_addr: vector<u8>, balance: u256) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.balance = balance;
    }

    public(friend) fun set_code(trie: &mut Trie, contract_addr: vector<u8>, code: vector<u8>) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.code = code;
    }

    fun set_nonce(trie: &mut Trie, contract_addr: vector<u8>, nonce: u256) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.nonce = nonce;
    }

    public(friend) fun set_state(contract_addr: vector<u8>, key: u256, value: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        if(value == 0) {
            if(simple_map::contains_key(&mut account.storage, &key)) {
                simple_map::remove(&mut account.storage, &key);
            }
        } else {
            simple_map::upsert(&mut account.storage, key, value);
        };
    }

    public(friend) fun create_account(contract_addr: vector<u8>, code: vector<u8>, balance: u256, nonce: u256, trie: &mut Trie) {
        if(!exist_account(contract_addr, trie)) {
            let checkpoint = get_lastest_checkpoint_mut(trie);
            simple_map::add(&mut checkpoint.state, contract_addr, new_account(balance, code, nonce));
        } else {
            set_nonce(trie, contract_addr, 1);
        }
    }

    public fun remove_account(contract_addr: vector<u8>, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        simple_map::remove(&mut checkpoint.state, &contract_addr);
    }

    public(friend) fun sub_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie): bool {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        if(account.balance >= amount) {
            account.balance = account.balance - amount;
            true
        } else {
            false
        }
    }

    public(friend) fun add_balance(contract_addr: vector<u8>, amount: u256, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.balance = account.balance + amount;
    }

    public(friend) fun add_nonce(contract_addr: vector<u8>, trie: &mut Trie) {
        let account = load_account_checkpoint_mut(trie, &contract_addr);
        account.nonce = account.nonce + 1;
    }

    public(friend) fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: &mut Trie): bool {
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
            let account = load_account_checkpoint(trie, &contract_addr);
            vector::length(&account.code) > 0 || account.nonce > 0 || simple_map::length(&account.storage) > 0
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
        let checkpoint = vector::borrow(&trie.context, len - 1).state;
        if(!simple_map::contains_key(&checkpoint, &address)) {
            return exist_account_storage(address)
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
            get_state_storage(contract_addr, key)
        }
    }

    public fun save(trie: &mut Trie) {
        let checkpoint = vector::pop_back(&mut trie.context).state;
        let (keys, values) = simple_map::to_vec_pair(checkpoint);
        let i = 0;
        let len = vector::length(&keys);
        while(i < len) {
            let address = *vector::borrow(&keys, i);
            let account = *vector::borrow(&values, i);
            save_account_storage(address, account.balance, account.code, account.nonce);
            let (keys, values) = to_vec_pair(account.storage);
            save_account_state(address, keys, values);
            i = i + 1;
        };
    }

    public(friend) fun revert_checkpoint(trie: &mut Trie) {
        vector::pop_back(&mut trie.context);
    }

    public(friend) fun commit_latest_checkpoint(trie: &mut Trie) {
        let new_checkpoint = vector::pop_back(&mut trie.context);
        let old_checkpoint = get_lastest_checkpoint_mut(trie);
        *old_checkpoint = new_checkpoint;
    }

    public(friend) fun add_warm_address(address: vector<u8>, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!simple_map::contains_key(&checkpoint.origin, &address)) {
            simple_map::upsert(&mut checkpoint.origin, address, simple_map::new<u256, u256>());
        }
    }

    public(friend) fun is_cold_address(address: vector<u8>, trie: &mut Trie): bool {
        if(is_precompile_address(address) || is_access_address(address, trie)) {
            return false
        };
        let checkpoint = get_lastest_checkpoint_mut(trie);
        let is_cold = !simple_map::contains_key(&checkpoint.origin, &address);
        if(is_cold) {
            simple_map::add(&mut checkpoint.origin, address, simple_map::new<u256, u256>());
        };

        is_cold
    }

    public fun get_cache(address: vector<u8>,
                         key: u256, trie: &mut Trie): (bool, u256) {
        let is_access_slot = !is_access_slot(address, key, trie);
        let checkpoint = get_lastest_checkpoint(trie);
        if(simple_map::contains_key(&checkpoint.origin, &address)) {
            let storage = simple_map::borrow(&checkpoint.origin, &address);
            if(simple_map::contains_key(storage, &key)) {
                return (false, *simple_map::borrow(storage, &key))
            }
        };

        let value = get_state(address, key, trie);
        put(address, key, value, trie);

        (is_access_slot, value)
    }

    fun put(address: vector<u8>, key: u256, value: u256, trie: &mut Trie) {
        let checkpoint = get_lastest_checkpoint_mut(trie);
        if(!simple_map::contains_key(&checkpoint.origin, &address)) {
            let new_table = simple_map::new<u256, u256>();
            simple_map::add(&mut checkpoint.origin, address, new_table);
        };
        let table = simple_map::borrow_mut(&mut checkpoint.origin, &address);
        simple_map::upsert(table, key, value);
    }

    fun is_access_address(address: vector<u8>, trie: &mut Trie): bool {
        simple_map::contains_key(&trie.access_list, &address)
    }

    fun is_access_slot(address: vector<u8>, key: u256, trie: &Trie): bool {
        if(!simple_map::contains_key(&trie.access_list, &address)) {
            return false
        };

        let data = simple_map::borrow(&trie.access_list, &address);
        simple_map::contains_key(data, &key)
    }

}