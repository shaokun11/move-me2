module aptos_framework::evm_log {
    use std::vector;
    use std::vector::for_each;

    friend aptos_framework::evm;

    struct Log has copy, drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topics: vector<vector<u8>>
    }

    struct LogContext has drop {
        checkpoints: vector<vector<Log>>
    }

    public(friend) fun init_logs(): LogContext {
        let log_context = LogContext {
            checkpoints: vector::empty()
        };
        vector::push_back(&mut log_context.checkpoints, vector::empty<Log>());
        log_context
    }

    public(friend) fun add_log(log_context: &mut LogContext, contract: vector<u8>, data: vector<u8>, topics: vector<vector<u8>>) {
        let len = vector::length(&log_context.checkpoints);
        let checkpoint = vector::borrow_mut(&mut log_context.checkpoints, len - 1);
        vector::push_back(checkpoint, Log {
            contract,
            data,
            topics
        });
    }

    public(friend) fun add_checkpoint(log_context: &mut LogContext) {
        vector::push_back(&mut log_context.checkpoints, vector::empty<Log>());
    }

    public fun get_logs(log_context: &mut LogContext): vector<Log> {
        let len = vector::length(&log_context.checkpoints);
        *vector::borrow(&mut log_context.checkpoints, len - 1)
    }

    public(friend) fun commit(log_context: &mut LogContext) {
        let data = vector::pop_back(&mut log_context.checkpoints);
        let len = vector::length(&log_context.checkpoints);
        let checkpoint = vector::borrow_mut(&mut log_context.checkpoints, len - 1);
        for_each(data, |elem| vector::push_back(checkpoint, elem));
    }

    public(friend) fun revert(log_context: &mut LogContext) {
        vector::pop_back(&mut log_context.checkpoints);
    }
}