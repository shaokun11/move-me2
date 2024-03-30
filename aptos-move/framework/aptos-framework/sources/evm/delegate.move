module aptos_framework::delegate {
    friend aptos_framework::evm;

    use aptos_framework::evm_util::{slice, to_u256, u256_to_data};
    use aptos_framework::multisig_account::vote_transanction;
    use aptos_std::from_bcs::to_address;
    use aptos_framework::create_signer::create_signer;
    use aptos_framework::primary_fungible_store;
    use aptos_framework::fungible_asset::Metadata;
    use aptos_framework::object;

    /// Cannot call not read only function in read only context
    const READ_ONLY: u64 = 10001;

    public(friend) fun execute_move_tx(sender: vector<u8>, contract: vector<u8>, _target: address, data: vector<u8>, read_only: bool): vector<u8> {
        let selector = slice(data, 0, 4);
        // debug::print(&data);
        // debug::print(&selector);
        if(selector == x"10d6791e") {
            let multisig_address = to_address(slice(data, 4, 32));
            let sequence_number = to_u256(slice(data, 36, 32));
            let approved = if(to_u256(slice(data, 68, 32)) == 1) true else false;
            vote_transanction(&create_signer(to_address(contract)), multisig_address, (sequence_number as u64), approved);
            x""
        } else if(selector == x"2c9e6315") {
            let method = to_u256(slice(data, 68, 32));
            let object_address = to_address(slice(data, 100, 32));
            let metadata = object::address_to_object(object_address);

            // let coin_key = get_coin_key_by_wrap_evm(token_address);
            if(method == 1) {
                let to = to_address(slice(data, 132, 32));
                u256_to_data((primary_fungible_store::balance<Metadata>(to, metadata) as u256))
            } else if(method == 5 || method == 6) {
                assert!(!read_only, READ_ONLY);
                let to = to_address(slice(data, 132, 32));
                let amount = to_u256(slice(data, 164, 32));
                let from = create_signer(to_address(sender));

                primary_fungible_store::transfer<Metadata>(&from, metadata, to, (amount as u64));
                x""
            } else {
                x""
            }
        }
        else {
            x""
        }
    }


}

