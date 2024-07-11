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
        let to = x"cccccccccccccccccccccccccccccccccccccccc";
        let data = x"1a8451e600000000000000000000000000000000000000000000000000000000000000f50000000000000000000000000000000000000000000000000000000000000006";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x00);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"0000000000000000000000000000000000000bad", x"000000000000000000000000000000000000600d", x"000000000000000000000000000000000000da7a", x"0000000000000000000000000000000000c0deee", x"0000000000000000000000000000000000c0def0", x"0000000000000000000000000000000000c0def5", x"0000000000000000000000000000000000c0deff", x"13c950f8740ffaea1869a88d70b029e8b0c9a8da", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"bb0237ab04970e3cf3e813c02064662adc89336b", x"cccccccccccccccccccccccccccccccccccccccc", x"f9d1ea8eab6963659ee85b3e0b4d8a57e7edba2b"];
        let balance_table = vector[0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x600d, 0x0ba1a9ce0ba1a9ce, 0x600d, 0x0ba1a9ce0ba1a9ce, 0x600d];
        let codes = vector[x"650bad0bad0bad60005260206000fd", x"61600d60005260206000f3", x"63deadbeef6000526160a760205260406000f3", x"60406101006000808061da7a5af16010553d60115561010051601255610120516013556000803581813b9283923c600080f06000553d6001553d60006102003e610200516002556102205160035500", x"60406101006000808061da7a5af16010553d60115561010051601255610120516013556000803581813b9283923c600080f06000553d6001553d60006102003e610200516002556102205160035500", x"60406101006000808061da7a5af16010553d6011556101005160125561012051601355615a176000803581813b9283923c600080f56000553d6001553d60006102003e610200516002556102205160035500", x"60406101006000808061da7a5af16010553d601155610100516012556101205160135563bad05a176000803581813b9283923c600080f56000553d6001553d60006102003e610200516002556102205160035500", x"600100", x"", x"600100", x"60206102008160008062c0de0060043501602435604061010084808061da7a5af16010553d60115561010051601255610120516013555a90600681146052575b8352f16000553d60015561020051600255005b6201ce809150603f56", x"600100"];
        let nonce_table = vector[0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01];
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
            from,
            to,
            data,
            gas_limit,
            gas_price,
            value,
            env
        );
    }
}