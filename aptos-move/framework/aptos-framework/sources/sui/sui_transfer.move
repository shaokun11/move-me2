module aptos_framework::sui_transfer {

    use aptos_framework::sui_object;
    use aptos_framework::create_signer::create_signer;
    use std::bcs;

    const SHARED_MODALITY: u64 = 1;

    struct Object has key {
        owner: address,
        data: vector<u8>
    }

    /// Turn the given object into a mutable shared object that everyone can access and mutate.
    /// This is irreversible, i.e. once an object is shared, it will stay shared forever.
    /// Aborts with `ESharedNonNewObject` of the object being shared was not created in this
    /// transaction. This restriction may be relaxed in the future.
    /// This function has custom rules performed by the Sui Move bytecode verifier that ensures
    /// that `T` is an object defined in the module where `share_object` is invoked. Use
    /// `public_share_object` to share an object with `store` outside of its module.
    public fun share_object<T: key>(obj: T) {
        // let data = bcs::to_bytes<T>(&obj);
        // let uid = sui_object::id(&obj);
        // let owner = sui_object::id_to_address(&uid);
        //
        // if(!exists<Object>(@0x123)) {
        //     move_to(&create_signer(@0x123), Object {
        //         owner,
        //         data,
        //     });
        // };

        share_object_impl(obj);
    }

    #[view]
    public fun get_object(addr: address): vector<u8> acquires Object {
        borrow_global<Object>(addr).data
    }

    public(friend) native fun share_object_impl<T: key>(obj: T);
}