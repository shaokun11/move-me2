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
        let to = x"a000000000000000000000000000000000000000";
        let data = x"";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x989680),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x155cc0);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x01);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"a000000000000000000000000000000000000000", x"a100000000000000000000000000000000000000", x"a200000000000000000000000000000000000000", x"a300000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0a, 0x0de0b6b3a7640000];
        let codes = vector[x"60206000600073a2220000000000000000000000000000000000003c60005160105573a2220000000000000000000000000000000000003b60115573a2220000000000000000000000000000000000003f6012556000600060006000600073a22200000000000000000000000000000000000061c350f260135560206000600073a2000000000000000000000000000000000000003c60005160205573a2000000000000000000000000000000000000003b60215573a2000000000000000000000000000000000000003f6022556000600060006000600073a20000000000000000000000000000000000000061c350f260235560206000600073a3000000000000000000000000000000000000003c60005160305573a3000000000000000000000000000000000000003b60315573a3000000000000000000000000000000000000003f6032556000600060006000600073a30000000000000000000000000000000000000061c350f26033556020600060006000600073a10000000000000000000000000000000000000062086470f15060005160405500", x"6000603980601a60003960006000f560005260206000f30000fe60206000600039600051605055303b605155303f605255600060006000600060003061c350f23b605355602060006000303c60005160545500", x"", x"", x""];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00];
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