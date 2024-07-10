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
        let to = x"00000000000000000000000000000000000c0dec";
        let data = x"52c3fd240000000000000000000000000000000000000000000000000000000000000001";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x01),u256_to_data(0x00),u256_to_data(0xb2d05e00),u256_to_data(0x02),x"0000000000000000000000000000000000000000000000000000000000000001",u256_to_data(0x03e7)];
        let gas_limit = u256_to_data(0x17d78400);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x00);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"00000000000000000000000000000000000c0dec", x"00000000000000000000000000000000c0de1006", x"00000000000000000000000000000000c0deffff", x"00000000000000000000000000000020c0de1006", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x1000, 0x1000, 0x1000, 0x1000, 0xe8d4a51001];
        let codes = vector[x"6004356000906002600390600493600593600c90600d96600e90600f9863dead60a7865563dead60a7875563dead60a7885563dead60a7825563dead60a7895563dead60a7855563dead60a7815563dead60a7835563dead60a78a5573d4e7ae083132925a4927c1f5816238ba17b82a00938060001461044c5780600a1461040e57806001146103dc5780600b146103a357806002146103715780600c1461033257806003146102f757806004146102bb578060051461027f5780600d146102435780600e1461020657806006146101d4578060101461019b5780600714610169576011146100ed57600080fd5b60009788808080809b9a819b9a829b73f7fef4b66b1570a057d7d5cec5c58846befa5b5c92615a1760058061049488398680f590555b5a825583808080348782f190555a81540390555a8755349082f190555a81540390555a825583808080348782f190555a81540390555a8755349082f190555a8154039055005b5060009788808080809b9a819b9a829b6000805160206104998339815191529260058061049487398580f09055610123565b5060009788808080809b9a819b9a829b73562d97e3e4d6d3c6e791ea64bb73d820871aa2199284600a8061048a83398180f59055610123565b5060009788808080809b9a819b9a829b60008051602061049983398151915292600a8061048a87398580f09055610123565b5060009788808080809b9a819b9a829b73d70df326038a3c7ca8fac785a99162bfe75ccc469284808080806420c0de100662010000f19055610123565b5060009788808080809b9a819b9a829b73d70df326038a3c7ca8fac785a99162bfe75ccc469284808080806420c0de1006617000f19055610123565b5060009788808080809b9a819b9a829b73b2050fc27ab6d6d42dc0ce6f7c0bf9481a4c3fc392848080808063c0deffff62010000f19055610123565b5060009788808080809b9a819b9a829b73a5a6a95fd9554f15ab6986a57519092be209512592848080808063c0de100662010000f19055610123565b5060009788808080809b9a819b9a829b73a5a6a95fd9554f15ab6986a57519092be209512592848080808063c0de1006617000f19055610123565b5060009788808080809b9a819b9a829b73a13d43586820e5d97a3fd1960625d537c86dc4e79284600665fe60106000f360d01b82528180f59055610123565b5060009788808080809b9a819b9a829b6000805160206104998339815191529260018061048987398580f09055610123565b5060009788808080809b9a819b9a829b73014001fdbede82315f4b8c2a7d45e980a8a4a12e928460068061048383398180f59055610123565b5060009788808080809b9a819b9a829b6000805160206104998339815191529260068061048387398580f09055610123565b5060009788808080809b9a819b9a829b7343255ee039968e0254887fc8c7172736983d878c928460056460006000fd60d81b82528180f59055610123565b5060009788808080809b9a819b9a829b6000805160206104998339815191529260048061047f87398580f0905561012356fe600080fd6160016000f3fe60ef60005360106000f360016000f3000000000000000000000000d4e7ae083132925a4927c1f5816238ba17b82a65", x"600660126000396006600080f060005500fe6160006000f3", x"600560126000396005600080f060005500fe60206000f3", x"60066013600039600060068180f560005500fe6160006000f3", x""];
        let nonce_table = vector[0x00, 0x01, 0xffffffffffffffff, 0x01, 0x00];
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