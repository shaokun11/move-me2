#[test_only]
module aptos_framework::evm_test {

    use aptos_framework::evm_for_test_v2::run_test;
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

        let from = x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        let to = x"cccccccccccccccccccccccccccccccccccccccc";
        let data = x"693c61390000000000000000000000000000000000000000000000000000000000000004";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x01);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"0000000000000000000000000000000000001000", x"0000000000000000000000000000000000001001", x"0000000000000000000000000000000000001002", x"0000000000000000000000000000000000001003", x"0000000000000000000000000000000000001004", x"0000000000000000000000000000000000001005", x"0000000000000000000000000000000000001006", x"0000000000000000000000000000000000001007", x"0000000000000000000000000000000000001008", x"0000000000000000000000000000000000001009", x"000000000000000000000000000000000000100a", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"600260020a60005500", x"7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0a60005500", x"637fffffff637fffffff0a60005500", x"637fffffff60000a60005500", x"6000637fffffff0a60005500", x"60016101010a60005500", x"61010160010a60005500", x"61010160020a60005500", x"600060000a60005500", x"660100000000000f60020a60005500", x"600f60020a60005500", x"", x"600060006000600060006004356110000162fffffff100"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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