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
        let to = x"0000000000000000000000000000000000000007";
        let data = x"73ac858c3531a0d29ea7a15dfca264e244056b35816eb2fa5e8b941bb7e03e269017ca7b29556e2c50a4525c68460af5ba912653059274ec9907faed7f4ceacf55ed7b50228e7e26e7113d6751750964de40c9f5bb9f378e19edc3fd6ffd6af7ee7710107f382df318b8e1c707719add3db4b00892ddfba9f3e970c8aa9b41f208c53bf041556585635e6534916c5ec0ba7162ea7979164bb27d007c198e1e50cb945b54a4dca4ac110de1a1d47f43fa61c9a6e916d30c3e89695e77cb0da0bcea3bd98260927c609b5782488c5d7e06f07fc67aa5f1cb3c2d7ee74a4054d94e0108b3c962a00fb567a505e96a974f83567a74b898ddd6136e1e6634e4c85cb37db14f98d0080ac548e092928b6eee8d6863592d990f9298d7040cfa486e4e881b0f19eb06892d2185cc0b295d7f2669f00ac67c30de107cd324610a5af8bb29d11354783888e7b8ba5ab533f959729b6e25886d426bbf4cd00626cffbc0ec6beb6a62ae0d9e7166a6303d22036c2b3d45e88057940ada00938e";
        let env = vector[u256_to_data(0x0a),x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x406fbe7b1f887c),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x4ac88d);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0xf5e5cc4b);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"b94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"c94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x26551a696cacb206, 0x577686e8d1344340, 0x11bae0bb79d6a164];
        let codes = vector[x"", x"62f46a4f547b169c9edf92f4b39273fe47accc75d1209ae58463c2585607ce051ff6714c4f0fbf6de0659784434fb240652ff52d08576408f168a43a6651f765a4788a05537086290691d5a3239db43eefea96b0012ea26534e99e4ba9ee7f92f37fa731707f800683bafb70815757d861ad8cc6804154ce5b9de3146b58cd53", x""];
        let nonce_table = vector[0x00, 0x70, 0xa3];
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