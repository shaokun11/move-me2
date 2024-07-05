module aptos_framework::evm_arithmetic {
    public native fun add(a: u256, b: u256): u256;
    public native fun mul(a: u256, b: u256): u256;
    public native fun sub(a: u256, b: u256): u256;
    public native fun div(a: u256, b: u256): u256;
    public native fun mod(a: u256, b: u256): u256;
    public native fun sdiv(a: u256, b: u256): u256;
    public native fun smod(a: u256, b: u256): u256;
    public native fun exp(a: u256, b: u256): u256;
    public native fun slt(a: u256, b: u256): bool;
    public native fun sgt(a: u256, b: u256): bool;
    public native fun sar(a: u256, b: u256): u256;
    public native fun shr(a: u256, b: u256): u256;
    public native fun add_mod(a: u256, b: u256, n: u256): u256;
    public native fun mul_mod(a: u256, b: u256, n: u256): u256;
    public native fun bit_length(a: vector<u8>): u256;
    public native fun mod_exp(base: vector<u8>, exp_bytes: vector<u8>, mod: vector<u8>): vector<u8>;
    public native fun bn128_add(a: vector<u8>): (bool, vector<u8>);
    public native fun bn128_mul(a: vector<u8>): (bool, vector<u8>);
    public native fun bn128_pairing(a: vector<u8>): (bool, u64, vector<u8>);
    public native fun blake_2f(input: vector<u8>): (bool, u64, vector<u8>);
}