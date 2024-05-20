module batch_transfer::batch_transfer {
    use std::vector;
    use aptos_framework::evm;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// adderess and amount size not match
    const SIZE_NOT_MATCH: u64 = 1;

    public entry fun batch_transfer_evm(sender: &signer, evm_addr_list: vector<vector<u8>>, amount_bytes_list: vector<vector<u8>>) {
        let len = vector::length(&evm_addr_list);
        assert!(len == vector::length(&amount_bytes_list), 1);
        let i = 0;
        while (i < len) {
            evm::deposit(sender, *vector::borrow(&evm_addr_list, i), *vector::borrow(&amount_bytes_list, i));
            i = i + 1;
        }
    }

    public entry fun batch_transfer_move(sender: &signer, move_addr_list: vector<address>, amount_list: vector<u64>) {
        let len = vector::length(&move_addr_list);
        assert!(len == vector::length(&amount_list), SIZE_NOT_MATCH);
        let i = 0;
        while (i < len) {
            coin::transfer<AptosCoin>(sender, *vector::borrow(&move_addr_list, i), *vector::borrow(&amount_list, i));
            i = i + 1;
        }
    }
}