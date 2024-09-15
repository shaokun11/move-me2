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
        let to = x"b94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        let data = x"0000000000000000000000004000000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x0f4240),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x0927c0);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x00);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"1000000000000000000000000000000000000000", x"1100000000000000000000000000000000000000", x"2000000000000000000000000000000000000000", x"2200000000000000000000000000000000000000", x"3000000000000000000000000000000000000000", x"3300000000000000000000000000000000000000", x"4000000000000000000000000000000000000000", x"4400000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"b94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"f000000000000000000000000000000000000000", x"f200000000000000000000000000000000000000"];
        let balance_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x056bc75e2d63100000, 0x00, 0x00, 0x00];
        let codes = vector[x"6000600060006000600073f0000000000000000000000000000000000000005af100", x"6000602480601360003960006000f5500000fe6000600060006000600073f0000000000000000000000000000000000000005af1500000", x"6000600060006000600073f0000000000000000000000000000000000000005af200", x"6000602480601360003960006000f5500000fe6000600060006000600073f0000000000000000000000000000000000000005af2500000", x"600060006000600073f0000000000000000000000000000000000000005af4500000", x"6000602280601360003960006000f5500000fe600060006000600073f0000000000000000000000000000000000000005af4500000", x"61010060006000600073f2000000000000000000000000000000000000005afa50600051600a5500", x"6000602980601160003960006000f500fe61010060006000600073f2000000000000000000000000000000000000005afa50600051600a550000", x"", x"600060006000600060006000355af100", x"6000602380601360003960006000f5500000fe30600055303160015532600255336003553460045536600555386006553a6007550000", x"6000602980601160003960006000f500fe3060005230316020523260405233606052346080523660a0523860c0523a60e0526101006000f30000"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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