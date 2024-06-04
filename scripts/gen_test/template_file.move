#[test_only]
module aptos_framework::evm_tests {
    use aptos_framework::evm::{pre, test_run};

    #[test]
    fun evm_add() {
        pre($addresses,
            $codes,
            $balances,
            $nonces);
        test_run(
            $from,
            $to,
            $data,
            $nonce,
            $value);
    }
}