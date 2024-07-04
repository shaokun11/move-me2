module aptos_framework::precompile {
    use std::vector;
    use aptos_framework::evm_util::{to_u256, to_32bit, vector_slice, vector_slice_u256};
    use aptos_std::secp256k1::{ecdsa_recover, ecdsa_signature_from_bytes, ecdsa_raw_public_key_to_bytes};
    use aptos_std::aptos_hash::{keccak256, ripemd160};
    use std::option::borrow;
    use aptos_std::debug;
    use std::hash::sha2_256;
    use aptos_framework::evm_arithmetic::{mod_exp, bit_length};

    /// unsupport precomile address
    const UNSUPPORT: u64 = 50001;
    /// invalid precomile calldata length
    const CALL_DATA_LENGTH: u64 = 50002;
    /// mod exp len params invalid
    const MOD_PARAMS_SISE: u64 = 50003;

    const MAX_SIZE: u256 = 2147483647;

    const ModexpGquaddivisor: u256 = 3;

    // precompile address list
    const RCRECOVER: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000001";
    const SHA256: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000002";
    const RIPEMD: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000003";
    const IDENTITY: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000004";
    const MODEXP: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000005";
    const ECADD: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000006";
    const ECMUL: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000007";
    const ECPAIRING: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000008";
    const BLAKE2F: vector<u8> = x"0000000000000000000000000000000000000000000000000000000000000009";

    #[view]
    public fun run_precompile(addr: vector<u8>, calldata: vector<u8>, chain_id: u64, gas_limit: u256): (bool, vector<u8>, u256) {
        if(addr == RCRECOVER) {
            assert!(vector::length(&calldata) == 128, CALL_DATA_LENGTH);
            let message_hash = vector_slice(calldata, 0, 32);
            let v = (to_u256(vector_slice(calldata, 32, 32)) as u64);
            let signature = ecdsa_signature_from_bytes(vector_slice(calldata, 64, 64));

            let recovery_id = if(v > 28) ((v - (chain_id * 2) - 35) as u8) else ((v - 27) as u8);
            let pk_recover = ecdsa_recover(message_hash, recovery_id, &signature);
            let pk = keccak256(ecdsa_raw_public_key_to_bytes(borrow(&pk_recover)));
            debug::print(&vector_slice(pk, 12, 20));
            (true, to_32bit(vector_slice(pk, 12, 20)), 0)
        } else if(addr == SHA256) {
            (true, sha2_256(calldata), 0)
        } else if(addr == RIPEMD) {
            debug::print(&to_32bit(ripemd160(calldata)));
            (true, to_32bit(ripemd160(calldata)), 0)
        } else if(addr == IDENTITY) {
            (true, calldata, 0)
        } else if(addr == MODEXP) {

            let base_len = to_u256(vector_slice(calldata, 0, 32));
            let exp_len = to_u256(vector_slice(calldata, 32, 32));
            let mod_len = to_u256(vector_slice(calldata, 64, 32));

            let pos = 96;
            let base_bytes = vector_slice_u256(calldata, pos, base_len);
            pos = pos + base_len;
            let exp_bytes = vector_slice_u256(calldata, pos, exp_len);
            pos = pos + exp_len;
            let mod_bytes = vector_slice_u256(calldata, pos, mod_len);
            let gas = calc_mod_exp_gas(base_len, exp_len, exp_bytes, mod_len);
            if(base_len == 0 || mod_len == 0) {
                return (true, to_32bit(x""), gas)
            };

            if(base_len > MAX_SIZE || mod_len > MAX_SIZE || exp_len > MAX_SIZE || (base_len + mod_len + exp_len + 96) > MAX_SIZE) {
                return (false, to_32bit(x""), gas_limit)
            };

            let result = mod_exp(base_bytes, exp_bytes, mod_bytes);

            (true, to_32bit(result), gas)
        } else {
            assert!(false, (to_u256(addr) as u64));
            (false, x"", 0)
        }
    }

    fun calc_mod_exp_gas(base_len: u256, exp_len: u256, exp_bytes: vector<u8>, mod_len: u256): u256 {
        let multiplication_complexity = calculate_multiplication_complexity(base_len, mod_len);
        let iteration_count = calculate_iteration_count(exp_len, exp_bytes);
        let gas = multiplication_complexity * iteration_count / ModexpGquaddivisor;
        if(gas < 200) {
            gas = 200;
        };

        gas
    }

    fun calculate_iteration_count(exponent_length: u256, exponent_bytes: vector<u8>): u256 {
        let bit_length = bit_length(exponent_bytes);
        let iteration_count = 0;
        if(exponent_length <= 32 && bit_length == 0) {
            iteration_count = 0;
        } else if(exponent_length <= 32) {
            iteration_count = bit_length - 1;
        } else if(exponent_length > 32) {
            let last_32_bit = vector_slice_u256(exponent_bytes, exponent_length - 32, 32);
            iteration_count = (8 * (exponent_length - 32)) + (bit_length(last_32_bit) - 1)
        };

        if(iteration_count == 0) 1 else iteration_count
    }

    fun calculate_multiplication_complexity(base_len: u256, mod_len: u256): u256 {
        let max_length = if(base_len > mod_len) base_len else mod_len;
        let words = max_length / 8;
        if(max_length % 8 != 0) {
            words = words + 1;
        };
        words * words
    }

    #[view]
    public fun is_precompile_address(addr: vector<u8>): bool {
        let num = to_u256(addr);
        num >= 0x01 && num <= 0x0a
    }

}