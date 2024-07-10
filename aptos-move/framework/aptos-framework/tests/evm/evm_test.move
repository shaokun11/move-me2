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
        let data = x"048071d3000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000000";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x0100000000),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x900000);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x00);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x10,0x12,0x13,0x14,0x15,0x20,0x21], vector[0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7,0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"00000000000000000000000000000000000060a7", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"6160a760005500", x"", x"60043561010052602435610120526044356101405260046101405114600061014051141761002f5760005061003e565b60218061025061030039610540525b6001610140511461005157600050610060565b60298061027161030039610540525b6002610140511461007357600050610082565b60268061029a61030039610540525b60036101405114610095576000506100a4565b602c806102c061030039610540525b600561014051146100b7576000506100c6565b6028806102ec61030039610540525b600661014051146100d9576000506100e8565b602a8061031461030039610540525b60128061033e61020039610520526001610100511461011757615a17610540516103006000f561060052610126565b610540516103006000f0610600525b586020553d601055600461014051143d1761014357600050610153565b602060006101603e610160516011555b610600513b61056052610560516000610400610600513c61056051610520510360125561040051610200510360135560016101205114610195576000506101ac565b600060006000600060006106005161fffff1610640525b600261012051146101bf576000506101d6565b600060006000600060006106005161fffff2610640525b600361012051146101e9576000506101fe565b60006000600060006106005161fffff4610640525b6004610120511461021157600050610226565b60006000600060006106005161fffffa610640525b58602155600061012051141561023e5760005061024d565b600161064051036014553d6015555b00fe601280600f61020039610200f300fe600060006000600060006160a761fffff100622fffff60002050601280601761020039610200f300fe600060006000600060006160a761fffff10060006000fd601280601461020039610200f300fe600060006000600060006160a761fffff1006160a760005260206000fd601280601a61020039610200f300fe600060006000600060006160a761fffff1006160a760005200601280601661020039610200f300fe600060006000600060006160a761fffff1006160a76000526000ff601280601861020039610200f300fe600060006000600060006160a761fffff100600060006000600060006160a761fffff100"];
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