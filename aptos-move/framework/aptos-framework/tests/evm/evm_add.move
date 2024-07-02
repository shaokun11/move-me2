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
        // debug::print(&u256_to_data(0x0ba1a9ce0ba1a9ce));
        // let balance = u256_to_data(0x0ba1a9ce0ba1a9ce);


        let aptos_framework = create_account_for_test(@0x1);
        initialize_for_test(&aptos_framework);

        let env = vector[u256_to_data(0x0a),
            x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",
            u256_to_data(0x020000),
            u256_to_data(0x00),
            u256_to_data(0x10000000000000),
            u256_to_data(0x01),
            x"0000000000000000000000000000000000000000000000000000000000020000",
            u256_to_data(0x03e8)];

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());


        let addresses = vector[
            x"a00000000000000000000000000000000000000a",
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"
        ];
        let balance_table = vector[ 0x0de0b6b3a7640000, 0x3635c9adc5dea00000 ];
        let codes = vector[
            x"5f3560e01c8063e2da2eb014602157633f37169214601957005b601f6029565b005b600b5f5d5f80fd5b600a5f5d5f5c5f55630e2da2eb60e41b5f525f80602081803061fffff16002555f5c60015556",
            x""
        ];
        // let nonce_table = vector[
        //     0x00,
        //     0x01
        // ];
        let i = 0;
        let balances = vector::empty<vector<u8>>();
        let nonces = vector::empty<u64>();
        while(i < vector::length(&addresses)) {
            let address = *vector::borrow(&addresses, i);
            vector::push_back(&mut nonces, 0);

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
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"a00000000000000000000000000000000000000a",
            x"3f371692",
            u256_to_data(0x061a80),
            u256_to_data(0x0a + 0x00),
            u256_to_data(0x00),
            env
        );
    }
}