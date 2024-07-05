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
        let data = x"1a8451e60000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000f101";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0xff112233445566),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x02625a00);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x0186a0);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x00,0x01], vector[0x60a7,0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"0000000000000000000000000000000000101157", x"000000000000000000000000000000000010c0de", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x00, 0x00, 0x0de0b6b3a7640000, 0x00];
        let codes = vector[x"600360005200", x"600360005200", x"", x"600435602435600080600080600063deadbeef6101005260008060008060016210115762100000f1508561f10081146100f05761f101811461011c5761f10281146101485761f10381146101745761f10481146101a25761f10581146101ce5761f20081146101fc5761f20181146102285761f20281146102545761f20381146102805761f20481146102ae5761f20581146102da5761f40081146103085761f40281146103305761f404811461035a5761fa0081146103845761fa0281146103ac5761fa0481146103d6576031811461040057603b811461041657603c811461042c57603f811461044a5761045c565b5a955060008060008060008c62100000f1505a945060008060008060008c62100000f1505a935061045c565b5a955060008060008060018c62100000f1505a945060008060008060018c62100000f1505a935061045c565b5a955060008060016000808c62100000f1505a945060008060016000808c62100000f1505a935061045c565b5a95506000806001600060018c62100000f1505a94506000806001600060018c62100000f1505a935061045c565b5a955060016000806000808c62100000f1505a945060016000806000808c62100000f1505a935061045c565b5a95506001600080600060018c62100000f1505a94506001600080600060018c62100000f1505a935061045c565b5a955060008060008060008c62100000f2505a945060008060008060008c62100000f2505a935061045c565b5a955060008060008060018c62100000f2505a945060008060008060018c62100000f2505a935061045c565b5a955060008060016000808c62100000f2505a945060008060016000808c62100000f2505a935061045c565b5a95506000806001600060018c62100000f2505a94506000806001600060018c62100000f2505a935061045c565b5a955060016000806000808c62100000f2505a945060016000806000808c62100000f2505a935061045c565b5a95506001600080600060018c62100000f2505a94506001600080600060018c62100000f2505a935061045c565b5a95506000806000808b62100000f4505a94506000806000808b62100000f4505a935061045c565b5a9550600080600160008b62100000f4505a9450600080600160008b62100000f4505a935061045c565b5a9550600160008060008b62100000f4505a9450600160008060008b62100000f4505a935061045c565b5a95506000806000808b62100000fa505a94506000806000808b62100000fa505a935061045c565b5a9550600080600160008b62100000fa505a9450600080600160008b62100000fa505a935061045c565b5a9550600160008060008b62100000fa505a9450600160008060008b62100000fa505a935061045c565b5a9550873192505a9450873191505a935061045c565b5a9550873b92505a9450873b91505a935061045c565b5a95506101006000808a3c5a94506101006000808a3c5a935061045c565b5a9550873f92505a9450873f91505a93505b50838503838503808214600055808203600155505050505050505050"];
        let nonce_table = vector[0x01, 0x01, 0x00, 0x01];
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