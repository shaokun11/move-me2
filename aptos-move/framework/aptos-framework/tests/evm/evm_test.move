#[test_only]
module aptos_framework::evm_test {

    use aptos_framework::evm_for_test_v2::run_test;
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

        let from = x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        let to = x"cccccccccccccccccccccccccccccccccccccccc";
        let data = x"693c61390000000000000000000000000000000000000000000000000000000000000002";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0xff112233445566),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0xf000000000);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x0186a0);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0de0b6b3a7640000, 0x00];
        let codes = vector[x"", x"60d560243560043580801561054257806001146104b4578060021461042857806003146103c1578060041461034c57806005146102e55780600614610296578060071461022057806008146101aa57600914610142575b600f81116100a2575b5060008111610089575b60406102008360008060095af16000556102005160015561022051600255005b5b8015610069578060019160600181604401530361008a565b60ff907b48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f60005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000001000000000000000000000060c05263ff000000811660181c60005362ff0000811660101c60015361ff00811660081c600253166003533861005f565b60008051602061054d83398151915260005260008051602061056d8339815191526020526819cde05b616263646560b81b60405260006060526000608052600060a0527b0500000000000000000000000000000001000000000000000000000060c052610056565b507bb736420d9819f695c458357b7a519844d4076b018d0c91c30ec9e2a01960005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000001000000000000000000000060c052610056565b507c0148c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f60005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000001000000000000000000000060c052610056565b5060008051602061054d833981519152600090815260008051602061056d8339815191526020526619cde05b61626360c81b6040526060819052608081905260a052600360d81b60c052610056565b5060008051602061054d83398151915260005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000001000000000000000000000060c052610056565b507b48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f60005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000001000000000000000000000060c052610056565b5060008051602061054d83398151915260005260008051602061056d8339815191526020526619cde05b61626360c81b60405260006060526000608052600060a0527b0300000000000000000000000000000002000000000000000000000060c052610056565b50915060d6917b0c48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d6000527f5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e602052671319cde05b61626360c01b60405260006060526000608052600060a0527a03000000000000000000000000000000010000000000000000000060c052610056565b50915060d4917d0c48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3a6000527ff54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e131960205265cde05b61626360d01b60405260006060526000608052600060a0527c030000000000000000000000000000000100000000000000000000000060c052610056565b506000925061005656fe0000000c48c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e13"];
        let nonce_table = vector[0x00, 0x00];
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