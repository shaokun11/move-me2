module aptos_framework::evm_cache {
    use aptos_std::simple_map::SimpleMap;
    use aptos_std::simple_map;
    use aptos_framework::evm_storage::{TestAccount, get_storage};

    public fun new_cache(): SimpleMap<vector<u8>, SimpleMap<u256, u256>> {
        simple_map::new<vector<u8>, SimpleMap<u256, u256>>()
    }

    public fun is_cold_address(address: vector<u8>, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>): bool {
        let is_cold = !simple_map::contains_key(cache, &address);
        if(is_cold) {
            let map = simple_map::new<u256, u256>();
            simple_map::upsert(cache, address, map);
        };

        is_cold
    }

    public fun get_cache(address: vector<u8>, key: u256, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>, trie: &SimpleMap<vector<u8>, TestAccount>): (bool, bool, u256) {
        let is_cold_address = false;
        if(simple_map::contains_key(cache, &address)) {
            let storage = simple_map::borrow(cache, &address);
            if(simple_map::contains_key(storage, &key)) {
                return (false, false, *simple_map::borrow(storage, &key))
            }
        } else {
            is_cold_address = true;
        };

        let value = get_storage(address, key, trie);
        put(address, key, value, cache);

        (is_cold_address, true, value)
    }

    fun put(address: vector<u8>, key: u256, value: u256, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>) {
        let map;
        if(!simple_map::contains_key(cache, &address)) {
            map = simple_map::new<u256, u256>();
            simple_map::upsert(cache, address, map);
        } else {
            map = *simple_map::borrow_mut(cache, &address);
        };

        simple_map::upsert(&mut map, key, value);
    }
}

