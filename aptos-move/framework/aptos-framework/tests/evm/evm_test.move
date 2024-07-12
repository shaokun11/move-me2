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
        let data = x"";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x7fffffffffffffff),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x07a120);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x01);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"1000000000000000000000000000000000000000", x"1000000000000000000000000000000000000001", x"1000000000000000000000000000000000000002", x"1000000000000000000000000000000000000003", x"1000000000000000000000000000000000000004", x"1000000000000000000000000000000000000005", x"1000000000000000000000000000000000000006", x"1000000000000000000000000000000000000007", x"1000000000000000000000000000000000000008", x"1000000000000000000000000000000000000009", x"1000000000000000000000000000000000000010", x"1000000000000000000000000000000000000011", x"1000000000000000000000000000000000000012", x"1000000000000000000000000000000000000013", x"1000000000000000000000000000000000000014", x"1000000000000000000000000000000000000015", x"1000000000000000000000000000000000000016", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff];
        let codes = vector[x"600060006000600060007310000000000000000000000000000000000000016707fffffffffffffff1600155600060006000600060007310000000000000000000000000000000000000026707fffffffffffffff1600255600060006000600060007310000000000000000000000000000000000000036707fffffffffffffff1600355600060006000600060007310000000000000000000000000000000000000046707fffffffffffffff1600455600060006000600060007310000000000000000000000000000000000000056707fffffffffffffff1600555600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600655600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600755600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600855600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600955600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600a55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600b55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600c55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600d55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600e55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff1600f55600060006000600060007310000000000000000000000000000000000000066707fffffffffffffff160105500", x"60006000f300", x"6000630ffffffff300", x"600063fffffffff300", x"600067fffffffffffffffff300", x"60006d0ffffffffffffffffffffffffffff300", x"60007ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff300", x"630fffffff6000f300", x"63ffffffff6000f300", x"67ffffffffffffffff6000f300", x"6d0fffffffffffffffffffffffffff6000f300", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6000f300", x"630fffffff630ffffffff300", x"63ffffffff63fffffffff300", x"67ffffffffffffffff67fffffffffffffffff300", x"6d0fffffffffffffffffffffffffff6d0ffffffffffffffffffffffffffff300", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff300", x""];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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