module batch_transfer::batch_transfer {
    use aptos_std::table::Table;

    /// adderess and amount size not match
    const SIZE_NOT_MATCH: u64 = 1;

    struct Account2 has copy {

    }

    struct Account has key {
        storage: Table<u256, Account2>,
    }


}