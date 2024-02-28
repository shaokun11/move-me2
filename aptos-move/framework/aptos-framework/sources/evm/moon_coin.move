module aptos_framework::moon_coin {
    use aptos_framework::movement_coin;
    use std::string::utf8;
    use aptos_framework::fungible_asset::{MintRef, TransferRef, BurnRef, Metadata};
    use aptos_framework::fungible_asset;
    #[test_only]
    use std::bcs::to_bytes;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use std::signer::address_of;
    use aptos_framework::primary_fungible_store;
    #[test_only]
    use std::vector;
    #[test_only]
    use aptos_framework::evm::{query, send_move_tx_to_evm};
    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_framework::evm_util::u256_to_data;
    use aptos_framework::object::Object;
    use aptos_framework::object;

    /// Only owner can create the moon coin
    const INVALID_OWNER: u64 = 1;
    const MoonCoinAddr: address = @0x5;

    struct MoonCoin has key {
        evm_address: vector<u8>,
        mint_ref: MintRef,
        transfer_ref: TransferRef,
        burn_ref: BurnRef,
    }

    fun init_module(sender: &signer) {
        let (constructor_ref, evm_address)  = movement_coin::create_movement_coin(
            sender,
            utf8(b"Moon Coin"),
            utf8(b"MOON")
        );

        // Create mint/burn/transfer refs to allow creator to manage the fungible asset.
        let mint_ref = fungible_asset::generate_mint_ref(&constructor_ref);
        let burn_ref = fungible_asset::generate_burn_ref(&constructor_ref);
        let transfer_ref = fungible_asset::generate_transfer_ref(&constructor_ref);

        move_to(
            sender,
            MoonCoin { evm_address, mint_ref, transfer_ref, burn_ref }
        )
    }

    public entry fun mint(to: address, amount: u64) acquires MoonCoin {
        let moon_coin = borrow_global<MoonCoin>(MoonCoinAddr);
        primary_fungible_store::mint(&moon_coin.mint_ref, to, amount);
    }

    #[view]
    fun get_evm_address(): vector<u8> acquires MoonCoin {
        borrow_global<MoonCoin>(MoonCoinAddr).evm_address
    }

    #[view]
    /// Return the address of the managed fungible asset that's created when this module is deployed.
    public fun get_metadata(): Object<Metadata> acquires MoonCoin {
        let asset_address = object::create_object_address(&MoonCoinAddr, get_evm_address());
        object::address_to_object<Metadata>(asset_address)
    }


    #[test]
    fun test_moon_coin() acquires MoonCoin {
        let aptos_framework = account::create_account_for_test(@0x1);
        movement_coin::initialize(&aptos_framework);

        let mooncoin = account::create_account_for_test(MoonCoinAddr);
        let owner = account::create_account_for_test(@0x2);
        let sender = to_bytes(&address_of(&owner));
        init_module(&mooncoin);

        let evm_contract_address = get_evm_address();
        mint(address_of(&owner), 1000000000);

        let to_account_1 = account::create_account_for_test(@0x3);
        let to_account_2 = account::create_account_for_test(@0x4);
        let metadata = get_metadata();
        primary_fungible_store::transfer(&owner, metadata, address_of(&to_account_1), 100000000);


        let balance = primary_fungible_store::balance(address_of(&to_account_1), metadata);
        debug::print(&utf8(b"query owner balance"));
        debug::print(&balance);

        let params = x"70a08231";
        vector::append(&mut params, sender);
        debug::print(&utf8(b"query sender balance"));
        debug::print(&query(sender, evm_contract_address, params));

        let transfer_params = x"a9059cbb";
        let to = to_bytes(&address_of(&to_account_2));
        vector::append(&mut transfer_params, to);
        vector::append(&mut transfer_params, u256_to_data(20000000));
        debug::print(&utf8(b"transfer"));
        send_move_tx_to_evm(&to_account_1, evm_contract_address, u256_to_data(0), transfer_params, 1);

        let params = x"70a08231";
        vector::append(&mut params, to_bytes(&to_account_1));
        debug::print(&utf8(b"query owner balance"));
        debug::print(&query(sender, evm_contract_address, params));

        let params = x"70a08231";
        vector::append(&mut params, to_bytes(&to_account_2));
        debug::print(&utf8(b"query other balance"));
        debug::print(&query(sender, evm_contract_address, params));
    }
}
