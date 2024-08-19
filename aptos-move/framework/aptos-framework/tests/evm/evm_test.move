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
        let to = x"095e7baea6a6c7c4c2dfeb977efac326af552d87";
        let data = x"66fd78520a4acd897a6e29cf1b15f576b05a2bc0c18bb93a759d3f5e1ac5d34ba1e261c70b7afd59945da98cc373eac6aa543bae2e6726e3ff03ad2e788dc33f3b736ef736637d8ac680281bb29884e641473063e58e7318f5f4cbade311c02eed1c323c19bba7df4729406464b42ed0cb6d0189be83857fb09713ae69e7d2d472e6d85d23920625c84c39489fc80d272868f40c64cc6cb93ea5741d1918dfc8f61086b1b0637390a1934b637c37ec94877d3ea763b20b9e04fa589f30da18f1565bcf15ad38bc735b9d45b5d963cadd77e9e3db27853e7462a6417a4ac9af38f967a198c6f50deb53634bcbbe9c6a83a7357847acc4f6360fa46e43595a8936969798890170a6874b4e67391c228e9d0a754f68635d505c3f9a8c2555728626e286db52177c2228fb04d4b702bea78df3747d6fa1079394222b8d2a0dfc34ce6d9e5664062fa8977526ced3516147e12a7b9e36f6628dd9efe320bef809146e8fad97d5aedf559bcc15442b1fd347758332cb1d4bb96471a01de009dc175e3eae40d189755a7c1f46c55d3353af6fd0ee638735594b4bb2e6aa99fdbc96508431f421dd770b6379f9b5cbee55423a23c5538390612dc07c752c39f1c87a02777b0fa261dd883d49b2ae5c02c6e81bd0a53ba5d53e12530485664f77811ffaca4c688d18d6122f3a564151676f40f70e45da4fe562355ba17d36458de5f760c8148a11b1fece135e184d2dbf9ecf019d634d8498ae6c6862431f356e1940bc7bb1a252ece1b1605e467f328c79bb45440e29a9444f1948f3737dc02ec2c10862323af3bae0db487768f3aa49fb0967d7eb138302bcb9cedb6b327f4d35a39cf561f1ee73c294825a5de76bd6bf707c5a660e3a417b6ac0586e80ecb6300ea61a618b628d8fcc6c80a37fbfda4e162006259f39441a81fd310c9a323be96b826199149ebdb88ea3e87df96d06c71959b65c4a3e73b50da0a67590625ad154729d9a0a585ba3fc028fc342115f2308566e69cd557f7a7a73474bae3846016f5281b41609a85ee1b4244652d5c1360c9d30fe27dd2d62b415d06a278aafd0816e734b76a3500869747b893809a7c2a185836da26ef253e0a0de429e617a82f8f17f055b1b67fe7366d9a5a491fb47f997937d38e7e8d4cbe8fa227c8b70f8a70e7b667883e393d677c86a9c8ec7144c61cf62e2403893";
        let env = vector[u256_to_data(0x0a),x"945304eb96065b2a98b57a48a06ae28d285a71b5",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x7fffffffffffffff),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x38c2a77b);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x6f33bb2d);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"095e7baea6a6c7c4c2dfeb977efac326af552d87", x"945304eb96065b2a98b57a48a06ae28d285a71b5", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x00, 0x2e, 0x0de0b6b3a7640000];
        let codes = vector[x"7d342beabe599e4bc177fd97d36df48d50650ba6129a9a83d4cf809ec21452357c620167f530c3265be9887f6e5b8186decdc00a6a801e5f56dd8d9d36a4806dbccc299e4bbf46ad577e25b5b1fc76b6999cb23a6a03c4035e36b8494135ee170647395da00b6e0a64c43f3358b8bdcf593c89fb70b865ef153b5195c77959256beb4f932095eb8ac80bc2c050f6f550a362aac77f5c4b197151df039d64b77dca22eb8fd4b8cf50fb85a36f1d909d1919a47fe97de5526726b4a47b866b7b13471056439457cd7cbc5060d978056ff5dd24a1f49e50b9f5924f473b2dc5306d67054ca575d0603e616291a3601460106009601f6338a57ddc73095e7baea6a6c7c4c2dfeb977efac326af552d87630e3319c8f133", x"6000355415600957005b60203560003555", x""];
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