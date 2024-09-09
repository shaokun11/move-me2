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
        let data = x"5114e2c8000000000000000000000000000000000000000000000000000000000000000a";
        let env = vector[u256_to_data(0x0a),x"2adc25665018aa1fe0e6bc666dac8fc2697ff9ba",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x05f5e100),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x04c4b400);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0x00);
        let tx_type = 1;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        simple_map::add(&mut storage_maps, x"000000000000000000000000000000005d7935df", init_storage(vector[0x02,0x12], vector[0x60a7,0x60a7]
));simple_map::add(&mut storage_maps, x"000000000000000000000000000000007f9317bd", init_storage(vector[0x00], vector[0x60a7]
));simple_map::add(&mut storage_maps, x"00000000000000000000000000000000ca11bacc", init_storage(vector[0x00,0x01], vector[0x60a7,0x60a7]
));
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"00000000000000000000000000000000000057a7", x"000000000000000000000000000000000000add1", x"00000000000000000000000000000000264bb86a", x"000000000000000000000000000000005114e2c8", x"000000000000000000000000000000005d7935df", x"000000000000000000000000000000006e3a7204", x"000000000000000000000000000000007074a486", x"000000000000000000000000000000007f9317bd", x"00000000000000000000000000000000c1c922f1", x"00000000000000000000000000000000c54b5829", x"00000000000000000000000000000000ca11bacc", x"00000000000000000000000000000000ebd141d5", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"cccccccccccccccccccccccccccccccccccccccc"];
        let balance_table = vector[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0ba1a9ce0ba1a9ce, 0x00];
        let codes = vector[x"366012575b600b5f6020565b5f5260205ff35b601c6160a75f6024565b6004565b5c90565b5d56", x"60106001600a5f6012565b015f6016565b005b5c90565b5d56", x"3033146033575b303303600e57005b601b5f35806001555f608d565b5f80808080305af1600255602e60016089565b600355005b603a5f6089565b8015608757604a600182035f608d565b5f80808080305af1156083576001606191035f608d565b5f80808080305af115608357607f60016078816089565b016001608d565b6006565b5f80fd5b005b5c90565b5d56", x"63ca11bacc3314603f575b63ca11bacc3303601657005b60235f35806001555f607f565b5f8080808063ca11bacc5af1600255603a6001607b565b600355005b60465f607b565b80156079576001816060606693605a84607b565b0183607f565b035f607f565b5f8080808063ca11bacc5af1600a575f80fd5b005b5c90565b5d56", x"60205f600181806157a75af16010555f515f555f805260205f80806157a75afa6011555f516001555f805260205f6001816157a75afa6012555f5160025500", x"3033146033575b303303600e57005b601b5f35806001555f606f565b5f80808080305af1600255602e6001606b565b600355005b603a5f606b565b80156069576001816054605a93604e84606b565b0183606f565b035f606f565b5f80808080305af26006575f80fd5b005b5c90565b5d56", x"3033146033575b303303600e57005b601b5f35806001555f608c565b5f80808080305af1600255602e60016088565b600355005b603a5f6088565b8015608657604a600182035f608c565b5f80808080305af2156082576001606191035f608c565b5f808080305af415608257607e60016077816088565b016001608c565b6006565b5f80fd5b005b5c90565b5d56", x"60065f604e565b5f555f8080808061add15af2601155601c5f604e565b6001555f80808061add15af460125560325f604e565b6002555f8080808061add15af160135560495f604e565b600355005b5c9056", x"3033146033575b303303600e57005b601b5f35806001555f606e565b5f80808080305af1600255602e6001606a565b600355005b603a5f606a565b80156068576001816054605a93604e84606a565b0183606e565b035f606e565b5f808080305af46006575f80fd5b005b5c90565b5d56", x"36156081573330036074575b5f3560f81c5f355f5260013603906001908060f1146064578060f21460545760f4146046575b5050333003603b57005b60425f6094565b5f55005b5f918291305af4505f806031565b505f91829182305af2505f806031565b505f91829182305af1505f806031565b607d60015f6098565b600b565b60926001608c5f6094565b015f6098565b005b5c90565b5d56", x"60065f601d565b5f5560106001601d565b6001555f80808080335af1005b5c9056", x"3033146033575b303303600e57005b601b5f35806001555f606f565b5f80808080305af1600255602e6001606b565b600355005b603a5f606b565b80156069576001816054605a93604e84606b565b0183606f565b035f606f565b5f80808080305af16006575f80fd5b005b5c90565b5d56", x"", x"5f8060208180803560e01c60043581835582525af160015500"];
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