module sui_on_aptos::counter {

    use aptos_framework::sui_transfer;
    use aptos_framework::sui_object::{Self, UID};
    use aptos_framework::tx_context::{Self, TxContext};


    struct Counter has key {
        id: UID,
        owner: address,
        value: u64
    }

    public fun owner(counter: &Counter): address {
        counter.owner
    }

    public fun value(counter: &Counter): u64 {
        counter.value
    }

    /// Create and share a Counter object.
    public entry fun create(val: u64, ctx: &mut TxContext) {
        sui_transfer::share_object(Counter {
            id: sui_object::new(ctx),
            owner: tx_context::sender(ctx),
            value: val
        })
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

    /// Assert a value for the counter.
    public entry fun assert_value(counter: &Counter, value: u64) {
        assert!(counter.value == value, 0)
    }
}
