module aptos_framework::sui_object {
    use aptos_framework::tx_context::TxContext;
    use aptos_framework::tx_context;

    struct ID has copy, drop, store {
        bytes: address
    }

    struct UID has store {
        id: ID,
    }

    /// Get the inner bytes of `id` as an address.
    public fun uid_to_address(uid: &UID): address {
        uid.id.bytes
    }

    public fun new(ctx: &mut TxContext): UID {
        UID {
            id: ID { bytes: tx_context::fresh_object_address(ctx) },
        }
    }

    public fun id<T: key>(obj: &T): ID {
        borrow_uid(obj).id
    }

    /// Get the inner bytes of `id` as an address.
    public fun id_to_address(id: &ID): address {
        id.bytes
    }

    /// Get the `UID` for `obj`.
    /// Safe because Sui has an extra bytecode verifier pass that forces every struct with
    /// the `key` ability to have a distinguished `UID` field.
    /// Cannot be made public as the access to `UID` for a given object must be privileged, and
    /// restrictable in the object's module.
    native fun borrow_uid<T: key>(obj: &T): &UID;

    #[test_only]
    /// Return the most recent created object ID.
    public fun last_created(ctx: &TxContext): ID {
        ID { bytes: tx_context::last_created_object_id(ctx) }
    }
}