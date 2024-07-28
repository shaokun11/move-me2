module aptos_framework::evm_context {
    friend aptos_framework::evm_trie_for_test;
    friend aptos_framework::evm_for_test;

    public(friend) native fun exist(contract: vector<u8>): (bool, bool);
    public(friend) native fun calculate_root(): vector<u8>;
    public(friend) native fun storage_empty(contract: vector<u8>): bool;
    public(friend) native fun is_cold_address(contract: vector<u8>): bool;
    public(friend) native fun get_transient_storage(contract: vector<u8>, index: u256): u256;
    public(friend) native fun get_origin(contract: vector<u8>, index: u256): (bool, u256);
    public(friend) native fun get_code(contract: vector<u8>): (bool, vector<u8>);
    public(friend) native fun get_balance(contract: vector<u8>): (bool, u256);
    public(friend) native fun get_nonce(contract: vector<u8>): (bool, u256);
    public(friend) native fun get_storage(contract: vector<u8>, index: u256): (bool, u256);
    public(friend) native fun set_code(contract: vector<u8>, code: vector<u8>);
    public(friend) native fun set_account(contract: vector<u8>, balance: u256, code: vector<u8>, nonce: u256);
    public(friend) native fun set_storage(contract: vector<u8>, index: u256, value: u256);
    public(friend) native fun set_transient_storage(contract: vector<u8>, index: u256, value: u256);
    public(friend) native fun add_balance(contract: vector<u8>, value: u256);
    public(friend) native fun sub_balance(contract: vector<u8>, value: u256): bool;
    public(friend) native fun inc_nonce(contract: vector<u8>);
    public(friend) native fun set_nonce(contract: vector<u8>, nonce: u256);
    public(friend) native fun add_always_hot_address(contract: vector<u8>);
    public(friend) native fun add_always_hot_slot(contract: vector<u8>, index: u256);
    public(friend) native fun add_hot_address(contract: vector<u8>);
    public(friend) native fun push_substate();
    public(friend) native fun commit_substate();
    public(friend) native fun revert_substate();
}