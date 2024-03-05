module aptos_framework::tx_context {

    /// Information about the transaction currently being executed.
    /// This cannot be constructed by a transaction--it is a privileged object created by
    /// the VM and passed in to the entrypoint of the transaction as `&mut TxContext`.
    struct TxContext has drop {
        /// The address of the user that signed the current transaction
        sender: address,
        /// Hash of the current transaction
        tx_hash: vector<u8>,
        /// The current epoch number
        epoch: u64,
        /// Timestamp that the epoch started at
        epoch_timestamp_ms: u64,
        /// Counter recording the number of fresh id's created while executing
        /// this transaction. Always 0 at the start of a transaction
        ids_created: u64
    }

    /// Return the address of the user that signed the current
    /// transaction
    public fun sender(self: &TxContext): address {
        self.sender
    }

    public entry fun hello() {

    }

    /// Return the transaction digest (hash of transaction inputs).
    /// Please do not use as a source of randomness.
    public fun digest(self: &TxContext): &vector<u8> {
        &self.tx_hash
    }

    /// Return the current epoch
    public fun epoch(self: &TxContext): u64 {
        self.epoch
    }

    /// Return the epoch start time as a unix timestamp in milliseconds.
    public fun epoch_timestamp_ms(self: &TxContext): u64 {
       self.epoch_timestamp_ms
    }

    /// Create an `address` that has not been used. As it is an object address, it will never
    /// occur as the address for a user.
    /// In other words, the generated address is a globally unique object ID.
    public fun fresh_object_address(ctx: &mut TxContext): address {
        let ids_created = ctx.ids_created;
        let id = derive_id(*&ctx.tx_hash, ids_created);
        ctx.ids_created = ids_created + 1;
        id
    }

    fun ids_created(self: &TxContext): u64 {
        self.ids_created
    }

    /// Native function for deriving an ID via hash(tx_hash || ids_created)
    native fun derive_id(tx_hash: vector<u8>, ids_created: u64): address;


  
}