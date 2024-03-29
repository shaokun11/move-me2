module sui_on_aptos::counter {
    use aptos_framework::tx_context::{TxContext};
    use aptos_framework::sui_transfer;
    use aptos_framework::sui_object;
    use aptos_framework::sui_object::UID;
    use aptos_framework::tx_context;

    struct Counter has key {
        id: UID,
        owner: address,
        value: u64
    }

    /// Create and share a Counter object.
    public entry fun create(value: u64, ctx: &mut TxContext) {
        sui_transfer::share_object(Counter {
            id: sui_object::new(ctx),
            owner: tx_context::sender(ctx),
            value
        });
    }

    /// Create and share a Counter object.
    public entry fun create2(signer: &signer, value: u64, ctx: &mut TxContext) {
        move_to(signer, Counter {
            id: sui_object::new(ctx),
            owner: tx_context::sender(ctx),
            value
        });
    }

    /// Increment a counter by 1.
    public entry fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    /// Set value (only runnable by the Counter owner)
    public entry fun set_value(counter: &mut Counter, value: u64, ctx: &TxContext) {
        assert!(counter.owner == tx_context::sender(ctx), 0);
        counter.value = value;
    }

    #[view]
    public fun get_value(addr: address): u64 acquires Counter {
        borrow_global<Counter>(addr).value
    }

    #[view]
    public fun exist(addr: address): bool {
        exists<Counter>(addr)
    }
}
