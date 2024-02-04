module aptos_framework::delegate {
    friend aptos_framework::evm;

    use aptos_framework::evm_util::{slice, to_u256, u256_to_data};
    use aptos_framework::multisig_account::vote_transanction;
    use aptos_std::from_bcs::to_address;
    use aptos_framework::movement_coin::get_coin_key_by_wrap_evm;
    use aptos_framework::movement_coin;
    use std::bcs::to_bytes;
    use std::signer::address_of;
    use aptos_framework::create_signer::create_signer;
    use aptos_std::debug;

    public(friend) fun execute_move_tx(signer: &signer, _target: address, data: vector<u8>): vector<u8> {
        let selector = slice(data, 0, 4);
        debug::print(&data);
        debug::print(&selector);
        if(selector == x"10d6791e") {
            let multisig_address = to_address(slice(data, 4, 32));
            let sequence_number = to_u256(slice(data, 36, 32));
            let approved = if(to_u256(slice(data, 68, 32)) == 1) true else false;
            vote_transanction(signer, multisig_address, (sequence_number as u64), approved);
            x""
        } else if(selector == x"2c9e6315") {
            let method = to_u256(slice(data, 68, 32));
            let token_address = to_bytes(&address_of(signer));

            let coin_key = get_coin_key_by_wrap_evm(token_address);
            if(method == 1) {
                let to = to_address(slice(data, 100, 32));
                u256_to_data((movement_coin::balance(to, coin_key) as u256))
            } else if(method == 5) {
                let from = to_address(slice(data, 100, 32));
                let to = to_address(slice(data, 132, 32));
                let amount = to_u256(slice(data, 164, 32));
                let signer = create_signer(from);
                movement_coin::transfer(&signer, to, (amount as u64), coin_key);
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

