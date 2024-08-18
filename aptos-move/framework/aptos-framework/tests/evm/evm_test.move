#[test_only]
module aptos_framework::evm_test {

    use aptos_framework::evm_for_test::{initialize_for_test, run_test};
    use aptos_framework::account::create_account_for_test;
    use aptos_framework::evm_util::u256_to_data;
    use aptos_std::simple_map;
    use aptos_std::simple_map::SimpleMap;
    use std::vector;


    #[test_only]
    fun init_storage(keys: vector<u256>, values: vector<u256>): SimpleMap<vector<u8>, vector<u8>> {
        let i = 0;
        let len = vector::length(&keys);
        let map = simple_map::new<vector<u8>, vector<u8>>();
        while(i < len) {
            let key = *vector::borrow(&keys, i);
            let value = *vector::borrow(&values, i);
            simple_map::add(&mut map, u256_to_data(key), u256_to_data(value));
            i = i + 1;
        };

        map
    }

    #[test]
    public fun test_run() {
        let aptos_framework = create_account_for_test(@0x1);
        initialize_for_test(&aptos_framework);

        let from = x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        let to = x"1000000000000000000000000000000000000000";
        let data = x"0000000000000000000000002000000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x989680),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x061a80);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x01);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"1000000000000000000000000000000000000000", x"2000000000000000000000000000000000000000", x"2100000000000000000000000000000000000000", x"2200000000000000000000000000000000000000", x"3000000000000000000000000000000000000000", x"3100000000000000000000000000000000000000", x"3200000000000000000000000000000000000000", x"a000000000000000000000000000000000000000", x"a100000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000];
        let codes = vector[x"6020600060006000600060003562055730f2506000513f6001556000513b6002556020600060006000513c6000516003556000600060006000600060005161c350f260045500", x"6020600060006000600073a000000000000000000000000000000000000000620249f0f15060206000f300", x"6020600060006000600073a000000000000000000000000000000000000000620249f0f25060206000f300", x"602060006000600073a000000000000000000000000000000000000000620249f0f45060206000f300", x"6020600060006000600073a100000000000000000000000000000000000000620249f0f15060206000f300", x"6020600060006000600073a1000000000000000000000000000000000000006203d090f25060206000f300", x"602060006000600073a100000000000000000000000000000000000000620249f0f45060206000f300", x"6000600f80601a60003960006000f560005260206000f30000fe6460206020556000526005601bf300", x"6000600f80606060003960006000f56000526001600155600160025560016003556001600455600160055560016006556001600755600160085560016009556001600a556001600b556001600c556001600d556001600e5560206000f30000fe6460206020556000526005601bf300", x""];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
        let i = 0;
        let balances = vector::empty<vector<u8>>();
        let nonces = vector::empty<vector<u8>>();
        while(i < vector::length(&addresses)) {
            let address = *vector::borrow(&addresses, i);
            let nonce =  *vector::borrow(&nonce_table, i);
            vector::push_back(&mut nonces, u256_to_data(nonce));

            let balance = *vector::borrow(&balance_table, i);
            vector::push_back(&mut balances, u256_to_data(balance));

            if(simple_map::contains_key(&storage_maps, &address)) {
                let data = simple_map::borrow(&storage_maps, &address);
                vector::push_back(&mut storage_keys, simple_map::keys(data));
                vector::push_back(&mut storage_values, simple_map::values(data));
            } else {
                vector::push_back(&mut storage_keys, vector::empty<vector<u8>>());
                vector::push_back(&mut storage_values, vector::empty<vector<u8>>());
            };
            i = i + 1;
        };

        run_test(
            addresses,
            codes,
            nonces,
            balances,
            storage_keys,
            storage_values,
            access_addresses,
            access_keys,
            from,
            to,
            data,
            gas_limit,
            gas_price,
            value,
            env,
            tx_type
        );
    }
}