module aptos_framework::evm_storage {
    use aptos_std::table::Table;
    use aptos_std::from_bcs::to_address;
    use aptos_std::table;
    use aptos_framework::create_signer::create_signer;
    use std::vector;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    use aptos_framework::evm_util::{data_to_u256, vector_slice, to_32bit};
    use aptos_std::debug;
    use aptos_framework::aptos_account::create_account;

    friend aptos_framework::evm_trie;
    friend aptos_framework::evm;

    const CONVERT_BASE: u256 = 10000000000;

    const ERROR_ACCOUNT_NOT_CREATED: u64 = 1001;
    const ERROR_INSUFFIENT_BALANCE: u64 = 1002;

    struct AccountStorage has key, store {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: Table<u256, u256>
    }

    struct AccountEvent has key, store {
        contract_addr: vector<u8>,
        data: vector<u8>
    }

    public fun get_move_address(evm_address: vector<u8>): address {
        to_address(to_32bit(evm_address))
    }

    public fun exist_account_storage(contract_addr: vector<u8>): bool {
        let move_address = get_move_address(contract_addr);
        exists<AccountStorage>(move_address)
    }

    public fun get_code_storage(contract_addr: vector<u8>): vector<u8> acquires AccountStorage {
        let move_address = get_move_address(contract_addr);
        if(exists<AccountStorage>(move_address)) {
            let account = borrow_global<AccountStorage>(move_address);
            account.code
        } else {
            x""
        }
    }

    public fun get_state_storage(contract_addr: vector<u8>, key: u256): u256 acquires AccountStorage {
        let move_address = get_move_address(contract_addr);
        if(exists<AccountStorage>(move_address)) {
            let account = borrow_global<AccountStorage>(move_address);
            *table::borrow_with_default(&account.storage, key, &0)
        } else {
            0
        }
    }

    public(friend) fun save_account_state(contract_addr: vector<u8>, keys: vector<u256>, values: vector<u256>) acquires AccountStorage {
        let move_address = get_move_address(contract_addr);
        if(exists<AccountStorage>(move_address)) {
            let account = borrow_global_mut<AccountStorage>(move_address);
            let i = 0;
            while(i < vector::length(&keys)) {
                table::upsert(&mut account.storage, *vector::borrow(&keys, i), *vector::borrow(&values, i));
                i = i + 1;
            }
        }
    }

    public(friend) fun save_account_storage(address: vector<u8>, balance: u256, code: vector<u8>, nonce: u256) acquires AccountStorage {
        let move_address = get_move_address(address);
        create_account_if_not_exist(move_address);
        let account_store_to = borrow_global_mut<AccountStorage>(move_address);
        if(account_store_to.nonce != nonce) {
            account_store_to.nonce = nonce;
        };

        if(account_store_to.balance != balance) {
            account_store_to.balance = balance;
        };

        if(account_store_to.code != code) {
            account_store_to.code = code;
        };
    }

    public(friend) fun load_account_storage(contract_addr: vector<u8>): (u256, vector<u8>, u256) acquires AccountStorage {
        let move_address = get_move_address(contract_addr);
        if(exists<AccountStorage>(move_address)) {
            let account = borrow_global<AccountStorage>(get_move_address(contract_addr));
            (account.balance, account.code, account.nonce)
        } else {
            (0, x"", 0)
        }
    }

    fun create_account_if_not_exist(move_address: address) {
        if(!exists<AccountStorage>(move_address)) {
            create_account(move_address);
            move_to(&create_signer(move_address), AccountStorage {
                balance: 0,
                code: x"",
                nonce: 0,
                storage: table::new()
            });
        }
    }

    public(friend) fun deposit_to(sender: &signer, address: vector<u8>, amount: u256) acquires AccountStorage {
        if(amount > 0) {
            coin::transfer<AptosCoin>(sender, @aptos_framework, ((amount / CONVERT_BASE)  as u64));

            let move_address = get_move_address(address);
            create_account_if_not_exist(move_address);
            let account_store_to = borrow_global_mut<AccountStorage>(move_address);
            account_store_to.balance = account_store_to.balance + amount;
        }
    }

    public(friend) fun withdraw_from(from: vector<u8>, data: vector<u8>) acquires AccountStorage {
        let amount = data_to_u256(data, 36, 32);
        let to = to_address(vector_slice(data, 100, 32));
        if(amount > 0) {
            let move_address = get_move_address(from);
            assert!(exists<AccountStorage>(move_address), ERROR_ACCOUNT_NOT_CREATED);

            let account_store_from = borrow_global_mut<AccountStorage>(move_address);
            assert!(account_store_from.balance >= amount, ERROR_INSUFFIENT_BALANCE);
            account_store_from.balance = account_store_from.balance - amount;

            let signer = create_signer(@aptos_framework);
            coin::transfer<AptosCoin>(&signer, to, ((amount / CONVERT_BASE)  as u64));
        }
    }

}
