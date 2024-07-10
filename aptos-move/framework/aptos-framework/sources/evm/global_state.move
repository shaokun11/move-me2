module aptos_framework::evm_global_state {
    use std::vector;
    use aptos_framework::evm_util::{to_u256, to_32bit};

    struct Env has drop {
        base_fee: u256,
        coinbase: vector<u8>,
        difficulty: u256,
        excess_blob_gas: u256,
        gas_limit: u256,
        gas_price: u256,
        number: u256,
        random: vector<u8>,
        timestamp: u256,
        sender: vector<u8>
    }

    struct RunState has drop {
        call_state: vector<CallState>,
        env: Env
    }

    struct CallState has drop{
        highest_memory_cost: u256,
        highest_memory_word_size: u256,
        gas_refund: u256,
        gas_left: u256,
        gas_limit: u256
    }

    public fun new_run_state(sender: vector<u8>, gas_price: u256, gas_limit: u256, env_data: &vector<vector<u8>>): RunState {
        let state = RunState {
            call_state: vector::empty(),
            env: parse_env(env_data, sender, gas_price)
        };
        add_call_state(&mut state, gas_limit);
        state
    }

    public fun add_call_state(run_state: &mut RunState, gas_limit: u256) {
        vector::push_back(&mut run_state.call_state, CallState {
            highest_memory_cost: 0,
            highest_memory_word_size: 0,
            gas_refund: 0,
            gas_left: gas_limit,
            gas_limit
        })
    }

    fun get_lastest_state_mut(run_state: &mut RunState): &mut CallState {
        let len = vector::length(&run_state.call_state);
        vector::borrow_mut(&mut run_state.call_state, len - 1)
    }

    fun get_lastest_state(run_state: &RunState): &CallState {
        let len = vector::length(&run_state.call_state);
        vector::borrow(&run_state.call_state, len - 1)
    }

    public fun commit_call_state(run_state: &mut RunState) {
        let new_state = vector::pop_back(&mut run_state.call_state);
        let old_state = get_lastest_state_mut(run_state);
        old_state.gas_refund = old_state.gas_refund + new_state.gas_refund;
        old_state.gas_left = old_state.gas_left - (new_state.gas_limit - new_state.gas_left);
    }

    public fun revert_call_state(run_state: &mut RunState) {
        let new_state = vector::pop_back(&mut run_state.call_state);
        let old_state = get_lastest_state_mut(run_state);
        old_state.gas_left = old_state.gas_left - new_state.gas_limit;
    }

    public fun get_memory_cost(run_state: &RunState) : u256 {
        let state = get_lastest_state(run_state);
        state.highest_memory_cost
    }

    public fun set_memory_cost(run_state: &mut RunState, cost: u256) {
        let state = get_lastest_state_mut(run_state);
        state.highest_memory_cost = cost
    }

    public fun get_memory_word_size(run_state: &RunState) : u256 {
        let state = get_lastest_state(run_state);
        state.highest_memory_word_size
    }

    public fun set_memory_word_size(run_state: &mut RunState, count: u256) {
        let state = get_lastest_state_mut(run_state);
        state.highest_memory_word_size = count
    }

    public fun add_gas_usage(run_state: &mut RunState, cost: u256): bool {
        let state = get_lastest_state_mut(run_state);
        if(state.gas_left < cost) {
            state.gas_left = 0;
            return true
        };
        state.gas_left = state.gas_left - cost;
        return false
    }

    public fun add_gas_left(run_state: &mut RunState, amount: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_left = if(state.gas_left > amount) state.gas_left + amount else 0;
    }

    public fun add_gas_refund(run_state: &mut RunState, refund: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = state.gas_refund + refund;
    }

    public fun sub_gas_refund(run_state: &mut RunState, refund: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = state.gas_refund - refund;
    }

    public fun clear_gas_refund(run_state: &mut RunState) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = 0;
    }

    public fun get_gas_left(run_state: &RunState): u256 {
        let state = get_lastest_state(run_state);
        state.gas_left
    }

    public fun get_gas_refund(run_state: &RunState): u256 {
        let state = get_lastest_state(run_state);
        state.gas_refund
    }

    public fun get_coinbase(run_state: &RunState): vector<u8> {
        run_state.env.coinbase
    }

    public fun get_basefee(run_state: &RunState): u256 {
        run_state.env.base_fee
    }

    public fun get_gas_price(run_state: &RunState): u256 {
        run_state.env.gas_price
    }

    public fun get_gas_limit(run_state: &RunState): u256 {
        run_state.env.gas_limit
    }

    public fun get_timestamp(run_state: &RunState): u256 {
        run_state.env.timestamp
    }

    public fun get_block_number(run_state: &RunState): u256 {
        run_state.env.number
    }

    public fun get_block_difficulty(run_state: &RunState): u256 {
        run_state.env.difficulty
    }

    public fun get_origin(run_state: &RunState): vector<u8> {
        run_state.env.sender
    }

    fun parse_env(env: &vector<vector<u8>>, sender: vector<u8>, gas_price: u256): Env {
        let base_fee = to_u256(*vector::borrow(env, 0));
        let coinbase = to_32bit(*vector::borrow(env, 1));
        let difficulty = to_u256(*vector::borrow(env, 2));
        let excess_blob_gas = to_u256(*vector::borrow(env, 3));
        let gas_limit = to_u256(*vector::borrow(env, 4));
        let number = to_u256(*vector::borrow(env, 5));
        let random = *vector::borrow(env, 6);
        let timestamp = to_u256(*vector::borrow(env, 7));
        Env {
            sender,
            base_fee,
            coinbase,
            difficulty,
            excess_blob_gas,
            gas_limit,
            gas_price,
            number,
            random,
            timestamp,
        }
    }
}

