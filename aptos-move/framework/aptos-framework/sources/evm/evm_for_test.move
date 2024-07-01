module aptos_framework::evm_for_test {
    use aptos_framework::account::{new_event_handle};
    use std::vector;
    use aptos_std::aptos_hash::keccak256;
    use aptos_std::debug;
    use aptos_framework::evm_util::{to_32bit, get_contract_address, to_int256, data_to_u256, u256_to_data, mstore, copy_to_memory, to_u256, get_valid_jumps, expand_to_pos, vector_slice};
    use aptos_framework::timestamp::now_microseconds;
    use aptos_framework::block;
    use std::string::utf8;
    use aptos_framework::event::EventHandle;
    use aptos_framework::precompile::{is_precompile_address, run_precompile};
    use aptos_std::simple_map;
    use aptos_std::simple_map::SimpleMap;
    use aptos_framework::evm_global_state::{new_run_state, get_gas_usage, add_gas_usage, get_gas_refund, RunState, add_call_state, revert_call_state, commit_call_state};
    use aptos_framework::evm_gas::{calc_exec_gas, calc_base_gas, max_call_gas};
    use aptos_framework::event;
    #[test_only]
    use aptos_framework::account::create_account_for_test;
    use aptos_framework::evm_arithmetic::{add, mul, sub, div, sdiv, mod, smod, add_mod, mul_mod, exp, shr, sar};
    use aptos_framework::evm_trie::{pre_init, Trie, add_checkpoint, revert_checkpoint, commit_latest_checkpoint, TestAccount, get_code, sub_balance, add_nonce, transfer, get_balance, get_state, set_state, exist_contract, get_nonce, new_account, get_storage_copy, save};
    friend aptos_framework::genesis;

    const ADDR_LENGTH: u64 = 10001;
    const SIGNATURE: u64 = 10002;
    const INSUFFIENT_BALANCE: u64 = 10003;
    const NONCE: u64 = 10004;
    const CONTRACT_READ_ONLY: u64 = 10005;
    const CONTRACT_DEPLOYED: u64 = 10006;
    const TX_NOT_SUPPORT: u64 = 10007;
    const ACCOUNT_NOT_EXIST: u64 = 10008;
    /// invalid chain id in raw tx
    const INVALID_CHAINID: u64 = 10009;
    const CONVERT_BASE: u256 = 10000000000;
    const CHAIN_ID: u64 = 0x150;

    const U256_MAX: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    const ZERO_ADDR: vector<u8> =      x"0000000000000000000000000000000000000000000000000000000000000000";
    const ONE_ADDR: vector<u8> =       x"0000000000000000000000000000000000000000000000000000000000000001";
    const CHAIN_ID_BYTES: vector<u8> = x"0150";

    /// invalid pc
    const EVM_ERROR_INVALID_PC: u64 = 10000001;
    /// invalid pop stack
    const EVM_ERROR_POP_STACK: u64 = 10000002;

    struct ExecResource has key {
        exec_event: EventHandle<ExecResultEvent>
    }

    struct ExecResultEvent has drop, store {
        gas_usage: u256,
        gas_refund: u256,
        state_root: vector<u8>
    }

    struct Log0Event has drop, store {
        contract: vector<u8>,
        data: vector<u8>
    }

    struct Log1Event has drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topic0: vector<u8>
    }

    struct Log2Event has drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topic0: vector<u8>,
        topic1: vector<u8>
    }

    struct Log3Event has drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topic0: vector<u8>,
        topic1: vector<u8>,
        topic2: vector<u8>
    }

    struct Log4Event has drop, store {
        contract: vector<u8>,
        data: vector<u8>,
        topic0: vector<u8>,
        topic1: vector<u8>,
        topic2: vector<u8>,
        topic3: vector<u8>
    }

    struct ContractEvent has key {
        log0Event: EventHandle<Log0Event>,
        log1Event: EventHandle<Log1Event>,
        log2Event: EventHandle<Log2Event>,
        log3Event: EventHandle<Log3Event>,
        log4Event: EventHandle<Log4Event>,
    }

    native fun revert(
        message: vector<u8>
    );

    native fun calculate_root(
        trie: SimpleMap<vector<u8>, TestAccount>
    ): vector<u8>;

    public(friend) fun initialize(aptos_framework: &signer) {
        move_to<ExecResource>(aptos_framework, ExecResource {
            exec_event: new_event_handle<ExecResultEvent>(aptos_framework)
        });
    }

    fun emit_event(state_root: vector<u8>, gas_usage: u256, gas_refund: u256) acquires ExecResource {
        let exec_resource = borrow_global_mut<ExecResource>(@aptos_framework);
        debug::print(&state_root);
        debug::print(&gas_usage);
        debug::print(&gas_refund);
        event::emit_event(&mut exec_resource.exec_event, ExecResultEvent {
            state_root,
            gas_usage,
            gas_refund
        });
    }

    public entry fun run_test(addresses: vector<vector<u8>>,
                              codes: vector<vector<u8>>,
                              nonces: vector<u64>,
                              balances: vector<vector<u8>>,
                              storage_keys: vector<vector<vector<u8>>>,
                              storage_values: vector<vector<vector<u8>>>,
                              from: vector<u8>,
                              to: vector<u8>,
                              data: vector<u8>,
                              gas_limit_bytes: vector<u8>,
                              gas_price_bytes:vector<u8>,
                              value_bytes: vector<u8>) acquires ExecResource {
        let value = to_u256(value_bytes);
        let trie = &mut pre_init(addresses, codes, nonces, balances, storage_keys, storage_values);
        let transient = simple_map::new<u256, u256>();
        let gas_price = to_u256(gas_price_bytes);
        let gas_limit = to_u256(gas_limit_bytes);
            from = to_32bit(from);
        to = to_32bit(to);
        // debug::print(&trie);
        let run_state = &mut new_run_state();
        let base_cost = calc_base_gas(&data) + 21000;
        add_gas_usage(run_state, base_cost);
        run(from, from, to, get_code(to, trie), data, value, gas_limit - base_cost, trie, &mut transient, run_state, true);
        let gas_refund = get_gas_refund(run_state);
        let gas_usage = get_gas_usage(run_state);
        let gasfee = gas_price * (gas_usage - gas_refund);
        sub_balance(from, gasfee, trie);
        add_nonce(from, trie);

        save(trie);
        let state_root = calculate_root(get_storage_copy(trie));
        let exec_cost = gas_usage - base_cost;
        // debug::print(checkpoint);
        debug::print(&exec_cost);
        emit_event(state_root, gas_usage, gas_refund);
    }

    fun handle_revert(gas_limit: u256, gas_used: &mut u256, trie: &mut Trie, run_state: &mut RunState) {
        *gas_used = gas_limit;
        add_gas_usage(run_state, *gas_used);
        revert_checkpoint(trie);
        revert_call_state(run_state);
    }

    fun handle_commit(gas_used: u256, trie: &mut Trie, run_state: &mut RunState) {
        add_gas_usage(run_state, gas_used);
        commit_latest_checkpoint(trie);
        commit_call_state(run_state);
    }


    fun run(
            origin: vector<u8>,
            sender: vector<u8>,
            to: vector<u8>,
            code: vector<u8>,
            data: vector<u8>,
            value: u256,
            gas_limit: u256,
            trie: &mut Trie,
            transient: &mut SimpleMap<u256, u256>,
            run_state: &mut RunState,
            transfer_eth: bool
        ): (bool, vector<u8>) {

        if (is_precompile_address(to)) {
            return (true, precompile(to, data))
        };

        add_checkpoint(trie);
        add_call_state(run_state);
        if(transfer_eth) {
            transfer(sender, to, value, trie);
        };


        // let to_account = simple_map::borrow_mut(&mut trie, &to);

        let stack = &mut vector::empty<u256>();
        let memory = &mut vector::empty<u8>();
        let len = (vector::length(&code) as u256);
        let i: u256 = 0;
        let runtime_code = vector::empty<u8>();
        let ret_bytes = vector::empty<u8>();
        let error_code = &mut 0;
        let gas_used = 0;
        let valid_jumps = get_valid_jumps(&code);

        let _events = simple_map::new<u256, vector<u8>>();
        // let gas = 21000;
        while (i < len) {
            // Fetch the current opcode from the bytecode.
            let opcode: u8 = *vector::borrow(&code, (i as u64));
            gas_used = gas_used + calc_exec_gas(opcode, to, stack, run_state, trie, gas_limit);
            if(gas_used >= gas_limit) {
                handle_revert(gas_limit, &mut gas_used, trie, run_state);
                return (false, ret_bytes)
            };
            // debug::print(&i);
            // debug::print(&opcode);
            // debug::print(&gas_used);

            // Handle each opcode according to the EVM specification.
            // The following is a simplified version of the EVM execution engine,
            // handling only a subset of all possible opcodes.
            // Each branch in this if-else chain corresponds to a specific opcode,
            // and contains the logic for executing that opcode.
            // For example, the `add` opcode pops two elements from the stack,
            // adds them together, and pushes the result back onto the stack.
            // The `mul` opcode does the same but with multiplication, and so on.
            // Some opcodes, like `sstore`, have side effects, such as modifying contract storage.
            // The `jump` and `jumpi` opcodes alter the control flow of the execution.
            // The `call`, `create`, and `create2` opcodes are used for contract interactions.
            // The `log` opcodes are used for emitting events.
            // The function returns the output data of the execution when it encounters the `stop` or `return` opcode.

            // stop
            if(opcode == 0x00) {
                ret_bytes = runtime_code;
                break
            }
            else if(opcode == 0xf3) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                ret_bytes = vector_slice(*memory, pos, len);
                // debug::print(&ret_bytes);
                break
            }
                //add
            else if(opcode == 0x01) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, add(a, b));
                i = i + 1;
            }
                //mul
            else if(opcode == 0x02) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, mul(a, b));
                i = i + 1;
            }
                //sub
            else if(opcode == 0x03) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, sub(a, b));
                i = i + 1;
            }
                //div
            else if(opcode == 0x04) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, div(a, b));
                i = i + 1;
            }
                //sdiv
            else if(opcode == 0x05) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, sdiv(a, b));
                i = i + 1;
            }
                //mod
            else if(opcode == 0x06) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, mod(a, b));
                i = i + 1;
            }
                //smod
            else if(opcode == 0x07) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, smod(a, b));
                i = i + 1;
            }
                //addmod
            else if(opcode == 0x08) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                let n = pop_stack(stack, error_code);
                vector::push_back(stack, add_mod(a, b, n));
                i = i + 1;
            }
                //mulmod
            else if(opcode == 0x09) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                let n = pop_stack(stack, error_code);
                vector::push_back(stack, mul_mod(a, b, n));
                i = i + 1;
            }
                //exp
            else if(opcode == 0x0a) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, exp(a, b));
                i = i + 1;
            }
                //signextend
            else if(opcode == 0x0b) {
                let b = pop_stack(stack, error_code);
                let value = pop_stack(stack, error_code);
                if(b > 31) {
                    vector::push_back(stack, value);
                } else {
                    let index = ((8 * b + 7) as u8);
                    let mask = (1 << index) - 1;
                    if(((value >> index) & 1) == 0) {
                        vector::push_back(stack, value & mask);
                    } else {
                        vector::push_back(stack, value | (U256_MAX - mask));
                    };
                };
                i = i + 1;
            }
                //lt
            else if(opcode == 0x10) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                if(a < b) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //gt
            else if(opcode == 0x11) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                if(a > b) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //slt
            else if(opcode == 0x12) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                let(neg_a, num_a) = to_int256(a);
                let(neg_b, num_b) = to_int256(b);

                let is_positive_lt = num_a < num_b && !(neg_a || neg_b);
                let is_negative_lt = num_a > num_b && (neg_a && neg_b);
                let has_different_signs = neg_a && !neg_b;

                let value = 0;
                if(is_positive_lt || is_negative_lt || has_different_signs) {
                    value = 1
                };
                vector::push_back(stack, value);
                i = i + 1;
            }
                //sgt
            else if(opcode == 0x13) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                let(neg_a, num_a) = to_int256(a);
                let(neg_b, num_b) = to_int256(b);

                let is_positive_gt = num_a > num_b && !(neg_a || neg_b);
                let is_negative_gt = num_a < num_b && (neg_a && neg_b);
                let has_different_signs = !neg_a && neg_b;
                let value = 0;
                if(is_positive_gt || is_negative_gt || has_different_signs) {
                    value = 1
                };
                vector::push_back(stack, value);
                i = i + 1;
            }
                //eq
            else if(opcode == 0x14) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                if(a == b) {
                    vector::push_back(stack, 1);
                } else {
                    vector::push_back(stack, 0);
                };
                i = i + 1;
            }
                //and
            else if(opcode == 0x16) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, a & b);
                i = i + 1;
            }
                //or
            else if(opcode == 0x17) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, a | b);
                i = i + 1;
            }
                //xor
            else if(opcode == 0x18) {
                let a = pop_stack(stack, error_code);
                let b = pop_stack(stack, error_code);
                vector::push_back(stack, a ^ b);
                i = i + 1;
            }
                //not
            else if(opcode == 0x19) {
                // 10 1010
                // 6 0101
                let n = pop_stack(stack, error_code);
                vector::push_back(stack, U256_MAX - n);
                i = i + 1;
            }
                //byte
            else if(opcode == 0x1a) {
                let ith = pop_stack(stack, error_code);
                let x = pop_stack(stack, error_code);
                if(ith >= 32) {
                    vector::push_back(stack, 0);
                } else {
                    vector::push_back(stack, (x >> ((248 - ith * 8) as u8)) & 0xFF);
                };

                i = i + 1;
            }
                //shl
            else if(opcode == 0x1b) {
                let b = pop_stack(stack, error_code);
                let a = pop_stack(stack, error_code);
                if(b >= 256) {
                    vector::push_back(stack, 0);
                } else {
                    vector::push_back(stack, a << (b as u8));
                };
                i = i + 1;
            }
                //shr
            else if(opcode == 0x1c) {
                let b = pop_stack(stack, error_code);
                let a = pop_stack(stack, error_code);
                vector::push_back(stack, shr(a, b));

                i = i + 1;
            }
                //sar
            else if(opcode == 0x1d) {
                let b = pop_stack(stack, error_code);
                let a = pop_stack(stack, error_code);
                vector::push_back(stack, sar(a, b));
                i = i + 1;
            }
                //push0
            else if(opcode == 0x5f) {
                vector::push_back(stack, 0);
                i = i + 1;
            }
                // push1 -> push32
            else if(opcode >= 0x60 && opcode <= 0x7f)  {
                let n = ((opcode - 0x60) as u256);
                let number = data_to_u256(code, i + 1, n + 1);
                vector::push_back(stack, number);
                i = i + n + 2;
            }
                // pop
            else if(opcode == 0x50) {
                pop_stack(stack, error_code);
                i = i + 1
            }
                //address
            else if(opcode == 0x30) {
                vector::push_back(stack, data_to_u256(to, 0, 32));
                i = i + 1;
            }
                //balance
            else if(opcode == 0x31) {
                let target = vector_slice(u256_to_data(pop_stack(stack, error_code)), 12, 20);
                get_balance(to_32bit(target), trie);
                i = i + 1;
            }
                //origin
            else if(opcode == 0x32) {
                let value = data_to_u256(origin, 0, 32);
                vector::push_back(stack, value);
                i = i + 1;
            }
                //caller
            else if(opcode == 0x33) {
                let value = data_to_u256(sender, 0, 32);
                vector::push_back(stack, value);
                i = i + 1;
            }
                // callvalue
            else if(opcode == 0x34) {
                vector::push_back(stack, value);
                i = i + 1;
            }
                //calldataload
            else if(opcode == 0x35) {
                let pos = pop_stack(stack, error_code);
                vector::push_back(stack, data_to_u256(data, pos, 32));
                i = i + 1;
            }
                //calldatasize
            else if(opcode == 0x36) {
                vector::push_back(stack, (vector::length(&data) as u256));
                i = i + 1;
            }
                //calldatacopy
            else if(opcode == 0x37) {
                let m_pos = pop_stack_u64(stack, error_code);
                let d_pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let end = d_pos + len;
                // debug::print(&utf8(b"calldatacopy"));
                // debug::print(&data);
                while (d_pos < end) {
                    // debug::print(&d_pos);
                    // debug::print(&end);
                    let bytes = if(end - d_pos >= 32) {
                        vector_slice(data, d_pos, 32)
                    } else {
                        vector_slice(data, d_pos, end - d_pos)
                    };
                    // debug::print(&bytes);
                    mstore(memory, m_pos, bytes);
                    d_pos = d_pos + 32;
                    m_pos = m_pos + 32;
                };
                i = i + 1
            }
                //codesize
            else if(opcode == 0x38) {
                vector::push_back(stack, (vector::length(&code) as u256));
                i = i + 1
            }
                //codecopy
            else if(opcode == 0x39) {
                let m_pos = pop_stack_u64(stack, error_code);
                let d_pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                runtime_code = vector_slice(code, d_pos, d_pos + len);
                copy_to_memory(memory, m_pos, d_pos, len, code);
                i = i + 1
            }
                //extcodesize
            else if(opcode == 0x3b) {
                let target = vector_slice(u256_to_data(pop_stack(stack, error_code)), 12, 20);
                let code = get_code(to_32bit(target), trie);
                vector::push_back(stack, (vector::length(&code) as u256));
                i = i + 1;
            }
                //extcodecopy
            else if(opcode == 0x3c) {
                let target = vector_slice(u256_to_data(pop_stack(stack, error_code)), 12, 20);
                let code = get_code(to_32bit(target), trie);
                let m_pos = pop_stack_u64(stack, error_code);
                let d_pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                copy_to_memory(memory, m_pos, d_pos, len, code);
                i = i + 1;
            }
                //returndatacopy
            else if(opcode == 0x3e) {
                // mstore()
                let m_pos = pop_stack_u64(stack, error_code);
                let d_pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let bytes = vector_slice(ret_bytes, d_pos, len);
                mstore(memory, m_pos, bytes);
                i = i + 1;
            }
                //returndatasize
            else if(opcode == 0x3d) {
                vector::push_back(stack, (vector::length(&ret_bytes) as u256));
                i = i + 1;
            }
                //blockhash
            else if(opcode == 0x40) {
                vector::push_back(stack, 0);
                i = i + 1;
            }
                //coinbase
            else if(opcode == 0x41) {
                vector::push_back(stack, 0);
                i = i + 1;
            }
                //timestamp
            else if(opcode == 0x42) {
                vector::push_back(stack, (now_microseconds() as u256) / 1000000);
                i = i + 1;
            }
                //number
            else if(opcode == 0x43) {
                vector::push_back(stack, (block::get_current_block_height() as u256));
                i = i + 1;
            }
                //difficulty
            else if(opcode == 0x44) {
                vector::push_back(stack, 0);
                i = i + 1;
            }
                //gaslimit
            else if(opcode == 0x45) {
                vector::push_back(stack, 30000000);
                i = i + 1;
            }
                //chainid
            else if(opcode == 0x46) {
                vector::push_back(stack, 1);
                i = i + 1
            }
                //self balance
            else if(opcode == 0x47) {
                vector::push_back(stack, get_balance(to, trie));
                i = i + 1;
            }
                // mload
            else if(opcode == 0x51) {
                let pos = pop_stack_u64(stack, error_code);
                vector::push_back(stack, data_to_u256(vector_slice(*memory, pos, 32), 0, 32));
                i = i + 1;
            }
                // mstore
            else if(opcode == 0x52) {
                let pos = pop_stack_u64(stack, error_code);
                let value = pop_stack(stack, error_code);
                mstore(memory, pos, u256_to_data(value));
                i = i + 1;

            }
                //mstore8
            else if(opcode == 0x53) {
                let pos = pop_stack_u64(stack, error_code);
                let value = pop_stack(stack, error_code);
                expand_to_pos(memory, pos + 1);
                *vector::borrow_mut(memory, pos) = ((value & 0xff) as u8);
                // mstore(memory, pos, u256_to_data(value & 0xff));
                i = i + 1;

            }
                // sload
            else if(opcode == 0x54) {
                let key = pop_stack(stack, error_code);
                vector::push_back(stack, get_state(to, key, trie));
                i = i + 1;
            }
                // sstore
            else if(opcode == 0x55) {
                let key = pop_stack(stack, error_code);
                let value = pop_stack(stack, error_code);
                set_state(to, key, value, trie);
                i = i + 1;
            }
                // pc
            else if(opcode == 0x58) {
                vector::push_back(stack, i);
                i = i + 1;
            }

                // MSIZE
            else if(opcode == 0x59) {
                vector::push_back(stack, (((vector::length(memory) + 31) / 32 * 32) as u256));
                i = i + 1;
            }
                //dup1 -> dup16
            else if(opcode >= 0x80 && opcode <= 0x8f) {
                let size = vector::length(stack);
                let value = *vector::borrow(stack, size - ((opcode - 0x80 + 1) as u64));
                vector::push_back(stack, value);
                i = i + 1;
            }
                //swap1 -> swap16
            else if(opcode >= 0x90 && opcode <= 0x9f) {
                let size = vector::length(stack);
                vector::swap(stack, size - 1, size - ((opcode - 0x90 + 2) as u64));
                i = i + 1;
            }
                //iszero
            else if(opcode == 0x15) {
                let value = pop_stack(stack, error_code);
                if(value == 0) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //jump
            else if(opcode == 0x56) {
                i = pop_stack(stack, error_code);
                if(i >= len || !*vector::borrow(&valid_jumps, (i as u64))) {
                    *error_code = EVM_ERROR_INVALID_PC;
                }
            }
                //jumpi
            else if(opcode == 0x57) {
                let dest = pop_stack(stack, error_code);
                let condition = pop_stack(stack, error_code);
                if(condition > 0) {
                    i = dest;
                    if(i >= len || !*vector::borrow(&valid_jumps, (i as u64))) {
                        *error_code = EVM_ERROR_INVALID_PC;
                    }
                } else {
                    i = i + 1
                };
            }
                //gas
            else if(opcode == 0x5a) {
                vector::push_back(stack, gas_limit - gas_used);
                i = i + 1
            }
                //jump dest (no action, continue execution)
            else if(opcode == 0x5b) {
                i = i + 1
            }
                //TLOAD
            else if(opcode == 0x5c) {
                let key = pop_stack(stack, error_code);
                if(simple_map::contains_key(transient, &key)) {
                    vector::push_back(stack, *simple_map::borrow(transient, &key));
                } else {
                    vector::push_back(stack, 0);
                };

                i = i + 1
            }
                //TSTORE
            else if(opcode == 0x5d) {
                let key = pop_stack(stack, error_code);
                let value = pop_stack(stack, error_code);
                simple_map::upsert(transient, key, value);
                i = i + 1
            }
                //MCOPY
            else if(opcode == 0x5e) {
                let m_pos = pop_stack_u64(stack, error_code);
                let d_pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let bytes = vector_slice(*memory, d_pos, len);
                mstore(memory, m_pos, bytes);
                i = i + 1;
            }
                //sha3
            else if(opcode == 0x20) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let bytes = vector_slice(*memory, pos, len);
                // debug::print(&value);
                let value = data_to_u256(keccak256(bytes), 0, 32);
                vector::push_back(stack, value);
                i = i + 1
            }
                //call 0xf1 static call 0xfa delegate call 0xf4
            else if(opcode == 0xf1 || opcode == 0xfa || opcode == 0xf4) {
                let gas_left = gas_limit - gas_used;
                let call_gas_limit = max_call_gas(gas_left, pop_stack(stack, error_code));
                let evm_dest_addr = to_32bit(u256_to_data(pop_stack(stack, error_code)));
                // let move_dest_addr = create_resource_address(&@aptos_framework, evm_dest_addr);
                let msg_value = if (opcode == 0xf1) pop_stack(stack, error_code) else if(opcode == 0xf4) value else 0;
                let m_pos = pop_stack_u64(stack, error_code);
                let m_len = pop_stack_u64(stack, error_code);
                let ret_pos = pop_stack_u64(stack, error_code);
                let ret_len = pop_stack_u64(stack, error_code);
                let ret_end = ret_len + ret_pos;
                let params = vector_slice(*memory, m_pos, m_len);
                let transfer_eth = if (opcode == 0xf1) true else false;

                // debug::print(&utf8(b"call 222"));
                // debug::print(&call_gas_limit);

                // debug::print(&dest_addr);
                if (is_precompile_address(evm_dest_addr) || exist_contract(evm_dest_addr, trie)) {
                    let dest_code = get_code(evm_dest_addr, trie);
                    let target = if (opcode == 0xf4) to else evm_dest_addr;
                    let from = if (opcode == 0xf4) sender else to;

                    let (call_res, bytes) = run(sender, from, target, dest_code, params, msg_value, call_gas_limit, trie, transient, run_state, transfer_eth);
                    ret_bytes = bytes;
                    let index = 0;

                    while (ret_pos < ret_end) {
                        let bytes = if (ret_end - ret_pos >= 32) {
                            vector_slice(bytes, index, 32)
                        } else {
                            vector_slice(bytes, index, ret_end - ret_pos)
                        };
                        mstore(memory, ret_pos, bytes);
                        ret_pos = ret_pos + 32;
                        index = index + 32;
                    };
                    vector::push_back(stack,  if(call_res) 1 else 0);
                } else {
                    vector::push_back(stack, 1);
                };
                // debug::print(&opcode);
                i = i + 1
            }
                //create
            else if(opcode == 0xf0) {
                let msg_value = pop_stack(stack, error_code);
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let new_codes = vector_slice(*memory, pos, len);
                // let contract_store = borrow_global_mut<Account>(move_contract_address);
                let nonce = get_nonce(to, trie);
                // must be 20 bytes

                let new_evm_contract_addr = get_contract_address(to, (nonce as u64));
                debug::print(&utf8(b"create start"));
                add_nonce(to, trie);

                let(create_res, bytes) = run(sender, to, new_evm_contract_addr, new_codes, x"", msg_value, gas_limit, trie, transient, run_state, true);
                if(create_res) {
                    new_account(new_evm_contract_addr, bytes, 0, 1, trie);
                    ret_bytes = new_evm_contract_addr;
                    vector::push_back(stack, data_to_u256(new_evm_contract_addr, 0, 32));
                } else {
                    ret_bytes = bytes;
                    vector::push_back(stack, 0);
                };

                // debug::print(&utf8(b"create end"));


                i = i + 1
            }
                //create2
            else if(opcode == 0xf5) {
                let msg_value = pop_stack(stack, error_code);
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let salt = u256_to_data(pop_stack(stack, error_code));
                let new_codes = vector_slice(*memory, pos, len);
                let p = vector::empty<u8>();
                // let contract_store = ;
                vector::append(&mut p, x"ff");
                // must be 20 bytes
                vector::append(&mut p, vector_slice(to, 12, 20));
                vector::append(&mut p, salt);
                vector::append(&mut p, keccak256(new_codes));
                let new_evm_contract_addr = to_32bit(vector_slice(keccak256(p), 12, 20));

                // to_account.nonce = to_account.nonce + 1;
                add_nonce(to, trie);
                let (create_res, bytes) = run(to, sender, new_evm_contract_addr, new_codes, x"", msg_value, gas_limit, trie, transient, run_state, true);

                if(create_res) {
                    new_account(new_evm_contract_addr, bytes, 0, 1, trie);

                    ret_bytes = new_evm_contract_addr;
                    vector::push_back(stack, data_to_u256(new_evm_contract_addr, 0, 32));
                } else {
                    ret_bytes = bytes;
                    vector::push_back(stack, 0);
                };
                i = i + 1
            }
                //revert
            else if(opcode == 0xfd) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let bytes = vector_slice(*memory, pos, len);
                debug::print(&utf8(b"revert"));
                debug::print(&bytes);
                revert(bytes);
            }
                //log0
            else if(opcode == 0xa0) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let _data = vector_slice(*memory, pos, len);
                // let event_store = borrow_global_mut<ContractEvent>(move_contract_address);
                // event::emit_event<Log0Event>(
                //     &mut event_store.log0Event,
                //     Log0Event{
                //         contract: evm_contract_address,
                //         data,
                //     },
                // );
                i = i + 1
            }
                //log1
            else if(opcode == 0xa1) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let _data = vector_slice(*memory, pos, len);
                let _topic0 = u256_to_data(pop_stack(stack, error_code));
                // let event_store = borrow_global_mut<ContractEvent>(move_contract_address);
                // event::emit_event<Log1Event>(
                //     &mut event_store.log1Event,
                //     Log1Event{
                //         contract: evm_contract_address,
                //         data,
                //         topic0,
                //     },
                // );
                i = i + 1
            }
                //log2
            else if(opcode == 0xa2) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let _data = vector_slice(*memory, pos, len);
                let _topic0 = u256_to_data(pop_stack(stack, error_code));
                let _topic1 = u256_to_data(pop_stack(stack, error_code));
                // let event_store = borrow_global_mut<ContractEvent>(move_contract_address);
                // event::emit_event<Log2Event>(
                //     &mut event_store.log2Event,
                //     Log2Event{
                //         contract: evm_contract_address,
                //         data,
                //         topic0,
                //         topic1
                //     },
                // );
                i = i + 1
            }
                //log3
            else if(opcode == 0xa3) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let _data = vector_slice(*memory, pos, len);
                let _topic0 = u256_to_data(pop_stack(stack, error_code));
                let _topic1 = u256_to_data(pop_stack(stack, error_code));
                let _topic2 = u256_to_data(pop_stack(stack, error_code));
                // let event_store = borrow_global_mut<ContractEvent>(move_contract_address);
                // event::emit_event<Log3Event>(
                //     &mut event_store.log3Event,
                //     Log3Event{
                //         contract: evm_contract_address,
                //         data,
                //         topic0,
                //         topic1,
                //         topic2
                //     },
                // );
                i = i + 1
            }
                //log4
            else if(opcode == 0xa4) {
                let pos = pop_stack_u64(stack, error_code);
                let len = pop_stack_u64(stack, error_code);
                let _data = vector_slice(*memory, pos, len);
                let _topic0 = u256_to_data(pop_stack(stack, error_code));
                let _topic1 = u256_to_data(pop_stack(stack, error_code));
                let _topic2 = u256_to_data(pop_stack(stack, error_code));
                let _topic3 = u256_to_data(pop_stack(stack, error_code));
                // let event_store = borrow_global_mut<ContractEvent>(move_contract_address);
                // event::emit_event<Log4Event>(
                //     &mut event_store.log4Event,
                //     Log4Event{
                //         contract: evm_contract_address,
                //         data,
                //         topic0,
                //         topic1,
                //         topic2,
                //         topic3
                //     },
                // );
                i = i + 1
            }
            else {
                assert!(false, (opcode as u64));
            };
            debug::print(stack);
            // debug::print(&vector::length(stack));

            if(*error_code > 0) {
                handle_revert(gas_limit, &mut gas_used, trie, run_state);
                return (false, ret_bytes)
            }
        };

        handle_commit(gas_used, trie, run_state);
        (true, ret_bytes)
    }


    // This function is used to execute precompile EVM contracts.
    fun precompile(to: vector<u8>, calldata: vector<u8>): vector<u8> {
        run_precompile(to, calldata, CHAIN_ID)
    }

    public fun pop_stack_u64(stack: &mut vector<u256>, error_code: &mut u64): u64 {
        if(vector::length(stack) > 0) {
            (vector::pop_back(stack) as u64)
        } else {
            *error_code = EVM_ERROR_POP_STACK;
            0
        }
    }

    public fun pop_stack(stack: &mut vector<u256>, error_code: &mut u64): u256 {
        if(vector::length(stack) > 0) {
            vector::pop_back(stack)
        } else {
            *error_code = EVM_ERROR_POP_STACK;
            0
        }
    }


    // fun add_balance(addr: address, amount: u256) acquires Account {
    //     create_account_if_not_exist(addr);
    //     if(amount > 0) {
    //         let account_store = borrow_global_mut<Account>(addr);
    //         account_store.balance = account_store.balance + amount;
    //     }
    // }

    // fun transfer_from_move_addr(signer: &signer, evm_to: vector<u8>, amount: u256) acquires Account {
    //     if(amount > 0) {
    //         let move_to = create_resource_address(&@aptos_framework, evm_to);
    //         create_account_if_not_exist(move_to);
    //         coin::transfer<AptosCoin>(signer, move_to, ((amount / CONVERT_BASE)  as u64));
    //
    //         let account_store_to = borrow_global_mut<Account>(move_to);
    //         account_store_to.balance = account_store_to.balance + amount;
    //     }
    // }

    // fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: ) acquires Account {
    //     if(amount > 0) {
    //         let move_from = create_resource_address(&@aptos_framework, evm_from);
    //         let move_to = create_resource_address(&@aptos_framework, evm_to);
    //         create_account_if_not_exist(move_to);
    //         let account_store_from = borrow_global_mut<Account>(move_from);
    //         assert!(account_store_from.balance >= amount, INSUFFIENT_BALANCE);
    //         account_store_from.balance = account_store_from.balance - amount;
    //
    //         let account_store_to = borrow_global_mut<Account>(move_to);
    //         account_store_to.balance = account_store_to.balance + amount;
    //
    //         let signer = create_signer(move_from);
    //         coin::transfer<AptosCoin>(&signer, move_to, ((amount / CONVERT_BASE)  as u64));
    //     }
    // }

    // fun transfer_to_move_addr(evm_from: vector<u8>, move_to: address, amount: u256) acquires Account {
    //     if(amount > 0) {
    //         let move_from = create_resource_address(&@aptos_framework, evm_from);
    //         let account_store_from = borrow_global_mut<Account>(move_from);
    //         assert!(account_store_from.balance >= amount, INSUFFIENT_BALANCE);
    //         account_store_from.balance = account_store_from.balance - amount;
    //
    //         let signer = create_signer(move_from);
    //         coin::transfer<AptosCoin>(&signer, move_to, ((amount / CONVERT_BASE)  as u64));
    //     }
    // }

    // fun create_event_if_not_exist(addr: address) {
    //     if(!exists<ContractEvent>(addr)) {
    //         let signer = create_signer(addr);
    //         move_to(&signer, ContractEvent {
    //             log0Event: new_event_handle<Log0Event>(&signer),
    //             log1Event: new_event_handle<Log1Event>(&signer),
    //             log2Event: new_event_handle<Log2Event>(&signer),
    //             log3Event: new_event_handle<Log3Event>(&signer),
    //             log4Event: new_event_handle<Log4Event>(&signer),
    //         })
    //     }
    // }

    fun create2_address(sender: vector<u8>, t1: vector<u8>, t2: vector<u8>, fee: u256, hash: vector<u8>): vector<u8> {
        let salt = vector::empty<u8>();
        vector::append(&mut salt, t1);
        vector::append(&mut salt, t2);
        vector::append(&mut salt, u256_to_data(fee));
        debug::print(&salt);
        let p = vector::empty<u8>();
        vector::append(&mut p, x"ff");
        // must be 20 bytes
        vector::append(&mut p, vector_slice(sender, 12, 20));
        vector::append(&mut p, keccak256(salt));
        vector::append(&mut p, hash);
        to_32bit(vector_slice(keccak256(p), 12, 20))
    }


    #[test_only]
    fun init_storage(keys: vector<u256>, values: vector<u256>): SimpleMap<vector<u8>, vector<u8>> {
        let i = 0;
        let len = vector::length(&keys);
        let map = simple_map::new<vector<u8>, vector<u8>>();
        while(i < len) {
            let key = *vector::borrow(&keys, i);
            let value = *vector::borrow(&values, i);
            simple_map::add(&mut map, u256_to_data(key), u256_to_data(value));
            i = i + 1;
        };

        map
    }

    #[test]
    public fun test_run() acquires ExecResource {
        // debug::print(&u256_to_data(0x0ba1a9ce0ba1a9ce));
        // let balance = u256_to_data(0x0ba1a9ce0ba1a9ce);
        let aptos_framework = create_account_for_test(@0x1);
        initialize(&aptos_framework);

        let storage_maps = simple_map::new<vector<u8>, simple_map::SimpleMap<vector<u8>, vector<u8>>>();
        simple_map::add(&mut storage_maps, x"cccccccccccccccccccccccccccccccccccccccc", init_storage(vector[0x00], vector[0x0bad]));
        let (storage_keys, storage_values) = (vector::empty<vector<vector<u8>>>(), vector::empty<vector<vector<u8>>>());


        let addresses = vector[
            x"0000000000000000000000000000000000000100",
            x"0000000000000000000000000000000000000101",
            x"0000000000000000000000000000000000000102",
            x"0000000000000000000000000000000000000103",
            x"0000000000000000000000000000000000000104",
            x"0000000000000000000000000000000000000105",
            x"0000000000000000000000000000000000000106",
            x"000000000000000000000000000000000000010a",
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc"
        ];
        let balance_table = vector[
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x0ba1a9ce0ba1a9ce,
            0x100000000000,
            0x0ba1a9ce0ba1a9ce
        ];
        let codes = vector[
            x"60006000a061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd60005260017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffa061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd6000527fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff6001a061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd60005260006001a061600d60005500",
            x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60005260206000a061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd60005260016000a061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd6000526001601fa061600d60005500",
            x"7faabbffffffffffffffffffffffffffffffffffffffffffffffffffffffffccdd60005260206000a060106002a061600d60005500",
            x"",
            x"6000600060006000600435610100015af400"
        ];
        // let nonce_table = vector[
        //     0x00,
        //     0x01
        // ];
        let i = 0;
        let balances = vector::empty<vector<u8>>();
        let nonces = vector::empty<u64>();
        while(i < vector::length(&addresses)) {
            let address = *vector::borrow(&addresses, i);
            vector::push_back(&mut nonces, 0);

            let balance = *vector::borrow(&balance_table, i);
            vector::push_back(&mut balances, u256_to_data(balance));

            if(simple_map::contains_key(&storage_maps, &address)) {
                let data = simple_map::borrow(&storage_maps, &address);
                vector::push_back(&mut storage_keys, simple_map::keys(data));
                vector::push_back(&mut storage_values, simple_map::values(data));
            } else {
                vector::push_back(&mut storage_keys, vector::empty<vector<u8>>());
                vector::push_back(&mut storage_values, vector::empty<vector<u8>>());
            };
            i = i + 1;
        };

        run_test(
            addresses,
            codes,
            nonces,
            balances,
            storage_keys,
            storage_values,
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000002",
            u256_to_data(0x04c4b400),
            u256_to_data(0x0a),
            u256_to_data(0x1)
        );
    }


}
