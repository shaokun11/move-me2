module aptos_framework::counter {
    use aptos_framework::tx_context::{TxContext};
    use aptos_framework::sui_transfer;
    use aptos_framework::sui_object;
    use aptos_framework::sui_object::UID;
    use aptos_framework::tx_context;
    #[test_only]
    use aptos_std::debug;
    #[test_only]
    use aptos_framework::sui_transfer::get_object;

    struct Counter has key {
        id: UID,
        owner: address,
        value: u64
    }

    /// Create and share a Counter object.
    public entry fun create(ctx: &mut TxContext) {
        sui_transfer::share_object(Counter {
            id: sui_object::new(ctx),
            owner: tx_context::sender(ctx),
            value: 0
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

    #[test]
    public fun test() {
        create(&mut tx_context::new_from_hint(@0x123, 0, 0, 0, 0));
        debug::print(&get_object(@0x123));
    }
}
