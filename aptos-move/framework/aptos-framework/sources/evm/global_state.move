module aptos_framework::evm_global_state {
    use std::vector;
    use aptos_framework::evm_util::{to_32bit};
    use aptos_std::debug;
    use aptos_framework::block::{get_current_block_height, get_epoch_interval_secs};

    const TX_TYPE_NORMAL: u64 = 1;
    const TX_TYPE_1559: u64 = 2;

    struct Env has drop {
        base_fee: u256,
        coinbase: vector<u8>,
        difficulty: u256,
        excess_blob_gas: u256,
        block_gas_limit: u256,
        gas_price: u256,
        max_priority_fee_per_gas: u256,
        max_fee_per_gas: u256,
        random: vector<u8>,
        sender: vector<u8>,
        to: vector<u8>,
        tx_type: u64
    }

    struct CallEvent has drop, copy, store {
        from: vector<u8>,
        to: vector<u8>,
        gas: u256,
        gas_used: u256,
        input: vector<u8>,
        output: vector<u8>,
        value: u256,
        type: u8,
        depth: u64,
        version: u8,
        extra: vector<u8>
    }

    struct RunState has drop {
        call_state: vector<CallState>,
        traces: vector<CallEvent>,
        env: Env,
        gas_used: u256
    }

    struct CallState has drop{
        highest_memory_cost: u256,
        highest_memory_word_size: u256,
        gas_refund: u256,
        gas_left: u256,
        gas_limit: u256,
        is_static: bool,
        ret_bytes: vector<u8>
    }

    fun default_env(sender: vector<u8>,
                    to: vector<u8>,
                    gas_price: u256,
                    max_fee_per_gas: u256,
                    max_priority_fee_per_gas: u256,
                    tx_type: u64): Env {
        let base_fee = 5000000000;
        let coinbase = to_32bit(x"892a2b7cF919760e148A0d33C1eb0f44D3b383f8");
        let difficulty = 0x00;
        let excess_blob_gas = 0x0e0000;
        let block_gas_limit = 30000000;
        let random = x"0000000000000000000000000000000000000000000000000000000000000000";
        if(tx_type == TX_TYPE_1559) {
            gas_price = base_fee + max_priority_fee_per_gas;
            gas_price = if(gas_price > max_fee_per_gas) max_fee_per_gas else gas_price
        };
        Env {
            tx_type,
            sender,
            to,
            max_fee_per_gas,
            max_priority_fee_per_gas,
            base_fee,
            coinbase,
            difficulty,
            excess_blob_gas,
            block_gas_limit,
            gas_price,
            random,
        }
    }

    public fun new_run_state(sender: vector<u8>,
                             to: vector<u8>,
                             gas_limit: u256,
                             gas_price: u256,
                             max_fee_per_gas: u256,
                             max_priority_per_gas: u256,
                             tx_type: u64): RunState {
        let state = RunState {
            gas_used: 0,
            call_state: vector::empty(),
            traces: vector::empty(),
            env: default_env(sender, to, gas_price, max_fee_per_gas, max_priority_per_gas, tx_type)
        };
        vector::push_back(&mut state.call_state, CallState {
            highest_memory_cost: 0,
            highest_memory_word_size: 0,
            gas_refund: 0,
            gas_left: gas_limit,
            gas_limit,
            is_static: false,
            ret_bytes: vector::empty()
        });
        state
    }

    public fun add_trace(run_state: &mut RunState, from: vector<u8>, to: vector<u8>, gas: u256, gas_used: u256, input: vector<u8>, output: vector<u8>, depth: u64, value: u256, type: u8) {
        vector::push_back(&mut run_state.traces, CallEvent {
            from,
            to,
            gas,
            gas_used,
            input,
            output,
            value,
            depth,
            type,
            version: 1,
            extra: x""
        })
    }

    public fun get_traces(run_state: &RunState): vector<CallEvent> {
        run_state.traces
    }

    public fun add_call_state(run_state: &mut RunState, gas_limit: u256, is_static: bool) {
        let state = get_lastest_state(run_state);
        let static = state.is_static || is_static;
        let gas_refund = state.gas_refund;
        vector::push_back(&mut run_state.call_state, CallState {
            highest_memory_cost: 0,
            highest_memory_word_size: 0,
            gas_refund,
            gas_left: gas_limit,
            gas_limit,
            is_static: static,
            ret_bytes: vector::empty()
        });
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
        old_state.gas_refund = new_state.gas_refund;
        old_state.gas_left = old_state.gas_left - (new_state.gas_limit - new_state.gas_left);
        run_state.gas_used = run_state.gas_used + (new_state.gas_limit - new_state.gas_left);
    }

    public fun revert_call_state(run_state: &mut RunState) {
        let new_state = vector::pop_back(&mut run_state.call_state);
        let old_state = get_lastest_state_mut(run_state);
        old_state.gas_left = if(old_state.gas_left > new_state.gas_limit) old_state.gas_left - new_state.gas_limit else 0;
        run_state.gas_used = run_state.gas_used + if(old_state.gas_left > new_state.gas_limit) new_state.gas_limit else old_state.gas_left;
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

    public fun set_ret_bytes(run_state: &mut RunState, bytes: vector<u8>) {
        let state = get_lastest_state_mut(run_state);
        state.ret_bytes = bytes
    }

    public fun get_ret_bytes(run_state: &RunState) : vector<u8> {
        let state = get_lastest_state(run_state);
        state.ret_bytes
    }

    public fun get_ret_size(run_state: &RunState): u256 {
        let state = get_lastest_state(run_state);
        (vector::length(&state.ret_bytes) as u256)
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
        debug::print(&10011);
    }

    public fun sub_gas_refund(run_state: &mut RunState, refund: u256) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = if(state.gas_refund > refund) state.gas_refund - refund else 0;
    }

    public fun clear_gas_refund(run_state: &mut RunState) {
        let state = get_lastest_state_mut(run_state);
        state.gas_refund = 0;
    }

    public fun get_is_static(run_state: &RunState): bool {
        let state = get_lastest_state(run_state);
        state.is_static
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

    public fun get_block_gas_limit(run_state: &RunState): u256 {
        run_state.env.block_gas_limit
    }

    public fun get_timestamp(_run_state: &RunState): u256 {
        ((get_epoch_interval_secs() / 1000000) as u256)
    }

    public fun get_block_number(_run_state: &RunState): u256 {
        (get_current_block_height() as u256)
    }

    public fun get_block_difficulty(run_state: &RunState): u256 {
        run_state.env.difficulty
    }

    public fun get_random(run_state: &RunState): vector<u8> {
        run_state.env.random
    }

    public fun get_origin(run_state: &RunState): vector<u8> {
        to_32bit(run_state.env.sender)
    }

    public fun get_sender(run_state: &RunState): vector<u8> {
        run_state.env.sender
    }

    public fun get_to(run_state: &RunState): vector<u8> {
        run_state.env.to
    }

    public fun get_max_fee_per_gas(run_state: &RunState): u256 {
        run_state.env.max_fee_per_gas
    }

    public fun get_max_priority_fee_per_gas(run_state: &RunState): u256 {
        run_state.env.max_priority_fee_per_gas
    }

    public fun is_eip_1559(run_state: &RunState): bool {
        run_state.env.tx_type == TX_TYPE_1559
    }
}

