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
        let data = x"048071d3000000000000000000000000000000000000000000000000000000000000003c00000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000003";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = u256_to_data(0x0a);
        let value = u256_to_data(0x01);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x0100], vector[0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));



        let addresses = vector[x"000000000000000000000000000000000000c0de", x"0000000000000000000000000000000000dead01", x"0000000000000000000000000000000000dead02", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x010000, 0x1000, 0x1000, 0x0ba1a9ce0ba1a9ce, 0x0ba1a9ce0ba1a9ce];
        let codes = vector[x"63deadbeef6000526101206000f300", x"600035ff00", x"600035ff00", x"", x"60016024351461001157600050610019565b61c0de612000525b60026024351461002b57600050610032565b6002612000525b6000604435146100445760005061004d565b61200051612040525b60016044351461005f57600050610071565b60a060020a6001026120005101612040525b60026044351461008357600050610095565b60fe60020a6001026120005101612040525b6003604435146100a7576000506100b9565b60ff60020a6001026120005101612040525b6004604435146100cb576000506100dd565b60a060020a6001026120005103612040525b67ff00ff00ff00ff006120205266ff00ff00ff00ff6120605260316004351461010857600050610139565b61200051316120205261204051316120605260016024351461012f57600061208052610138565b62010000612080525b5b603b6004351461014b5760005061017a565b612000513b61202052612040513b6120605260016024351461017257600061208052610179565b600f612080525b5b603c6004351461018c576000506101e0565b60206000612020612000513c60206000612060612040513c6001602435146101b9576000612080526101df565b7f63deadbeef6000526101206000f3000000000000000000000000000000000000612080525b5b603f600435146101f257600050610240565b612000513f61202052612040513f612060526001602435146102195760006120805261023f565b7f85ab232a015279867a1f5b5da4f9688c6c92e555c122e9147f9d13bc53c03e92612080525b5b60f160043514610252576000506102bb565b60206120206020612000600061200051611000f15060206120606020612000600061204051611000f1506001602435146102b0577f9267d3dbed802941483f1afa2a6bc68de5f653128aca9bf1461c5d0a3ad36ed2612080526102ba565b63deadbeef612080525b5b60f2600435146102cd57600050610336565b60206120206020612000600061200051611000f25060206120606020612000600061204051611000f25060016024351461032b577f9267d3dbed802941483f1afa2a6bc68de5f653128aca9bf1461c5d0a3ad36ed261208052610335565b63deadbeef612080525b5b60f460043514610348576000506103ad565b6020612020602061200061200051611000f4506020612060602061200061204051611000f4506001602435146103a2577f9267d3dbed802941483f1afa2a6bc68de5f653128aca9bf1461c5d0a3ad36ed2612080526103ac565b63deadbeef612080525b5b60fa600435146103bf57600050610424565b6020612020602061200061200051611000fa506020612060602061200061204051611000fa50600160243514610419577f9267d3dbed802941483f1afa2a6bc68de5f653128aca9bf1461c5d0a3ad36ed261208052610423565b63deadbeef612080525b5b60ff60043514610436576000506104b6565b61200051316120a052600060006020612000600062dead016310000000f150612000513161202052600060006020612040600062dead026310000000f150612000513161206052612020516120605103612060526120a0516120205103612020526001602435146104ad57611000612080526104b5565b611000612080525b5b61206051612020510360005561208051612020510360015560006101005500"];
        let nonce_table = vector[0x00, 0x00, 0x00, 0x00, 0x00];
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