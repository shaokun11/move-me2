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
        let data = x"02";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x0100000000),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0xf0000000);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x00);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"40f1299359ea754ac29eb2662a1900752bf8275f", init_storage(vector[0x00], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"8af6a7af30d840ba137e8f3f34d54cfb8beba6e2", init_storage(vector[0x00], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x10,0x11,0x12,0x13,0x14,0x15,0x20,0x21,0x22], vector[0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"40f1299359ea754ac29eb2662a1900752bf8275f", x"8af6a7af30d840ba137e8f3f34d54cfb8beba6e2", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"601d60005500", x"601d60005500", x"", x"60f860020a6000350461010052601580610158610300396105405260068061016d61020039610520526001610100511461004957615a17610540516103006000f561060052610058565b610540516103006000f0610600525b586020553d6010556106005160115560006000600060006000738af6a7af30d840ba137e8f3f34d54cfb8beba6e261fffff16106405258602155600161064051036012553d601355600060006000600060007340f1299359ea754ac29eb2662a1900752bf8275f61fffff16106405258602255600161064051036014553d601555738af6a7af30d840ba137e8f3f34d54cfb8beba6e23b6030556030546000610660738af6a7af30d840ba137e8f3f34d54cfb8beba6e23c610660516031557340f1299359ea754ac29eb2662a1900752bf8275f3b60325560325460006106607340f1299359ea754ac29eb2662a1900752bf8275f3c6106605160335500fe600680600f61020039610200f300fe60ff6000550060ff60005500"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00];
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