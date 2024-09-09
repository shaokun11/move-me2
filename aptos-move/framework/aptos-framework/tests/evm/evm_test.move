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
        let to = x"1000000000000000000000000000000000000000";
        let data = x"000000000000000000000000bbbf5374fce5edbc8e2a8697c15331677e6ebf0b";
        let env = vector[u256_to_data(0x0a),x"b94f5374fce5edbc8e2a8697c15331677e6ebf0b",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x174876e800),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x14f46b0400);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x0a);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"aaaf5374fce5edbc8e2a8697c15331677e6ebf0b", init_storage(vector[0x00], vector[0x01]
));simple_map::add(&mut storage_maps, x"baaf5374fce5edbc8e2a8697c15331677e6ebf0b", init_storage(vector[0x00], vector[0x01]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"1000000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"aaaf5374fce5edbc8e2a8697c15331677e6ebf0b", x"baaf5374fce5edbc8e2a8697c15331677e6ebf0b", x"bbbf5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccf5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x00, 0xffffffffffffffffffffffffffffffff, 0x1b58, 0x1b58, 0x0fffffffffffff, 0x0fffffffffffff];
        let codes = vector[x"6000600060006000346000355af1600055600160015500", x"", x"60005460005200", x"60005460005500", x"5b61c3506080511015603e576000600061c350600073baaf5374fce5edbc8e2a8697c15331677e6ebf0b620186a0fa6000556001608051016080526000565b60805160015500", x"5b61c3506080511015603e576000600061c350600073aaaf5374fce5edbc8e2a8697c15331677e6ebf0b620186a0fa6000556001608051016080526000565b60805160205500"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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