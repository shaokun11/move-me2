#[test_only]
module aptos_framework::evm_tests {
    use aptos_framework::evm::{pre, test_run};

    #[test]
    fun evm_add() {
        pre(vector[x"0xcccccccccccccccccccccccccccccccccccccccc", x"0x0000000000000000000000000000000000000100", x"0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0x0000000000000000000000000000000000000102", x"0x0000000000000000000000000000000000000101", x"0x0000000000000000000000000000000000000104", x"0x0000000000000000000000000000000000000103"],
            vector[x"0x600060006000600060006004356101000162fffffff100", x"0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"0x", x"0x60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"0x60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"0x600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[, , , , , , ];
        test_run(
            x"undefined",
            x"undefined",
            x"undefined",
            undefined,
            undefined);
    }
}