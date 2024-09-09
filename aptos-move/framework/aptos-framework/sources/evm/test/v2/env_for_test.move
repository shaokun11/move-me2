module aptos_framework::env_for_test {
    use std::vector;
    use aptos_framework::evm_util::to_u256;

    struct Env has drop {
        block_number: u256,
        block_coinbase: vector<u8>,
        block_timestamp: u256,
        block_difficulty: u256,
        block_random: vector<u8>,
        block_gas_limit: u256,
        block_base_fee_per_gas: u256,
        block_excess_blob_gas: u256,
        chain_id: u256
    }

    public fun get_base_fee_per_gas(env: &Env): u256 {
        env.block_base_fee_per_gas
    }

    public fun parse_env(env: &vector<vector<u8>>): Env {
        let block_base_fee_per_gas = to_u256(*vector::borrow(env, 0));
        let block_coinbase = *vector::borrow(env, 1);
        let block_difficulty = to_u256(*vector::borrow(env, 2));
        let block_excess_blob_gas = to_u256(*vector::borrow(env, 3));
        let block_gas_limit = to_u256(*vector::borrow(env, 4));
        let block_number = to_u256(*vector::borrow(env, 5));
        let block_random = *vector::borrow(env, 6);
        let block_timestamp = to_u256(*vector::borrow(env, 7));
        Env {
            block_base_fee_per_gas,
            block_coinbase,
            block_difficulty,
            block_excess_blob_gas,
            block_gas_limit,
            block_number,
            block_random,
            block_timestamp,
            chain_id: 1
        }
    }
}