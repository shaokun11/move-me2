#[test_only]
module aptos_framework::evm_add {
    use aptos_framework::evm::{pre, test_run};

    #[test]
    fun Cancun_0_0_0() {
        pre(vector[x"cccccccccccccccccccccccccccccccccccccccc", x"0000000000000000000000000000000000000100", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0000000000000000000000000000000000000102", x"0000000000000000000000000000000000000101", x"0000000000000000000000000000000000000104", x"0000000000000000000000000000000000000103"],
            vector[x"600060006000600060006004356101000162fffffff100", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"", x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
        test_run(
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000000",
            0x0,
            0x1);
    }

    #[test]
    fun Cancun_0_1_0() {
        pre(vector[x"cccccccccccccccccccccccccccccccccccccccc", x"0000000000000000000000000000000000000100", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0000000000000000000000000000000000000102", x"0000000000000000000000000000000000000101", x"0000000000000000000000000000000000000104", x"0000000000000000000000000000000000000103"],
            vector[x"600060006000600060006004356101000162fffffff100", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"", x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
        test_run(
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000001",
            0x0,
            0x1);
    }

    #[test]
    fun Cancun_0_2_0() {
        pre(vector[x"cccccccccccccccccccccccccccccccccccccccc", x"0000000000000000000000000000000000000100", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0000000000000000000000000000000000000102", x"0000000000000000000000000000000000000101", x"0000000000000000000000000000000000000104", x"0000000000000000000000000000000000000103"],
            vector[x"600060006000600060006004356101000162fffffff100", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"", x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
        test_run(
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000002",
            0x0,
            0x1);
    }

    #[test]
    fun Cancun_0_3_0() {
        pre(vector[x"cccccccccccccccccccccccccccccccccccccccc", x"0000000000000000000000000000000000000100", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0000000000000000000000000000000000000102", x"0000000000000000000000000000000000000101", x"0000000000000000000000000000000000000104", x"0000000000000000000000000000000000000103"],
            vector[x"600060006000600060006004356101000162fffffff100", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"", x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
        test_run(
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000003",
            0x0,
            0x1);
    }

    #[test]
    fun Cancun_0_4_0() {
        pre(vector[x"cccccccccccccccccccccccccccccccccccccccc", x"0000000000000000000000000000000000000100", x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b", x"0000000000000000000000000000000000000102", x"0000000000000000000000000000000000000101", x"0000000000000000000000000000000000000104", x"0000000000000000000000000000000000000103"],
            vector[x"600060006000600060006004356101000162fffffff100", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"", x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500", x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500", x"600060000160005500"],
            vector[0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce, 0xba1a9ce0ba1a9ce],
            vector[0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]);
        test_run(
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000004",
            0x0,
            0x1);
    }
}