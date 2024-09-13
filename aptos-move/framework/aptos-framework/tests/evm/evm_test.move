#[test_only]
module aptos_framework::evm_test {

    use aptos_framework::evm_for_test_v2::run_test;
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

        let from = x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b";
        let to = x"cccccccccccccccccccccccccccccccccccccccc";
        let data = x"693c613900000000000000000000000000000000000000000000000000000060baccfa57";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x10000000000000),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x10000000000000);
        let gas_price = vector[u256_to_data(0x07d0)];
        let value = u256_to_data(0x00);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"0000000000000000000000000000000000060006", init_storage(vector[0x00], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"000000000000000000000000000000000060bacc", init_storage(vector[0x00], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x00], vector[0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"000000000000000000000000000000000000c0de", x"000000000000000000000000000000000000ca11", x"0000000000000000000000000000000000060006", x"000000000000000000000000000000000020c0de", x"000000000000000000000000000000000060bacc", x"00000000000000000000000000000000c0dec0de", x"00000000000000000000000000000000ca1100f1", x"00000000000000000000000000000000ca1100f2", x"00000000000000000000000000000000ca1100f4", x"00000000000000000000000000000000ca1100fa", x"00000000000000000000000000000000deaddead", x"00000000000000000000000000000060baccfa57", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x0de0b6b3a7640000, 0x3635c9adc5dea00000, 0x0de0b6b3a7640000];
        let codes = vector[x"fe", x"fe", x"fe", x"fe", x"fe", x"60006220c0de81813b9283923c6000f3", x"6020600080808061ca115af11560155760206000f35b60206000fd", x"6020600080808061ca115af21560155760206000f35b60206000fd", x"60206000808061ca115af41560145760206000f35b60206000fd", x"60206000808061ca115afa1560145760206000f35b60206000fd", x"6000ff", x"6000358015602d5760019003600052602060008181806460baccfa575af11560275760206000f35b60206000fd5bfe", x"", x"6160a760005260018060043563c0dec0de3b602061c0de3b8315610311578360f1146104cb578360f2146104b5578360f4146104a0578360fa1461048b578361f1f114610473578361f2f11461045b578361f4f114610444578361faf11461042d578361f1f214610415578361f2f2146103fd578361f4f2146103e6578361faf2146103cf578361f1f4146103b7578361f2f41461039f578361f4f414610388578361faf414610371578361f1fa14610359578361f2fa14610341578361f4fa1461032a578361fafa14610313578360fd14610311578360fe14610311578360ff14610311578360f0146102eb578360f5146102c157508261f0f114610297578261f5f11461026b578261f0f214610248578261f5f214610223578261f0f414610201578261f5f4146101dd578261f0fa146101b4578261f5fa146101895750506460baccfa571461016e5765bad0bad0bad06000525b15610168571561016857600051600055005b60206000fd5b506103ff600052602060008181806460baccfa575af1610156565b9150615a17935080925060008263c0dec0de3c670de0b6b3a7640000f5602060008080845afa610156565b819450809350600091925063c0dec0de3c670de0b6b3a7640000f0602060008080845afa610156565b9150615a17935080925060008263c0dec0de3c6000f5602060008080845af4610156565b819450809350600091925063c0dec0de3c6000f0602060008080845af4610156565b9150615a17935080925060008263c0dec0de3c6000f560206000808080855af2610156565b819450809350600091925063c0dec0de3c6000f060206000808080855af2610156565b9150615a17935080925060008263c0dec0de3c670de0b6b3a7640000f560206000808080855af1610156565b819450809350600091925063c0dec0de3c670de0b6b3a7640000f060206000808080855af1610156565b92509050615a179293508160008261c0de3c670de0b6b3a7640000f590602060016000843c610156565b9394509150508160008261c0de3c670de0b6b3a7640000f090602060016000843c610156565bfe5b505050505060206000808063ca1100fa5afa610156565b505050505060206000808063ca1100fa5af4610156565b50505050506020600080808063ca1100fa5af2610156565b50505050506020600080808063ca1100fa5af1610156565b505050505060206000808063ca1100f45afa610156565b505050505060206000808063ca1100f45af4610156565b50505050506020600080808063ca1100f45af2610156565b50505050506020600080808063ca1100f45af1610156565b505050505060206000808063ca1100f25afa610156565b505050505060206000808063ca1100f25af4610156565b50505050506020600080808063ca1100f25af2610156565b50505050506020600080808063ca1100f25af1610156565b505050505060206000808063ca1100f15afa610156565b505050505060206000808063ca1100f15af4610156565b50505050506020600080808063ca1100f15af2610156565b50505050506020600080808063ca1100f15af1610156565b505050505060206000808061ca115afa610156565b505050505060206000808061ca115af4610156565b50505050506020600080808061ca115af2610156565b50505050506020600080808061ca115af161015656"];
        let nonce_table = vector[0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01];
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