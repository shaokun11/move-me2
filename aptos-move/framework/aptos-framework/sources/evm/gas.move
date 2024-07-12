module aptos_framework::evm_gas {
    use std::vector;
    use aptos_framework::evm_util::{u256_to_data, print_opcode, u256_bytes_length, get_word_count, get_valid_ethereum_address};
    use aptos_framework::evm_global_state::{get_memory_cost, set_memory_cost, add_gas_refund, sub_gas_refund, get_memory_word_size, set_memory_word_size, RunState, get_gas_left, get_ret_size};
    use aptos_std::debug;
    use std::vector::for_each;
    use aptos_framework::evm_trie::{Trie, get_state, exist_account, is_cold_address, get_cache, get_balance};

    const U64_MAX: u256 = 18446744073709551615; // 18_446_744_073_709_551_615

    const OUT_OF_GAS: u64 = 11;
    const STACK_UNDERFLOW: u64 = 12;
    const INVALID_OPCODE: u64 = 13;

    const SstoreNoopGasEIP2200: u256 = 100;
    const SstoreInitGasEIP2200: u256 = 20000;
    const SstoreCleanGasEIP2200: u256 = 2900;
    const SstoreDirtyGasEIP2200: u256 = 100;
    const SstoreClearRefundEIP2200: u256 = 4800;
    const SstoreInitRefundEIP2200: u256 = 19900;
    const SstoreCleanRefundEIP2200: u256 = 2800;
    const SstoreSentryGasEIP2200: u256 = 2300;
    const Coldsload: u256 = 2100;
    const Warmstorageread: u256 = 100;
    const CallNewAccount: u256 = 25000;
    const CallValueTransfer: u256 = 9000;
    const ColdAccountAccess: u256 = 2600;
    const ExpByte: u256 = 50;
    const Copy: u256 = 3;
    const LogTopic: u256 = 375;
    const LogData: u256 = 8;
    const Keccak256Word: u256 = 6;
    const CallStipend: u256 = 2300;
    const InitCodeWordCost: u256 = 2;

    fun access_address(address: vector<u8>, trie: &mut Trie): u256 {
        if(is_cold_address(address, trie)) ColdAccountAccess else Warmstorageread
    }

    fun calc_memory_expand(stack: &vector<u256>, pos: u64, size: u64, run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let len = vector::length(stack);
        let out_offset = *vector::borrow(stack,len - pos);
        let out_size = *vector::borrow(stack,len - size);

        if(out_size == 0) {
            return 0
        };
        // To prevent overflow
        if(out_offset > U64_MAX || out_size > U64_MAX || out_offset + out_size > U64_MAX) {
            *error_code = OUT_OF_GAS;
            return 0
        };
        calc_memory_expand_internal(out_offset + out_size, run_state, gas_limit, error_code)
    }

    fun calc_memory_expand_internal(new_memory_size: u256, run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        if(new_memory_size == 0) {
            return 0
        };
        let old_memory_word_size = get_memory_word_size(run_state);
        let new_memory_word_size = get_word_count(new_memory_size);

        if(new_memory_word_size <= old_memory_word_size) {
            return 0
        };
        // To prevent overflow
        if(gas_limit / 3 < new_memory_word_size) {
            *error_code = OUT_OF_GAS;
            return 0
        };

        let old_memory_cost = get_memory_cost(run_state);
        let new_memory_cost = (new_memory_word_size * new_memory_word_size / 512) + 3 * new_memory_word_size;
        if(new_memory_cost > old_memory_cost) {
            set_memory_cost(run_state, new_memory_cost);
            new_memory_cost = new_memory_cost - old_memory_cost;
        };
        set_memory_word_size(run_state, new_memory_word_size);
        new_memory_cost
    }

    fun calc_mcopy_gas(stack: &vector<u256>,
                        run_state: &mut RunState,
                        gas_limit: u256,
                       error_code: &mut u64): u256 {
        let gas = 0;
        let len = vector::length(stack);
        if(len < 3) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let length = *vector::borrow(stack,len - 3);
        let word_size = get_word_count(length);
        gas = gas +  calc_memory_expand(stack, 1, 3, run_state, gas_limit, error_code);
        gas = gas +  calc_memory_expand(stack, 2, 3, run_state, gas_limit, error_code);
        gas = gas +  word_size * 3;

        gas + 3
    }

    fun calc_mstore_gas(stack: &vector<u256>,
                        run_state: &mut RunState,
                        gas_limit: u256,
                        error_code: &mut u64): u256 {
        let len = vector::length(stack);
        let offset = *vector::borrow(stack,len - 1);
        calc_memory_expand_internal(offset + 32, run_state, gas_limit, error_code)
    }

    fun calc_mstore8_gas(stack: &vector<u256>,
                         run_state: &mut RunState,
                         gas_limit: u256,
                         error_code: &mut u64): u256 {
        let len = vector::length(stack);
        let offset = *vector::borrow(stack,len - 1);
        calc_memory_expand_internal(offset + 1, run_state, gas_limit, error_code)
    }

    fun calc_sload_gas(address: vector<u8>,
                       stack: &vector<u256>,
                       trie: &mut Trie): u256 {
        let len = vector::length(stack);
        let key = *vector::borrow(stack,len - 1);
        let (is_cold_slot, _) = get_cache(address, key, trie);
        if(is_cold_slot) Coldsload else Warmstorageread
    }

    fun calc_sstore_gas(address: vector<u8>,
                        stack: &vector<u256>,
                        trie: &mut Trie,
                        run_state: &mut RunState,
                        error_code: &mut u64): u256 {
        if(get_gas_left(run_state) <= SstoreSentryGasEIP2200) {
            *error_code = OUT_OF_GAS;
            return 0
        };

        let len = vector::length(stack);
        let key = *vector::borrow(stack,len - 1);
        let (is_cold_slot, origin) = get_cache(address, key, trie);
        let current = get_state(address, key, trie);
        let new = *vector::borrow(stack,len - 2);
        let cold_cost = if(is_cold_slot) Coldsload else 0;
        // debug::print(get)
        let gas_cost = cold_cost;

        if(current == new) {
            //sstoreNoopGasEIP2200
            gas_cost = gas_cost + SstoreNoopGasEIP2200
        } else {
            if(origin == current) {
                if(origin == 0) {
                    //sstoreInitGasEIP2200
                    gas_cost = gas_cost + SstoreInitGasEIP2200
                } else {
                    if(new == 0) {
                        add_gas_refund(run_state, SstoreClearRefundEIP2200)
                    };
                    gas_cost = gas_cost + SstoreCleanGasEIP2200
                }
            } else {
                gas_cost = gas_cost + SstoreDirtyGasEIP2200;
                if(origin != 0) {
                    if(current == 0) {
                        sub_gas_refund(run_state, SstoreClearRefundEIP2200)
                    } else if(new == 0) {
                        add_gas_refund(run_state, SstoreClearRefundEIP2200)
                    }
                };
                if(new == origin) {
                    if(origin == 0) {
                        add_gas_refund(run_state, SstoreInitRefundEIP2200)
                    } else {
                        add_gas_refund(run_state, SstoreCleanRefundEIP2200)
                    }
                }
            }
        };

        gas_cost
    }

    fun calc_exp_gas(stack: &vector<u256>, error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 2) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let exponent = *vector::borrow(stack,len - 2);
        if(exponent == 0) {
            return 0
        };

        let byte_length = u256_bytes_length(exponent);
        ExpByte * byte_length
    }

    fun calc_call_gas(stack: &mut vector<u256>,
                      opcode: u8,
                      trie: &mut Trie, run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let gas = 0;
        let len = vector::length(stack);
        let size = if(opcode == 0xf1 || opcode == 0xf2) 7 else 6;
        if(len < size) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let address = get_valid_ethereum_address(*vector::borrow(stack,len - 2));
        if(opcode == 0xf1 || opcode == 0xf2) {
            let value = *vector::borrow(stack,len - 3);

            if(opcode == 0xf1 && value > 0 && !exist_account(address, trie)) {
                gas = gas + CallNewAccount;
            };
            if(value > 0) {
                gas = gas + CallValueTransfer;
            };
            gas = gas +  calc_memory_expand(stack, 4, 5, run_state, gas_limit, error_code);
            gas = gas +  calc_memory_expand(stack, 6, 7, run_state, gas_limit, error_code);
        } else {
            gas = gas +  calc_memory_expand(stack, 3, 4, run_state, gas_limit, error_code);
            gas = gas +  calc_memory_expand(stack, 5, 6, run_state, gas_limit, error_code);
        };

        gas = gas + access_address(address, trie);

        gas
    }

    fun calc_return_data_copy_gas(stack: &mut vector<u256>,
                           run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 3) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let data_length = *vector::borrow(stack,len - 3);
        let data_pos = *vector::borrow(stack,len - 1);
        if(data_length + data_pos > get_ret_size(run_state)) {
            *error_code = OUT_OF_GAS;
            return 0
        };

        calc_code_copy_gas(stack, run_state, gas_limit, error_code)
    }

    fun calc_code_copy_gas(stack: &mut vector<u256>,
                           run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 3) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let gas = 0;
        let data_length = *vector::borrow(stack,len - 3);
        if(data_length > 0) {
            let word_count = get_word_count(data_length);
            gas = gas + word_count * Copy;
            // Prevent overflow here; if the result is greater than gasLimit, return gasLimit directly
            if(gas > gas_limit) {
                *error_code = OUT_OF_GAS;
                return 0
            };
            gas = gas + calc_memory_expand(stack, 1, 3, run_state, gas_limit, error_code);
        };
        gas + 3
    }

    fun calc_address_access_gas(stack: &mut vector<u256>,
                                trie: &mut Trie,
                                error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len == 0) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let address = get_valid_ethereum_address(*vector::borrow(stack,len - 1));
        access_address(address, trie)
    }

    fun calc_ext_code_copy_gas(stack: &mut vector<u256>,
                               run_state: &mut RunState,
                               trie: &mut Trie,
                               gas_limit: u256,
                               error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 4) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let gas = 0;
        let data_length = *vector::borrow(stack,len - 4);
        if(data_length > 0) {
            let word_count = get_word_count(data_length);
            gas = gas + word_count * Copy;
            // Prevent overflow here; if the result is greater than gasLimit, return gasLimit directly
            if(gas > gas_limit) {
                *error_code = OUT_OF_GAS;
                return 0
            };
            gas = gas + calc_memory_expand(stack, 2, 4, run_state, gas_limit, error_code);
        };
        let address = get_valid_ethereum_address(*vector::borrow(stack,len - 1));
        gas = gas + access_address(address, trie);
        gas
    }

    fun calc_keccak256_gas(stack: &mut vector<u256>,
                     run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 2) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let gas = 0;
        let data_length = *vector::borrow(stack,len - 2);

        if(data_length > 0) {
            let word_count = get_word_count(data_length);
            gas = gas + word_count * Keccak256Word;
            gas = gas + calc_memory_expand(stack, 1, 2, run_state, gas_limit, error_code);
        };

        gas + 30
    }

    fun calc_log_gas(opcode: u8, stack: &mut vector<u256>,
                           run_state: &mut RunState, gas_limit: u256, error_code: &mut u64): u256 {
        let topic_count = ((opcode - 0xa0) as u256);
        let len = vector::length(stack);
        let gas = 0;
        let data_length = *vector::borrow(stack,len - 2);
        gas = gas + calc_memory_expand(stack, 1, 2, run_state, gas_limit, error_code);
        if(data_length > gas_limit) {
            *error_code = OUT_OF_GAS;
            return 0
        };
        gas = gas + LogTopic * topic_count + data_length * LogData + LogTopic;
        gas
    }

    fun calc_create_gas(address: vector<u8>,
                        stack: &vector<u256>,
                        trie: &mut Trie,
                        run_state: &mut RunState,
                        gas_limit: u256,
                        error_code: &mut u64): u256 {
        let len = vector::length(stack);
        if(len < 3) {
            *error_code = STACK_UNDERFLOW;
            return 0
        };
        let length = *vector::borrow(stack,len - 3);
        let gas = 0;
        let words = get_word_count(length);
        gas = gas + calc_memory_expand(stack, 2, 3, run_state, gas_limit, error_code);
        gas = gas + words * InitCodeWordCost;

        access_address(address, trie);

        gas
    }

    fun calc_create2_gas(address: vector<u8>,
                         stack: &vector<u256>,
                         trie: &mut Trie,
                         run_state: &mut RunState,
                         gas_limit: u256,
                         error_code: &mut u64): u256 {
        let len = vector::length(stack);
        let length = *vector::borrow(stack,len - 3);
        let gas = 0;
        let words = get_word_count(length);
        gas = gas + calc_memory_expand(stack, 2, 3, run_state, gas_limit, error_code);
        gas = gas + words * InitCodeWordCost;
        gas = gas + words * Keccak256Word;
        access_address(address, trie);

        gas
    }

    fun calc_self_destruct_gas(address: vector<u8>,
                               stack: &mut vector<u256>,
                               trie: &mut Trie): u256 {
        let balance = get_balance(address, trie);
        let len = vector::length(stack);
        let to = u256_to_data(*vector::borrow(stack,len - 1));
        let gas = 0;
        if(balance > 0) {
            if(balance > 0 && !exist_account(to, trie)) {
                gas = gas + CallNewAccount;
            };
        };
        gas = gas + access_address(to, trie);
        gas + 5000
    }

    public fun max_call_gas(gas_left: u256, gas_limit: u256, value: u256, need_stipend: bool): (u256, u256) {
        let gas_allow = gas_left - gas_left / 64;
        gas_limit = if(gas_limit > gas_allow) gas_allow else gas_limit;
        let gas_stipend = 0;
        if(need_stipend && value > 0) {
            gas_stipend = gas_stipend + CallStipend;
            gas_limit = gas_limit + CallStipend;
        };
        (gas_limit, gas_stipend)
    }

    public fun calc_base_gas(memory: &vector<u8>, access_address_count: u256, access_slot_count: u256): u256 {
        let gas = 0;

        for_each(*memory, |elem| gas = gas + if(elem == 0) 4 else 16);
        gas + access_address_count * 2400 + access_slot_count * 1900
    }

    public fun calc_exec_gas(opcode :u8,
                             address: vector<u8>,
                             stack: &mut vector<u256>,
                             run_state: &mut RunState,
                             trie: &mut Trie,
                             gas_limit: u256,
                             error_code: &mut u64
                            ): u256 {
        print_opcode(opcode);
        let gas = if (opcode == 0x00) {
            // STOP
            0
        } else if (opcode == 0x01) {
            // ADD
            3
        } else if (opcode == 0x02) {
            // MUL
            5
        } else if (opcode == 0x03) {
            // SUB
            3
        } else if (opcode == 0x04) {
            // DIV
            5
        } else if (opcode == 0x05) {
            // SDIV
            5
        } else if (opcode == 0x06) {
            // MOD
            5
        } else if (opcode == 0x07) {
            // SMOD
            5
        } else if (opcode == 0x08) {
            // ADDMOD
            8
        } else if (opcode == 0x09) {
            // MULMOD
            8
        } else if (opcode == 0x0A) {
            // EXP (dynamic gas)
            calc_exp_gas(stack, error_code) + 10
        } else if (opcode == 0x0B) {
            // SIGNEXTEND
            5
        } else if (opcode == 0x10) {
            // LT
            3
        } else if (opcode == 0x11) {
            // GT
            3
        } else if (opcode == 0x12) {
            // SLT
            3
        } else if (opcode == 0x13) {
            // SGT
            3
        } else if (opcode == 0x14) {
            // EQ
            3
        } else if (opcode == 0x15) {
            // ISZERO
            3
        } else if (opcode == 0x16) {
            // AND
            3
        } else if (opcode == 0x17) {
            // OR
            3
        } else if (opcode == 0x18) {
            // XOR
            3
        } else if (opcode == 0x19) {
            // NOT
            3
        } else if (opcode == 0x1A) {
            // BYTE
            3
        } else if (opcode == 0x1B) {
            // SHL
            3
        } else if (opcode == 0x1C) {
            // SHR
            3
        } else if (opcode == 0x1D) {
            // SAR
            3
        } else if (opcode == 0x30) {
            // ADDRESS
            2
        } else if (opcode == 0x32) {
            // ORIGIN
            2
        } else if (opcode == 0x33) {
            // CALLER
            2
        } else if (opcode == 0x34) {
            // CALLVALUE
            2
        } else if (opcode == 0x35) {
            // CALLDATALOAD
            3
        } else if (opcode == 0x36) {
            // CALLDATASIZE
            2
        } else if (opcode == 0x38) {
            // CODESIZE
            2
        } else if (opcode == 0x3A) {
            // GASPRICE
            2
        } else if (opcode == 0x3D) {
            // RETURNDATASIZE
            2
        } else if (opcode == 0x40) {
            // BLOCKHASH
            20
        } else if (opcode == 0x41) {
            // COINBASE
            2
        } else if (opcode == 0x42) {
            // TIMESTAMP
            2
        } else if (opcode == 0x43) {
            // NUMBER
            2
        } else if (opcode == 0x44) {
            // PREVRANDAO
            2
        } else if (opcode == 0x45) {
            // GASLIMIT
            2
        } else if (opcode == 0x46) {
            // CHAINID
            2
        } else if (opcode == 0x47) {
            // SELFBALANCE
            5
        } else if (opcode == 0x48) {
            // BASEFEE
            2
        } else if (opcode == 0x49) {
            // BLOBHASH
            3
        } else if (opcode == 0x4A) {
            // BLOBBASEFEE
            2
        } else if (opcode == 0x50) {
            // POP
            2
        } else if (opcode == 0x56) {
            // JUMP
            8
        } else if (opcode == 0x57) {
            // JUMPI
            10
        } else if (opcode == 0x58) {
            // PC
            2
        } else if (opcode == 0x59) {
            // MSIZE
            2
        } else if (opcode == 0x5A) {
            // GAS
            2
        } else if (opcode == 0x5B) {
            // JUMPDEST
            1
        } else if (opcode == 0x5C) {
            // TLOAD
            100
        } else if (opcode == 0x5D) {
            // TSTORE
            100
        } else if (opcode == 0x5F) {
            // PUSH0
            2
        } else if (opcode >= 0x60 && opcode <= 0x7F) {
            // PUSH1 to PUSH32
            3
        } else if (opcode >= 0x80 && opcode <= 0x8F) {
            // DUP1 to DUP16
            3
        } else if (opcode >= 0x90 && opcode <= 0x9F) {
            // SWAP1 to SWAP16
            3
        } else if (opcode == 0x20) {
            // KECCAK256
            calc_keccak256_gas(stack, run_state, gas_limit, error_code)
        } else if (opcode == 0x31) {
            // BALANCE
            calc_address_access_gas(stack, trie, error_code)
        } else if (opcode == 0x3f || opcode == 0x3b) {
            // EXTCODEHASH
            calc_address_access_gas(stack, trie, error_code)
        } else if (opcode == 0xf0) {
            // CREATE
            calc_create_gas(address, stack, trie, run_state, gas_limit, error_code) + 32000
        } else if (opcode == 0xf5) {
            // CREATE2
            calc_create2_gas(address, stack, trie, run_state, gas_limit, error_code) + 32000
        } else if(opcode == 0x53){
            calc_mstore8_gas(stack, run_state, gas_limit, error_code) + 3
        } else if (opcode == 0x51 || opcode == 0x52) {
            // MSTORE & MLOAD
            calc_mstore_gas(stack, run_state, gas_limit, error_code) + 3
        } else if (opcode == 0xf1 || opcode == 0xf2 || opcode == 0xf4 || opcode == 0xfa) {
            // CALL
            calc_call_gas(stack, opcode, trie, run_state, gas_limit, error_code)
        } else if (opcode == 0xf3 || opcode == 0xfd) {
            // RETURN & REVERT
            calc_memory_expand(stack, 1, 2, run_state, gas_limit, error_code)
        } else if (opcode == 0x54) {
            // SLOAD
            calc_sload_gas(address, stack, trie)
        } else if (opcode == 0x55) {
            // SSTORE
            calc_sstore_gas(address, stack, trie, run_state, error_code)
        } else if (opcode == 0x5e) {
            // MCOPY
            calc_mcopy_gas(stack, run_state, gas_limit, error_code)
        } else if(opcode == 0x3e){
            //RETURNDATA COPY
            calc_return_data_copy_gas(stack, run_state, gas_limit, error_code)
        } else if (opcode == 0x37 || opcode == 0x39) {
            // CALLDATACOPY & CODECOPY
            calc_code_copy_gas(stack, run_state, gas_limit, error_code)
        } else if (opcode == 0x3c) {
            // EXTCODECOPY
            calc_ext_code_copy_gas(stack, run_state, trie, gas_limit, error_code)
        } else if (opcode >= 0xa0 && opcode <= 0xa4) {
            // LOG
            calc_log_gas(opcode, stack, run_state, gas_limit, error_code)
        } else if (opcode == 0xff) {
            // SELF DESTRUCT
            calc_self_destruct_gas(address, stack, trie)
        }
        else {
            *error_code = INVALID_OPCODE;
            0
        };
        debug::print(&gas);
        gas
    }
}

