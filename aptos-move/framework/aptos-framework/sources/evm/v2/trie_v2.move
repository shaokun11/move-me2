module aptos_framework::evm_trie_v2 {
    use std::vector;
    use aptos_framework::evm_util::{to_u256, vector_slice};
    use aptos_framework::evm_context;
    use aptos_framework::evm_storage;
    use aptos_std::debug;
    use aptos_framework::evm_storage::get_state_storage;

    friend aptos_framework::evm;
    friend aptos_framework::evm_gas;

    public(friend) fun add_checkpoint() {
        evm_context::push_substate();
    }

    public fun init_new_trie(access_list_bytes: vector<u8>): (u256, u256) {
        let iter = 0;
        let access_address_count = to_u256(vector_slice(access_list_bytes, iter, 8));
        let i = 0;
        iter = iter + 8;
        let access_slot_count = 0;
        while (i < access_address_count) {
            let address = vector_slice(access_list_bytes, iter, 20);
            iter = iter + 20;
            let key_size = to_u256(vector_slice(access_list_bytes, iter, 8));
            iter = iter + 8;

            let j = 0;
            while(j < key_size) {
                let key = to_u256(vector_slice(access_list_bytes, iter, 32));
                iter = iter + 32;
                evm_context::add_always_hot_slot(address, key);
                j = j + 1;
                access_slot_count = access_slot_count + 1;
            };
            evm_context::add_always_hot_address(address);
            i = i + 1;
        };

        (access_address_count, access_slot_count)
    }

    public(friend) fun get_transient_storage(contract: vector<u8>, key: u256): u256 {
        evm_context::get_transient_storage(contract, key)
    }

    public(friend) fun put_transient_storage(contract: vector<u8>, key: u256, value: u256) {
        evm_context::set_transient_storage(contract, key, value)
    }

    public(friend) fun set_code(contract: vector<u8>, code: vector<u8>) {
        evm_context::set_code(contract, code);
    }

    public(friend) fun set_state(contract: vector<u8>, key: u256, value: u256) {
        evm_context::set_storage(contract, key, value)
    }

    public(friend) fun add_nonce(contract: vector<u8>) {
        get_nonce(contract);
        evm_context::inc_nonce(contract)
    }

    public(friend) fun add_balance(contract: vector<u8>, value: u256) {
        get_balance(contract);
        evm_context::add_balance(contract, value)
    }

    public(friend) fun sub_balance(contract: vector<u8>, value: u256): bool {
        get_balance(contract);
        evm_context::sub_balance(contract, value)
    }

    public(friend) fun set_balance(contract: vector<u8>, value: u256) {
        get_balance(contract);
        evm_context::set_balance(contract, value)
    }

    public(friend) fun transfer(from: vector<u8>, to: vector<u8>, amount: u256): bool {
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

    public(friend) fun commit_latest_checkpoint() {
        evm_context::commit_substate()
    }

    public(friend) fun revert_checkpoint() {
        evm_context::revert_substate()
    }

    public(friend) fun new_account(contract: vector<u8>, code: vector<u8>, balance: u256, nonce: u256) {
        if(!exist_account(contract)) {
            evm_context::set_account(contract, balance, code, nonce);
        } else {
            evm_context::set_nonce(contract, 1);
        }
    }

    public(friend) fun is_contract_or_created_account(contract: vector<u8>): bool {
        if(!exist_account(contract)) {
            false
        } else {
            get_code_length(contract) > 0 || get_nonce(contract) > 0 || !evm_context::storage_empty(contract)
        }
    }

    public(friend) fun exist_contract(contract: vector<u8>): bool {
        if(!exist_account(contract)) {
            false
        } else {
            get_code_length(contract) > 0
        }
    }

    public(friend) fun exist_account(address: vector<u8>): bool {
        let (exist_in_context, exist) = evm_context::exist(address);
        if(!exist_in_context) {
            return evm_storage::exist_account_storage(address)
        };
        exist
    }

    public(friend) fun get_nonce(contract: vector<u8>): u256 {
        let (exist, nonce) = evm_context::get_nonce(contract);
        if(!exist) {
            nonce = evm_storage::get_nonce_storage(contract);
            evm_context::set_nonce(contract, nonce);
        };
        nonce
    }

    public(friend) fun get_code(contract: vector<u8>): vector<u8> {
        let (exist, code) = evm_context::get_code(contract);
        if(!exist) {
            code = evm_storage::get_code_storage(contract);
        };
        code
    }

    public(friend) fun get_code_length(contract: vector<u8>): u256 {
        (vector::length(&get_code(contract)) as u256)
    }

    public(friend) fun get_balance(contract: vector<u8>): u256 {
        let (exist, balance) = evm_context::get_balance(contract);
        if(!exist) {
            balance = evm_storage::get_balance_storage(contract);
            evm_context::set_balance(contract, balance);
        };
        balance
    }

    public(friend) fun get_state(contract: vector<u8>, key: u256): u256 {
        let (exist, value) = evm_context::get_storage(contract, key);
        if(!exist) {
            value = evm_storage::get_state_storage(contract, key);
            evm_context::set_storage(contract, key, value)
        };
        value
    }

    public(friend) fun pre_init(addresses: vector<vector<u8>>,
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

    public(friend) fun save() {
        let (len, address_list, balances) = evm_context::get_balance_change_set();
        let i = 0;
        while(i < len) {
            let address = vector_slice(address_list, 32 * i, 32);
            let balance = *vector::borrow(&balances, i);
            evm_storage::save_account_balance(address, balance);
            i = i + 1;
        };

        let (len, address_list, nonces) = evm_context::get_nonce_change_set();
        let i = 0;
        while(i < len) {
            let address = vector_slice(address_list, 32 * i, 32);
            let nonce = *vector::borrow(&nonces, i);
            evm_storage::save_account_nonce(address, nonce);
            i = i + 1;
        };

        let (len, address_list, code_lengths, code_list) = evm_context::get_code_change_set();
        let i = 0;
        let code_index = 0;
        while(i < len) {
            let address = vector_slice(address_list, 32 * i, 32);

            let code_length = *vector::borrow(&code_lengths, i);
            let code = vector_slice(code_list, code_index, code_length);
            code_index = code_index + code_length;
            evm_storage::save_account_code(address, code);

            i = i + 1;
        };

        let (len, address_list) = evm_context::get_address_change_set();
        let i = 0;
        while(i < len) {
            let address = vector_slice(address_list, 32 * i, 32);
            let (keys, values) = evm_context::get_storage_change_set(address);
            evm_storage::save_account_state(address, keys, values);
            i = i + 1;
        };
    }

    public(friend) fun add_warm_address(address: vector<u8>) {
        evm_context::add_hot_address(address)
    }

    public(friend) fun is_cold_address(address: vector<u8>): bool {
        evm_context::is_cold_address(address)
    }

    public(friend) fun get_cache(address: vector<u8>,
                                 key: u256): (bool, u256) {
        get_state(address, key);
        evm_context::get_origin(address, key)
    }
}