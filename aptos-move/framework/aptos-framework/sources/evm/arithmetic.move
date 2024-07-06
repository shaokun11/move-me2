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


}