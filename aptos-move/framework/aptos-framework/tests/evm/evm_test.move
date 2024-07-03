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
        let data = x"3f8390d50000000000000000000000000000000000000000000000000000000000f2f1fe";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x00);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"000000000000000000000000000000000000dead", init_storage(vector[0x10], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"000000000000000000000000000000003f8390d5", init_storage(vector[0x01], vector[0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"000000000000000000000000000000000000dead", x"000000000000000000000000000000003f8390d5", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x00, 0x00, 0x0ba1a9ce0ba1a9ce, 0x00];
        let codes = vector[x"5f35601e1a5f35601f1a90617e57908060f1146084578060f2146072578060f414606157156051575b6010558015604f578060fd14604b578060fe1460495760ff14604657005b5fff5bfe5b5f80fd5b005b605d63bad0beef5f6096565b6028565b50505f808080633f8390d55af46028565b50505f80808080633f8390d55af26028565b50505f80808080633f8390d55af16028565b5d56", x"5f35601d1a600b5f609b565b15602b576160a760195f609b565b14601f57005b602961beef5f609f565b005b60356160a75f609f565b5f355f525f9060025a04908060f1146088578060f21460755760f4146064575b5060015560605f609b565b5f55005b5f915060208261dead8193f45f6055565b505f91506020828061dead8194f25f6055565b505f91506020828061dead8194f15f6055565b5c90565b5d56", x"", x"5f8060208180803560e01c60043581835582525af160015500"];
        let nonce_table = vector[0x01, 0x01, 0x01, 0x01];
        let i = 0;
        let balances = vector::empty<vector<u8>>();
        let nonces = vector::empty<u64>();
        while(i < vector::length(&addresses)) {
            let address = *vector::borrow(&addresses, i);
            let nonce =  *vector::borrow(&nonce_table, i);
            vector::push_back(&mut nonces, nonce);

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