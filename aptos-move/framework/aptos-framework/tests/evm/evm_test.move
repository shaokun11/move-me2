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
        let to = x"000000000000000000000000000000ca1100f022";
        let data = x"756dbf65726963616e207f9439303733373936353331363631303037345a057265737582673075742074650041030a000000efbf7125e86c756dbf65726963616e207f9439303733373936353331363631303037345a0572657375826730757420746500";
        let env = vector[u256_to_data(0x0a),x"b94f5374fce5edbc8e2a8697c15331677e6ebf0b",u256_to_data(0x020000),u256_to_data(0x00),u256_to_data(0x26e1f476fe1e22),u256_to_data(0x01),x"0000000000000000000000000000000000000000000000000000000000020000",u256_to_data(0x03e8)];
        let gas_limit = u256_to_data(0x024174);
        let gas_price = vector[u256_to_data(0x0a)];
        let value = u256_to_data(0xefbf7125);
        let tx_type = 0;

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());
        
        // simple_map::add(&mut storage_maps, x"a00000000000000000000000000000000000000a", init_storage(vector[0x02], vector[0xffff]));

        let access_addresses = vector::empty<vector<u8>>();
        let access_keys = vector::empty<vector<vector<u8>>>();
        


        let addresses = vector[x"000000000000000000000000000000ca1100f022", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b"];
        let balance_table = vector[0x00, 0x3fffffffffffffff];
        let codes = vector[x"7f6c756dbf65726963616e207f9439303733373936353331363631303037345a056000527f7265737582673075742074650041030a000000efbf7125e86c756dbf657269636020527f616e207f9439303733373936353331363631303037345a0572657375826730757f742074650041030a000000efbf7125e86c756dbf65726963616e207f943930377f33373936353331363631303037345a057265737582673075742074650041030a7cefbf7125e86c756dbf65726963616e207f9439303733373936353331367f3631303037345a057265737582673075742074650041030a000000efbf7125e8606c60e053607560e153606d60e25360bf60e353606560e453607260e553606960e653606360e75360e860006000f06000600060006000845a6950507f7f9439303733373936353331363631303037345a05726573758267307574207460005260206000f35b410061943961207f61616e616963616572600563012b9bbff167000000000000015f565b670000000000004ca65661363551613636556136555161363755613675516136385561369551613639556136b55161363a556136d55161363b556136f55161363c556137155161363d556137355161363e556137555161363f55613775516136405561379551613641556137b551613642556137d551613643556137f55161364455613815516136455561383551613646556138555161364755613875516136485561389551613649556138b55161364a556138d55161364b556138f55161364c556139155161364d556139355161364e556139555161364f55613975516136505561399551613651556139b551613652556139d551613653556139f55161365455613a155161365555613a355161365655613a555161365755613a755161365855613a955161365955613ab55161365a55613ad55161365b55613af55161365c00", x""];
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