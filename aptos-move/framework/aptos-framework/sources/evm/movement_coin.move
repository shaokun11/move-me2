module aptos_framework::movement_coin {
    friend aptos_framework::movement_coin_issuer;
    friend aptos_framework::genesis;

    use std::string;
    use aptos_std::table;
    use aptos_std::table::Table;
    use aptos_std::type_info::{type_of, account_address, module_name, struct_name, TypeInfo};
    use std::bcs::to_bytes;
    use std::vector;
    use std::signer::address_of;
    use std::error;
    use std::option::Option;
    use std::option;
    use aptos_std::debug;

    /// Address of account which is used to initialize a coin `CoinType` doesn't match the deployer of module
    const ECOIN_INFO_ADDRESS_MISMATCH: u64 = 1;

    /// `CoinType` is already initialized as a coin
    const ECOIN_INFO_ALREADY_PUBLISHED: u64 = 2;

    /// `CoinType` hasn't been initialized as a coin
    const ECOIN_INFO_NOT_PUBLISHED: u64 = 3;

    /// Deprecated. Account already has `CoinStore` registered for `CoinType`
    const ECOIN_STORE_ALREADY_PUBLISHED: u64 = 4;

    /// Account hasn't registered `CoinStore` for `CoinType`
    const ECOIN_STORE_NOT_PUBLISHED: u64 = 5;

    /// Not enough coins to complete transaction
    const EINSUFFICIENT_BALANCE: u64 = 6;


    struct WrapEvmCoin has key {
        info: Table<vector<u8>, vector<u8>>
    }

    struct CoinStore has key {
        coins: Table<vector<u8>, CoinInfo>
    }

    struct CoinInfo has store {
        name: string::String,
        symbol: string::String,
        decimals: u8,
        total_supply: u64,
        evm_address: vector<u8>
    }

    struct BalanceStore has key, store {
        balances: Table<vector<u8>, u64>
    }

    public(friend) fun initialize(account: &signer) {
        move_to(account, CoinStore {
            coins: table::new<vector<u8>, CoinInfo>(),
        });
        move_to(account, WrapEvmCoin {
            info: table::new<vector<u8>, vector<u8>>(),
        });
    }

    public(friend) fun create<CoinType> (
        creator: &signer,
        evm_address: vector<u8>,
        name: string::String,
        symbol: string::String,
        supply: u64,
        decimals: u8
    ) acquires WrapEvmCoin, CoinStore, BalanceStore {
        let account_addr = address_of(creator);

        let coin_key = get_coin_key_by_type<CoinType>();
        debug::print(&coin_key);
        assert!(!is_coin_initialized(coin_key), error::already_exists(ECOIN_INFO_ALREADY_PUBLISHED));

        assert!(
            account_address(&type_of<CoinType>()) == account_addr,
            error::invalid_argument(ECOIN_INFO_ADDRESS_MISMATCH),
        );

        let wrap_evm_coins = borrow_global_mut<WrapEvmCoin>(@aptos_framework);
        table::add(&mut wrap_evm_coins.info, evm_address, coin_key);
        let coin_store = borrow_global_mut<CoinStore>(@aptos_framework);
        table::add(&mut coin_store.coins, coin_key, CoinInfo {
            name,
            symbol,
            decimals,
            total_supply: supply,
            evm_address
        });

        register(creator, coin_key);
        let balance_store = borrow_global_mut<BalanceStore>(account_addr);
        table::upsert(&mut balance_store.balances, coin_key, supply);
    }

    public entry fun register(
        from: &signer,
        coin_key: vector<u8>
    ) acquires BalanceStore {
        let account_addr = address_of(from);
        if(!exists<BalanceStore>(account_addr)) {
            move_to(from, BalanceStore {
                balances: table::new<vector<u8>, u64>(),
            });
        };

        let balance_store = borrow_global_mut<BalanceStore>(account_addr);
        if(!table::contains(&balance_store.balances, coin_key)) {
            table::add(&mut balance_store.balances, coin_key, 0);
        }
    }

    /// Transfers `amount` of coins `CoinType` from `from` to `to`.
    public entry fun transfer (
        sender: &signer,
        to: address,
        amount: u64,
        coin_key: vector<u8>
    ) acquires CoinStore, BalanceStore {
        assert!(is_coin_initialized(coin_key), error::not_found(ECOIN_INFO_NOT_PUBLISHED));
        // Convert `from` and `to` addresses to bytes
        let from = address_of(sender);

        register(sender, coin_key);
        let from_balance_store = borrow_global_mut<BalanceStore>(from);
        // Check if `from` account has enough balance to transfer
        let from_balance = *table::borrow(&from_balance_store.balances, coin_key);
        assert!(from_balance >= amount, error::invalid_argument(EINSUFFICIENT_BALANCE));
        // Update balances
        table::upsert(&mut from_balance_store.balances, coin_key, from_balance - amount);
        // table::upsert(&mut token_store, coin_key, Coin { value: from_balance.value - amount });
        assert!(is_account_registered(to, coin_key), error::not_found(ECOIN_STORE_NOT_PUBLISHED));
        let to_balance_store = borrow_global_mut<BalanceStore>(to);
        let to_balance = *table::borrow(&to_balance_store.balances, coin_key);
        table::upsert(&mut to_balance_store.balances, coin_key, to_balance + amount);
    }

    #[view]
    public fun get_coin_evm_address<CoinType>(): vector<u8> acquires CoinStore {
        assert!(is_coin_initialized(get_coin_key_by_type<CoinType>()), error::not_found(ECOIN_INFO_NOT_PUBLISHED));
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        table::borrow(&coin_store.coins, get_coin_key_by_type<CoinType>()).evm_address
    }

    #[view]
    public fun is_movement_coin<CoinType>(): bool acquires CoinStore {
        is_coin_initialized(get_coin_key_by_type<CoinType>())
    }

    #[view]
    /// Returns `true` if `account_addr` is registered to receive `CoinType`.
    public fun is_account_registered(account_addr: address, coin_key: vector<u8>): bool acquires BalanceStore, CoinStore {
        if(!is_coin_initialized(coin_key) || !exists<BalanceStore>(account_addr)) {
            false
        } else {
            let balance_store = borrow_global<BalanceStore>(account_addr);
            table::contains(&balance_store.balances, coin_key)
        }
    }

    #[view]
    /// Returns `true` if the type `CoinType` is an initialized coin.
    public fun is_coin_initialized(coin_key: vector<u8>): bool acquires CoinStore {
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        table::contains(&coin_store.coins, coin_key)
    }

    #[view]
    /// Returns the balance of `owner` for provided `CoinType`.
    public fun balance(owner: address, coin_key: vector<u8>): u64 acquires CoinStore, BalanceStore {
        assert!(is_coin_initialized(coin_key), error::not_found(ECOIN_INFO_NOT_PUBLISHED));
        assert!(is_account_registered(owner, coin_key), error::not_found(ECOIN_STORE_NOT_PUBLISHED));

        let balance_store = borrow_global<BalanceStore>(owner);
        *table::borrow(&balance_store.balances, coin_key)
    }

    #[view]
    /// Returns the symbol of the coin, usually a shorter version of the name.
    public fun name(coin_key: vector<u8>): string::String acquires CoinStore {
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        table::borrow(&coin_store.coins, coin_key).name
    }

    #[view]
    /// Returns the symbol of the coin, usually a shorter version of the name.
    public fun symbol(coin_key: vector<u8>): string::String acquires CoinStore {
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        table::borrow(&coin_store.coins, coin_key).symbol
    }

    #[view]
    /// Returns the number of decimals used to get its user representation.
    /// For example, if `decimals` equals `2`, a balance of `505` coins should
    /// be displayed to a user as `5.05` (`505 / 10 ** 2`).
    public fun decimals(coin_key: vector<u8>): u8 acquires CoinStore {
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        table::borrow(&coin_store.coins, coin_key).decimals
    }

    #[view]
    /// Returns the amount of coin in existence.
    public fun supply(coin_key: vector<u8>): Option<u128> acquires CoinStore {
        let coin_store = borrow_global<CoinStore>(@aptos_framework);
        let supply = &(table::borrow(&coin_store.coins, coin_key).total_supply as u128);
        option::some(*supply)
    }

    #[view]
    public fun get_coin_key_by_wrap_evm(evm_addr: vector<u8>): vector<u8> acquires WrapEvmCoin {
        let wrap_evm_coins = borrow_global_mut<WrapEvmCoin>(@aptos_framework);
        if(table::contains(&wrap_evm_coins.info, evm_addr)) {
            *table::borrow(&wrap_evm_coins.info, evm_addr)
        } else {
            vector::empty<u8>()
        }
    }

    #[view]
    public fun get_coin_key_by_type<CoinType>(): vector<u8> {
        get_coin_key_by_info(type_of<CoinType>())
    }

    fun get_coin_key_by_info(info: TypeInfo): vector<u8> {
        let key = vector::empty<u8>();
        vector::append(&mut key, to_bytes(&account_address(&info)));
        vector::append(&mut key, to_bytes(&module_name(&info)));
        vector::append(&mut key, to_bytes(&struct_name(&info)));
        key
    }
}