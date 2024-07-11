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
        let data = x"1a8451e600000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0xff112233445566),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x02625a00);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x0186a0);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        vector::push_back(&mut access_addresses, x"cccccccccccccccccccccccccccccccccccccccc");
vector::push_back(&mut access_keys, vector[x"0000000000000000000000000000000000000000000000000000000000000000",x"00000000000000000000000000000000000000000000000000000000000060a7"]);



        let addresses = vector[x"0000000000000000000000000000000000001000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"60006000351461001157600050610018565b6110016020525b60016000351461002a5760005061002f565b326020525b60026000351461004157600050610046565b336020525b6003600035146100585760005061005d565b306020525b60046000351461006f57600050610075565b60016020525b60005160005260006020351461008d576000506100b6565b5a600052602051315060165a60005103036000555a600052602051315060165a60005103036001555b6001602035146100c8576000506100f1565b5a6000526020513b5060165a60005103036000555a6000526020513b5060165a60005103036001555b6002602035146101035760005061012c565b5a6000526020513f5060165a60005103036000555a6000526020513f5060165a60005103036001555b60036020351461013e5760005061017a565b6106a5610100525a600052602060006101006020513c60205a60005103036000555a600052602060006101006020513c60205a60005103036001555b00", x"", x"600435610100526024356101205260406000604061010060006110005af15060005160005560205160015500"];
        let nonce_table = vector[0x00, 0x00, 0x00];
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