#[test_only]
module aptos_framework::evm_test {

    use aptos_framework::evm_for_test_v2::run_test;
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
        let to = x"ac00000000000000000000000000000000000000";
        let data = x"000000000000000000000000a200000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x989680),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x01ecf8);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x0a);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"a000000000000000000000000000000000000000", x"a100000000000000000000000000000000000000", x"a200000000000000000000000000000000000000", x"a300000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"ac00000000000000000000000000000000000000", x"b000000000000000000000000000000000000000", x"c000000000000000000000000000000000000000", x"d000000000000000000000000000000000000000"];
        let balance_table = vector[0x00, 0x00, 0x00, 0x00, 0xe8d4a51000, 0x00, 0x00, 0x00, 0x00];
        let codes = vector[x"6000600060006000600073b00000000000000000000000000000000000000061c350f1600a556000600060006000600073c00000000000000000000000000000000000000061c350f1600b556000600060006000600073d00000000000000000000000000000000000000061c350f1600c55600c600455600c60055500", x"6000600060006000600073b00000000000000000000000000000000000000061c350f2600a556000600060006000600073c00000000000000000000000000000000000000061c350f2600b556000600060006000600073d00000000000000000000000000000000000000061c350f2600c55600c600455600c60055500", x"600060006000600073b00000000000000000000000000000000000000061c350f4600a55600060006000600073c00000000000000000000000000000000000000061c350f4600b55600060006000600073d00000000000000000000000000000000000000061c350f4600c55600c600455600c60055500", x"6000600060006000600073b00000000000000000000000000000000000000061c350f1600a55600060006000600073c00000000000000000000000000000000000000061c350f4600b556000600060006000600073d00000000000000000000000000000000000000061c350f2600c55600c600455600c60055500", x"", x"6000600060006000346000356203f7a0f100", x"600c60015560016000fd00", x"600c60025560016000fd00", x"600c60035560016000fd00"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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