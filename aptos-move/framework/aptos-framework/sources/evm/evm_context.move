module aptos_framework::evm_context {
    /// Type of tables
    struct HashMap<phantom K: copy + drop, phantom V> has drop, copy {
        handle: vector<u8>,
    }
}