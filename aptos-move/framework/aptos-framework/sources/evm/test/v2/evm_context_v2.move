module aptos_framework::evm_context_v2 {
    use aptos_framework::env_for_test::Env;

    friend aptos_framework::evm_for_test_v2;
    friend aptos_framework::evm;

    public(friend) native fun get_balance_change_set(): (u64, vector<u8>, vector<u256>);
    public(friend) native fun get_nonce_change_set(): (u64, vector<u8>, vector<u256>);
    public(friend) native fun get_code_change_set(): (u64, vector<u8>, vector<u64>, vector<u8>);
    public(friend) native fun get_address_change_set(): (u64, vector<u8>);
    public(friend) native fun get_storage_change_set(address: vector<u8>): (vector<u256>, vector<u256>);
    public(friend) native fun calculate_root(): vector<u8>;
    public(friend) native fun set_code(contract: vector<u8>, code: vector<u8>);
    public(friend) native fun set_account(contract: vector<u8>, balance: u256, code: vector<u8>, nonce: u256);
    public(friend) native fun set_storage(contract: vector<u8>, index: u256, value: u256);
    public(friend) native fun add_always_warm_address(contract: vector<u8>);
    public(friend) native fun add_always_warm_slot(contract: vector<u8>, index: u256);
    public(friend) native fun execute_tx_for_test(env: Env, from: vector<u8>, to: vector<u8>, value: u256, data: vector<u8>, gas_limit: u256,
                          gas_price: u256, max_fee_per_gas: u256, max_priority_fee_per_gas: u256, access_list_address_len: u64,
                                         access_list_slot_len: u64, tx_type: u8): (u64, u256);
    public(friend) native fun execute_tx<Storage>(from: vector<u8>,
                                                to: vector<u8>,
                                                value: u256,
                                                nonce: u256,
                                                data: vector<u8>,
                                                gas_limit: u256,
                                                gas_price: u256,
                                                max_fee_per_gas: u256,
                                                max_priority_fee_per_gas: u256,
                                                access_list_address_len: u64,
                                                access_list_slot_len: u64,
                                                tx_type: u64,
                                                skip_nonce: bool,
                                                skip_balance: bool,
                                                skip_block_gas_limit_validation: bool,
                                                block_timestamp: u256,
                                                block_number: u256,
                                                block_coinbase: vector<u8>,
                                                chain_id: u256): (u64, u256, vector<u8>, vector<u8>);
}