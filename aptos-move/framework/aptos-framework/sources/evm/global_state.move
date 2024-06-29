module aptos_framework::evm_global_state {
    use std::vector;

    struct RunState has drop {
        call_state: vector<CallState>
    }

    struct CallState has drop{
        highest_memory_cost: u256,
        highest_memory_word_size: u256,
        gas_refund: u256,
        gas_usage: u256
    }

    public fun new_run_state(): RunState {
        let state = RunState {
            call_state: vector::empty(),
        };
        add_call_state(&mut state);
        state
    }

    public fun add_call_state(run_state: &mut RunState) {
        vector::push_back(&mut run_state.call_state, CallState {
            highest_memory_cost: 0,
            highest_memory_word_size: 0,
            gas_refund: 0,
            gas_usage: 0
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
        old_state.gas_usage = old_state.gas_usage + new_state.gas_usage;
    }

    public fun revert_call_state(run_state: &mut RunState) {
        let new_state = vector::pop_back(&mut run_state.call_state);
        let old_state = get_lastest_state_mut(run_state);
        old_state.gas_usage = old_state.gas_usage + new_state.gas_usage;
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

    public fun add_gas_usage(run_state: &mut RunState, cost: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_usage = state.gas_usage + cost;
    }

    public fun add_gas_refund(run_state: &mut RunState, refund: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = state.gas_refund + refund;
    }

    public fun sub_gas_refund(run_state: &mut RunState, refund: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = state.gas_refund - refund;
    }

    public fun get_gas_usage(run_state: &RunState): u256 {
        let state = get_lastest_state(run_state);
        state.gas_usage
    }

    public fun get_gas_refund(run_state: &RunState): u256 {
        let state = get_lastest_state(run_state);
        state.gas_refund
    }
}

