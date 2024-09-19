module aptos_framework::evm_for_test_v2 {
    use aptos_framework::env_for_test::{parse_env, get_base_fee_per_gas};
    use std::vector;
    use aptos_framework::evm_context_v2;
    use aptos_framework::event;
    use aptos_std::debug;
    use aptos_framework::evm_util::to_u256;
    use aptos_framework::evm_storage::AccountStorage;
    #[test_only]
    use aptos_framework::evm_storage;

    const TX_TYPE_NORMAL: u8 = 1;
    const TX_TYPE_1559: u8 = 2;

    #[event]
    struct ExecResultEvent has drop, store {
        state_root: vector<u8>,
        execute_time: u256
    }

    public fun pre_init(addresses: vector<vector<u8>>,
                        codes: vector<vector<u8>>,
                        nonces: vector<vector<u8>>,
                        balances: vector<vector<u8>>,
                        storage_keys: vector<vector<vector<u8>>>,
                        storage_values: vector<vector<vector<u8>>>,
                        access_addresses: vector<vector<u8>>,
                        access_keys: vector<vector<vector<u8>>>): (u64, u64) {

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
                evm_context_v2::set_storage(address, to_u256(key), to_u256(value));
                j = j + 1;
            };
            evm_context_v2::set_account(address, to_u256(*vector::borrow(&balances, i)), *vector::borrow(&codes, i), to_u256(*vector::borrow(&nonces, i)));
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
                evm_context_v2::add_always_warm_slot(contract, to_u256(key));
                j = j + 1;
                access_slot_count = access_slot_count + 1;
            };

            evm_context_v2::add_always_warm_address(contract);

            i = i + 1;
        };

        (access_list_len, access_slot_count)
    }


    fun emit_event(state_root: vector<u8>, execute_time: u256) {
        event::emit(ExecResultEvent {
            state_root,
            execute_time
        });

    }

    public entry fun run_test(addresses: vector<vector<u8>>,
                              codes: vector<vector<u8>>,
                              nonces: vector<vector<u8>>,
                              balances: vector<vector<u8>>,
                              storage_keys: vector<vector<vector<u8>>>,
                              storage_values: vector<vector<vector<u8>>>,
                              access_addresses: vector<vector<u8>>,
                              access_keys: vector<vector<vector<u8>>>,
                              from: vector<u8>,
                              to: vector<u8>,
                              data: vector<u8>,
                              gas_limit_bytes: vector<u8>,
                              gas_price_data: vector<vector<u8>>,
                              value_bytes: vector<u8>,
                              env_data: vector<vector<u8>>,
                              tx_type: u8) {
        let (address_list_address_len, access_list_slot_len) = pre_init(addresses, codes, nonces, balances, storage_keys, storage_values, access_addresses, access_keys);
        let gas_limit = to_u256(gas_limit_bytes);
        let value = to_u256(value_bytes);
        let gas_price;
        let env = parse_env(&env_data);
        let (result, execute_time);
        if(tx_type == TX_TYPE_NORMAL) {
            gas_price = to_u256(*vector::borrow(&gas_price_data, 0));
            (result, execute_time) = evm_context_v2::execute_tx_for_test(env, from, to, value, data, gas_limit, gas_price, 0, 0, address_list_address_len, access_list_slot_len, tx_type);
        } else {
            gas_price = get_base_fee_per_gas(&env) + to_u256(*vector::borrow(&gas_price_data, 1));
            let max_fee_per_gas = to_u256(*vector::borrow(&gas_price_data, 0));
            let max_priority_fee_per_gas = to_u256(*vector::borrow(&gas_price_data, 1));
            gas_price = if(gas_price > max_fee_per_gas) max_fee_per_gas else gas_price;
            (result, execute_time) = evm_context_v2::execute_tx_for_test(env, from, to, value, data, gas_limit, gas_price, max_fee_per_gas, max_priority_fee_per_gas, address_list_address_len, access_list_slot_len, tx_type);
        };

        assert!(result < 300, result);

        let state_root = evm_context_v2::calculate_root();
        // let exec_cost = gas_usage - base_cost;
        debug::print(&state_root);
        debug::print(&execute_time);
        emit_event(state_root, execute_time);
    }

    #[test]
    fun test_storage() {
        let addr = x"123456";
        debug::print(&evm_context_v2::get_balance_storage_for_test<AccountStorage>(addr));
        evm_storage::save_account_balance(addr, 1222);
        debug::print(&evm_context_v2::get_balance_storage_for_test<AccountStorage>(addr));

        debug::print(&evm_context_v2::get_state_storage_for_test<AccountStorage>(addr, 1));
        evm_storage::save_account_state(addr, vector[1], vector[2]);
        debug::print(&evm_context_v2::get_state_storage_for_test<AccountStorage>(addr, 1));
    }
}