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
        let data = x"048071d3000000000000000000000000000000000000000000000000000000000000003e00000000000000000000000000000000000000000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x01);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x0100], vector[0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"000000000000000000000000000000000000c0de", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"6101206000f300", x"", x"6000612040526000602435146100175760005061001e565b6000612020525b60016024351461003057600050610037565b6010612020525b60026024351461004957600050610051565b618000612020525b6003602435146100635760005061006d565b6010600003612020525b60046024351461007f57600050610089565b637fffffff612020525b60056024351461009b576000506100a5565b6380000000612020525b6006602435146100b7576000506100c1565b63ffffffff612020525b6007602435146100d3576000506100de565b640100000000612020525b6008602435146100f0576000506100fe565b677fffffffffffffff612020525b6009602435146101105760005061011e565b678000000000000000612020525b600a602435146101305760005061013e565b67ffffffffffffffff612020525b600b602435146101505760005061015f565b68010000000000000000612020525b60006044351461017157600050610178565b6000612060525b60016044351461018a57600050610191565b6010612060525b6002604435146101a3576000506101ab565b618000612060525b6003604435146101bd576000506101c7565b6010600003612060525b6037600435146101d9576000506101e7565b612060516120205161204051375b6039600435146101f957600050610207565b612060516120205161204051395b603c600435146102195760005061022a565b61206051612020516120405161c0de3c5b603e6004351461023c5760005061024a565b6120605161202051612040513e5b61013e6004351461025d5760005061027f565b61010061010060006000600061c0de611000f1506120605161202051612040513e5b60006101005560036024351015610298576000506102a5565b6000516000556020516001555b00"];
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