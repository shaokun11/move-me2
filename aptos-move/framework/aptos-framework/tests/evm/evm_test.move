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
        let to = x"b000000000000000000000000000000000000000";
        let data = x"000000000000000000000000ca11003000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"cafe000000000000000000000000000000000001",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x989680),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x3d0900);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x64);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"a000000000000000000000000000000000000000", init_storage(vector[0x00,0x01,0x02], vector[0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf,0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf,0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf]
));simple_map::add(&mut storage_maps, x"b000000000000000000000000000000000000000", init_storage(vector[0x00,0x01,0x02], vector[0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf,0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf,0xdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeafdeadbeaf]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"a000000000000000000000000000000000000000", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"b000000000000000000000000000000000000000", x"ca11001000000000000000000000000000000000", x"ca11002000000000000000000000000000000000", x"ca11003000000000000000000000000000000000", x"ca11004000000000000000000000000000000000", x"ca11005000000000000000000000000000000000", x"ca11006000000000000000000000000000000000", x"ca11007000000000000000000000000000000000", x"ca11008000000000000000000000000000000000"];
        let balance_table = vector[0x03e8, 0x0de0b6b3a7640000, 0x03e8, 0x03e8, 0x03e8, 0x03e8, 0x03e8, 0x03e8, 0x03e8, 0x03e8, 0x03e8];
        let codes = vector[x"7ffeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed60005560006000600060006000355afa6001557ffeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed60025500", x"", x"7ffeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed6000556000356000526000600060206000600073a0000000000000000000000000000000000000005af16001557ffeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeedfeed60025500", x"7f18c547e4f7b0f325ad1e56f57e26c745b09a3e503d86e00e5255ff7f715d3d1c600052601c6020527f73b1693892219d736caba55bdb67216e485557ea6b6af75f37096c9aa6a5a75f6040527feeb940b1d03b21e36b0e47e79769f095fe2ab855bd91e3a38756b7d75a9c4549606052602061200060806000600260015af100", x"7c0ccccccccccccccccccccccccccccccccccccccccccccccccccc000000600052602061200060206000600260025af100", x"7c0ccccccccccccccccccccccccccccccccccccccccccccccccccc000000600052602061200060206000600260035af100", x"7c0ccccccccccccccccccccccccccccccccccccccccccccccccccc000000600052602061200060206000600260045af100", x"6001600052602060205260206040527f03fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc6060527f2efffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc6080527f2f0000000000000000000000000000000000000000000000000000000000000060a052602061200060a16000600260055af100", x"7f0f25929bcb43d5a57391564615c9e70a992b10eafa4db109709649cf48c50dd26000527f16da2f5cb6be7a0aa72c440c53c9bbdfec6c36c7d515536431b3a865468acbba6020527f1de49a4b0233273bba8146af82042d004f2085ec982397db0d97da17204cc2866040527f0217327ffc463919bef80cc166d09c6172639d8589799928761bcd9f22c903d4606052604061200060806000600260065af100", x"7f0f25929bcb43d5a57391564615c9e70a992b10eafa4db109709649cf48c50dd26000527f16da2f5cb6be7a0aa72c440c53c9bbdfec6c36c7d515536431b3a865468acbba6020526003604052604061200060606000600260075af100", x"7f1c76476f4def4bb94541d57ebba1193381ffa7aa76ada664dd31c16024c43f596000527f3034dd2920f673e204fee2811c678745fc819b55d3e9d294e45c9b03a76aef416020527f209dd15ebff5d46c4bd888e51a93cf99a7329636c63514396b4a452003a35bf76040527f04bf11ca01483bfa8b34b43561848d28905960114c8ac04049af4b6315a416786060527f2bb8324af6cfc93537a2ad1a445cfd0ca2a71acd7ac41fadbf933c2a51be344d6080527f120a2a4cf30c1bf9845f20c6fe39e07ea2cce61f0c9bb048165fe5e4de87755060a0527f111e129f1cf1097710d41c4ac70fcdfa5ba2023c6ff1cbeac322de49d1b6df7c60c0527f2032c61a830e3c17286de9462bf242fca2883585b93870a73853face6a6bf41160e0527f198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2610100527f1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed610120527f090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b610140527f12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa6101605260206120006101806000600260085af100"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
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