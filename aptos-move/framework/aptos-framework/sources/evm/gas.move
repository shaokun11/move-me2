module aptos_framework::evm_gas {
    use std::vector;
    use aptos_std::simple_map::{SimpleMap};
    use aptos_framework::evm_storage::{get_storage, TestAccount, exist_account};
    use aptos_framework::evm_cache::{get_cache, is_cold_address};
    use aptos_framework::evm_util::{u256_to_data, print_opcode, u256_bytes_length};
    use aptos_framework::evm_global_state::{get_memory_cost, set_memory_cost, add_gas_usage};
    use aptos_std::debug;
    use std::vector::for_each;
    use std::string::utf8;


    const SstoreNoopGasEIP2200: u64 = 100;
    const SstoreInitGasEIP2200: u64 = 20000;
    const SstoreCleanGasEIP2200: u64 = 2900;
    const SstoreDirtyGasEIP2200: u64 = 100;
    const Coldsload: u64 = 2100;
    const CallNewAccount: u64 = 25000;
    const CallValueTransfer: u64 = 9000;
    const ColdAccountAccess: u64 = 2600;
    const ExpByte: u64 = 50;

    fun access_address(address: vector<u8>, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>): u64 {
        if(is_cold_address(address, cache)) ColdAccountAccess else 0
    }

    fun calc_memory_expand(stack: &vector<u256>, pos: u64, size: u64, run_state: &mut SimpleMap<u64, u64>): u64 {
        let len = vector::length(stack);
        let out_offset = *vector::borrow(stack,len - pos);
        let out_size = *vector::borrow(stack,len - size);
        calc_memory_expand_internal(((out_offset + out_size) as u64), run_state)
    }

    fun calc_memory_expand_internal(new_memory_size: u64, run_state: &mut SimpleMap<u64, u64>): u64 {
        let old_memory_cost = get_memory_cost(run_state);
        let new_memory_size_word = (new_memory_size + 31) / 32;
        let new_memory_cost = (new_memory_size_word * new_memory_size_word / 512) + 3 * new_memory_size_word;
        if(new_memory_cost > old_memory_cost) {
            set_memory_cost(run_state, new_memory_cost);
            return new_memory_cost - old_memory_cost
        };

        0
    }

    fun calc_sstore_gas(address: vector<u8>, stack: &mut vector<u256>, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>, trie: &mut SimpleMap<vector<u8>, TestAccount>): u64 {
        let len = vector::length(stack);
        let key = *vector::borrow(stack,len - 1);
        let (_, is_cold_slot, origin) = get_cache(address, key, cache, trie);
        let current = get_storage(address, key, trie);
        let new = *vector::borrow(stack,len - 2);
        let cold_cost = if(is_cold_slot) Coldsload else 0;

        if(current == new) {
            //sstoreNoopGasEIP2200
            return SstoreNoopGasEIP2200 + cold_cost
        } else if(origin == current) {
            if(origin == 0) {
                //sstoreInitGasEIP2200
                return SstoreInitGasEIP2200 + cold_cost
            } else {
                return SstoreCleanGasEIP2200 + cold_cost
            }
        };

        SstoreDirtyGasEIP2200 + cold_cost
    }

    fun calc_exp_gas(stack: &vector<u256>): u64 {
        let len = vector::length(stack);
        let exponent = *vector::borrow(stack,len - 2);
        if(exponent == 0) {
            return 0
        };

        let byte_length = u256_bytes_length(exponent);
        debug::print(&utf8(b"exp gas"));
        debug::print(&exponent);
        debug::print(&byte_length);
        ExpByte * byte_length
    }

    fun calc_call_gas(stack: &mut vector<u256>, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>, run_state: &mut SimpleMap<u64, u64>, trie: &mut SimpleMap<vector<u8>, TestAccount>): u64 {
        let gas = 0;
        let len = vector::length(stack);
        let value = *vector::borrow(stack,len - 3);
        let address = u256_to_data(*vector::borrow(stack,len - 2));
        if(value > 0 && !exist_account(address, trie)) {
            gas = gas + CallNewAccount;
        };
        if(value > 0) {
            gas = gas + CallValueTransfer;
        };

        let memory_cost = calc_memory_expand(stack, 6, 7, run_state);

        gas = gas + access_address(address, cache);

        gas + memory_cost
    }

    public fun calc_base_gas(memory: &vector<u8>): u64 {
        debug::print(memory);
        let gas = 0;

        for_each(*memory, |elem| gas = gas + if(elem == 0) 4 else 16);

        debug::print(&gas);
        gas
    }

    public fun calc_exec_gas(opcode :u8, address: vector<u8>, stack: &mut vector<u256>, run_state: &mut SimpleMap<u64, u64>, cache: &mut SimpleMap<vector<u8>, SimpleMap<u256, u256>>, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
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
            calc_exp_gas(stack) + 10
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
        } else if (opcode == 0x31) {
            // BALANCE
            700
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
        } else if (opcode == 0x3B) {
            // EXTCODESIZE
            700
        } else if (opcode == 0x3D) {
            // RETURNDATASIZE
            2
        } else if (opcode == 0x3F) {
            // EXTCODEHASH
            700
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
        } else if (opcode == 0x51) {
            // MLOAD
            3
        } else if (opcode == 0x52) {
            // MSTORE
            3
        } else if (opcode == 0x53) {
            // MSTORE8
            3
        } else if (opcode == 0x54) {
            // SLOAD
            2100
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
        } else if (opcode == 0xf1) {
            // CALL
            calc_call_gas(stack, cache, run_state, trie)
        } else if (opcode == 0xf3) {
            // RETURN
            calc_memory_expand(stack, 1, 2, run_state)
        } else if (opcode == 0x55) {
            // SSTORE
            calc_sstore_gas(address, stack, cache, trie)
        } else {
            assert!(false, (opcode as u64));
            0
        };
        debug::print(&gas);
        add_gas_usage(run_state, gas);

    }
}

