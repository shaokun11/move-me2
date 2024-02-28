module self::counter {
    // use sui::transfer;
    // use sui::object::{Self, UID};
    use sui::tx_context::{TxContext};

    /// A shared counter.
    struct Counter has key {
        // id: UID,
        owner: address,
        value: u64
    }

    // public fun owner(counter: &Counter): address {
    //     counter.owner
    // }

    // public fun value(counter: &Counter): u64 {
    //     counter.value
    // }

    /// Create and share a Counter object.
    public entry fun create(_ctx: &mut TxContext) {
        // transfer::share_object(Counter {
        //     id: object::new(ctx),
        //     owner: tx_context::sender(ctx),
        //     value: 0
        // })
    }

    // Increment a counter by 1.
    public entry fun increment(counter: &mut Counter) {
        counter.value = counter.value + 1;
    }

    // /// Set value (only runnable by the Counter owner)
    // public entry fun set_value(counter: &mut Counter, value: u64, ctx: &TxContext) {
    //     assert!(counter.owner == tx_context::sender(ctx), 0);
    //     counter.value = value;
    // }

    // /// Assert a value for the counter.
    // public entry fun assert_value(counter: &Counter, value: u64) {
    //     assert!(counter.value == value, 0)
    // }

    // /// Delete counter (only runnable by the Counter owner)
    // public entry fun delete(counter: Counter, ctx: &TxContext) {
    //     assert!(counter.owner == tx_context::sender(ctx), 0);
    //     let Counter {id, owner:_, value:_} = counter;
    //     object::delete(id);
    // }
}

