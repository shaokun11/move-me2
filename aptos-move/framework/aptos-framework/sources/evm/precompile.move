module aptos_framework::evm_precompile {
    use std::vector;
    use aptos_framework::evm_util::{to_u256, to_32bit, vector_slice, get_word_count};
    use aptos_std::aptos_hash::{keccak256, ripemd160};
    use aptos_std::debug;
    use std::hash::sha2_256;

    public native fun mod_exp(input: vector<u8>): (bool, u64, vector<u8>);
    public native fun bn128_add(a: vector<u8>): (bool, vector<u8>);
    public native fun bn128_mul(a: vector<u8>): (bool, vector<u8>);
    public native fun bn128_pairing(a: vector<u8>): (bool, u64, vector<u8>);
    public native fun blake_2f(input: vector<u8>): (bool, u64, vector<u8>);
    public native fun ecrecover_internal(message: vector<u8>,
                                         recovery_id: u8,
                                         signature: vector<u8>): (bool, vector<u8>);

    /// unsupport precomile address
    const UNSUPPORT: u64 = 50001;
    /// invalid precomile calldata length
    const CALL_DATA_LENGTH: u64 = 50002;
    /// mod exp len params invalid
    const MOD_PARAMS_SISE: u64 = 50003;

    const MAX_SIZE: u256 = 2147483647;

    const ModexpGquaddivisor: u256 = 3;
    const Sha256Word: u256 = 12;
    const Ripemd160Word: u256 = 120;
    const IdentityWord: u256 = 3;
    const EcAddCost: u256 = 150;
    const EcMulCost: u256 = 6000;
    const Ecrecover: u256 = 3000;

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

    fun ecrecover(calldata: vector<u8>, gas_limit: u256): (bool, vector<u8>, u256) {
        let message_hash = vector_slice(calldata, 0, 32);
        let v = to_u256(vector_slice(calldata, 32, 32));
        debug::print(&v);
        if(v != 27 && v != 28) {
            return (true, x"", Ecrecover)
        };
        let recovery_id = if(v == 27) 0 else 1;
        let (success, pk_recover) = ecrecover_internal(message_hash, recovery_id, vector_slice(calldata, 64, 64));
        if(!success) {
            return (true, x"", Ecrecover)
        };
        let pk = keccak256(pk_recover);
        if(Ecrecover > gas_limit) {
            (false, x"", gas_limit)
        } else {
            (true, to_32bit(vector_slice(pk, 12, 20)), Ecrecover)
        }
    }

    public fun run_precompile(addr: vector<u8>, calldata: vector<u8>, gas_limit: u256): (bool, vector<u8>, u256)  {
        debug::print(&addr);
        debug::print(&calldata);
        if(addr == RCRECOVER) {
            ecrecover(calldata, gas_limit)
        } else if(addr == SHA256) {
            let word_count = get_word_count((vector::length(&calldata) as u256));
            (true, sha2_256(calldata), Sha256Word * word_count + 60)
        } else if(addr == RIPEMD) {
            let word_count = get_word_count((vector::length(&calldata) as u256));
            (true, to_32bit(ripemd160(calldata)), 600 + Ripemd160Word * word_count)
        } else if(addr == IDENTITY) {
            let word_count = get_word_count((vector::length(&calldata) as u256));
            (true, calldata, 15 + IdentityWord * word_count)
        } else if(addr == MODEXP) {
            let (success, gas, result) = mod_exp(calldata);
            let gas_cost = if(success) (gas as u256) else gas_limit;
            (success, result, gas_cost)
        } else if(addr == ECADD) {
            let (success, result) = bn128_add(calldata);
            if(success) (success, result, EcAddCost) else (success, result, gas_limit)
        } else if(addr == ECMUL) {
            let (success, result) = bn128_mul(calldata);
            if(success) (success, result, EcMulCost) else (success, result, gas_limit)
        } else if(addr == ECPAIRING) {
            let (success, gas, result) = bn128_pairing(calldata);
            if(success) (success, result, (gas as u256)) else (success, result, gas_limit)
        } else if(addr == BLAKE2F) {
            if(vector::length(&calldata) != 213) {
                return (false, x"", gas_limit)
            };
            let (success, gas_cost, result) = blake_2f(calldata);
            debug::print(&vector::length(&calldata));
            debug::print(&result);
            debug::print(&success);
            debug::print(&gas_cost);
            if(!success) {
                return (false, x"", gas_limit)
            } else {
                return (true, result, (gas_cost as u256))
            }
        } else {
            (false, x"", gas_limit)
        }
    }

    #[view]
    public fun is_precompile_address(addr: vector<u8>): bool {
        let num = to_u256(addr);
        num >= 0x01 && num <= 0x0a
    }

}