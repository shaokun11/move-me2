module aptos_framework::evm_global_state {
    use aptos_std::simple_map::SimpleMap;
    use aptos_std::simple_map;

    const GasUsage: u64 = 0;
    const HighestMemoryCost: u64 = 1;


    public fun new_run_state(): SimpleMap<u64, u256> {
        let state = simple_map::new<u64, u256>();
        simple_map::add(&mut state, GasUsage, 21000);
        set_memory_cost(&mut state, 0);
        state
    }

    public fun get_memory_cost(run_state: &SimpleMap<u64, u256>) : u256 {
        *simple_map::borrow(run_state, &HighestMemoryCost)
    }

    public fun set_memory_cost(run_state: &mut SimpleMap<u64, u256>, cost: u256) {
        simple_map::upsert(run_state, HighestMemoryCost, cost);
    }

    public fun add_gas_usage(run_state: &mut SimpleMap<u64, u256>, cost: u256) {
        let current_gas_usage = *simple_map::borrow(run_state, &GasUsage);
        simple_map::upsert(run_state, GasUsage, current_gas_usage + cost);
    }

    public fun get_gas_usage(run_state: &SimpleMap<u64, u256>): u256 {
        *simple_map::borrow(run_state, &GasUsage)
    }
}

