module aptos_framework::evm_util {
    use std::vector;
    use aptos_std::aptos_hash::keccak256;
    use aptos_framework::rlp_encode::encode_bytes_list;
    use aptos_std::debug;
    use std::string::utf8;

    const U64_MAX: u256 = 18446744073709551615; // 18_446_744_073_709_551_615

    const U256_MAX: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
    const U255_MAX: u256 = 57896044618658097711785492504343953926634992332820282019728792003956564819967;
    const ZERO_EVM_ADDR: vector<u8> = x"";
    const TX_FORMAT: u64 = 20001;

    public native fun new_fixed_length_vector(size: u64): vector<u8>;
    public native fun vector_extend(a: vector<u8>, b: vector<u8>): vector<u8>;
    public native fun vector_slice(a: vector<u8>, pos: u64, size: u64): vector<u8>;

    public fun vector_slice_u256(a: vector<u8>, pos: u256, size: u64): vector<u8> {
        if(pos > U64_MAX) {
            return create_empty_data(size)
        };

        vector_slice(a, (pos as u64), size)
    }

    public fun create_empty_data(len: u64): vector<u8> {
        let bytes = vector::empty<u8>();
        let i = 0;
        while(i < len) {
            vector::push_back(&mut bytes, 0);
            i = i + 1;
        };
        bytes
    }

    public fun to_32bit(data: vector<u8>): vector<u8> {
        let bytes = vector::empty<u8>();
        let len = vector::length(&data);
        // debug::print(&len);
        while(len < 32) {
            vector::push_back(&mut bytes, 0);
            len = len + 1
        };
        vector::append(&mut bytes, data);
        bytes
    }

    public fun get_contract_address(addr: vector<u8>, nonce: u64): vector<u8> {
        let nonce_bytes = vector::empty<u8>();
        let l = 0;
        while(nonce > 0) {
            l = l + 1;
            vector::push_back(&mut nonce_bytes, ((nonce % 0x100) as u8));
            nonce = nonce / 0x100;
        };
        vector::reverse(&mut nonce_bytes);
        let salt = encode_bytes_list(vector[vector_slice(addr, 12, 20), nonce_bytes]);
        to_32bit(vector_slice(keccak256(salt), 12, 20))
    }

    public fun power(base: u256, exponent: u256): u256 {
        let result = 1;

        let i = 0;
        while (i < exponent) {
            result = result * base;
            i = i + 1;
        };

        result
    }

    public fun to_int256(num: u256): (bool, u256) {
        let neg = false;
        if(num > U255_MAX) {
            neg = true;
            num = U256_MAX - num + 1;
        };
        (neg, num)
    }

    public fun add_sign(value: u256, sign: bool): u256 {
        if(sign) {
            U256_MAX - value + 1
        } else {
            value
        }
    }

    public fun to_u256(data: vector<u8>): u256 {
        let res = 0;
        let i = 0;
        let len = vector::length(&data);
        while (i < len) {
            let value = *vector::borrow(&data, i);
            res = (res << 8) + (value as u256);
            i = i + 1;
        };
        res
    }

    public fun data_to_u256(data: vector<u8>, p: u256, size: u256): u256 {
        let res = 0;
        let i = 0;
        let len = (vector::length(&data) as u256);
        assert!(size <= 32, 1);
        while (i < size) {
            if(p + i < len) {
                let value = *vector::borrow(&data, ((p + i) as u64));
                res = (res << 8) + (value as u256);
            } else {
                res = res << 8
            };

            i = i + 1;
        };

        res
    }

    public fun u256_bytes_length(num: u256): u256 {
        let i = 0;
        while(num > 0) {
            i = i + 1;
            num = num >> 8;
        };

        i
    }

    public fun u256_to_data(num256: u256): vector<u8> {
        let res = vector::empty<u8>();
        let i = 32;
        while(i > 0) {
            i = i - 1;
            let shifted_value = num256 >> (i * 8);
            let byte = ((shifted_value & 0xff) as u8);
            vector::push_back(&mut res, byte);
        };
        res
    }

    public fun expand_to_pos(memory: &mut vector<u8>, pos: u64) {
        let len_m = vector::length(memory);
        let pos = pos;
        if(pos % 32 != 0) {
            pos = pos / 32 * 32 + 32;
        };

        if(pos > len_m) {
            let size = pos - len_m;
            let new_array = new_fixed_length_vector(size);
            *memory = vector_extend(new_array, *memory)
        };
    }

    public fun copy_to_memory(memory: &mut vector<u8>, m_pos: u256, d_pos: u256, len: u256, data: vector<u8>) {
        expand_to_pos(memory, ((m_pos + len) as u64));
        let i = 0;
        let d_len =( vector::length(&data) as u256);

        while (i < len) {
            let bytes = if(d_pos > U64_MAX || d_pos + i >= d_len) 0 else *vector::borrow(&data, ((d_pos + i) as u64));
            *vector::borrow_mut(memory, ((m_pos + i) as u64)) = bytes;
            i = i + 1;
        };
    }

    public fun mstore(memory: &mut vector<u8>, pos: u64, data: vector<u8>) {
        let len_d = vector::length(&data);
        expand_to_pos(memory, pos + len_d);

        let i = 0;
        while (i < len_d) {
            *vector::borrow_mut(memory, pos + i) = *vector::borrow(&data, i);
            i = i + 1
        };
    }

    public fun get_message_hash(input: vector<vector<u8>>): vector<u8> {
        let i = 0;
        let len = vector::length(&input);
        let content = vector::empty<u8>();
        while(i < len) {
            let item = vector::borrow(&input, i);
            let item_len = vector::length(item);
            let encoded = if(item_len == 1 && *vector::borrow(item, 0) < 0x80) *item else encode_data(item, 0x80);
            vector::append(&mut content, encoded);
            i = i + 1;
        };

        encode_data(&content, 0xc0)
    }

    public fun u256_to_trimed_data(num: u256): vector<u8> {
        trim(u256_to_data(num))
    }

    public fun trim(data: vector<u8>): vector<u8> {
        let i = 0;
        let len = vector::length(&data);
        while (i < len) {
            let ith = *vector::borrow(&data, i);
            if(ith != 0) {
                break
            };
            i = i + 1
        };
        vector_slice(data, i, len - i)
    }

    public fun get_valid_jumps(bytecode: &vector<u8>): vector<bool> {
        let i = 0;
        let len = vector::length(bytecode);
        let valid_jumps = vector::empty<bool>();
        while(i < len) {
            let opcode = *vector::borrow(bytecode, i);
            if(opcode == 0x5b) {
                vector::push_back(&mut valid_jumps, true)
            } else if(opcode >= 0x60 && opcode <= 0x7f) {
                let size = opcode - 0x60 + 1;
                vector::push_back(&mut valid_jumps, false);
                while(size > 0) {
                    vector::push_back(&mut valid_jumps, false);
                    i = i + 1;
                    size = size - 1;
                }
            } else {
                vector::push_back(&mut valid_jumps, false);
            };
            i = i + 1;
        };

        valid_jumps
    }

    public fun print_opcode(opcode: u8) {
        if(opcode == 0x00) {
            debug::print(&utf8(b"STOP"))
        } else if(opcode == 0x01) {
            debug::print(&utf8(b"ADD"));
        } else if(opcode == 0x02) {
            debug::print(&utf8(b"MUL"));
        } else if(opcode == 0x03) {
            debug::print(&utf8(b"SUB"));
        } else if(opcode == 0x04) {
            debug::print(&utf8(b"DIV"));
        } else if(opcode == 0x05) {
            debug::print(&utf8(b"SDIV"));
        } else if(opcode == 0x06) {
            debug::print(&utf8(b"MOD"));
        } else if(opcode == 0x07) {
            debug::print(&utf8(b"SMOD"));
        } else if(opcode == 0x08) {
            debug::print(&utf8(b"ADDMOD"));
        } else if(opcode == 0x09) {
            debug::print(&utf8(b"MULMOD"));
        } else if(opcode == 0x0a) {
            debug::print(&utf8(b"EXP"));
        } else if(opcode == 0x0b) {
            debug::print(&utf8(b"SIGNEXTEND"));
        } else if(opcode == 0x10) {
            debug::print(&utf8(b"LT"));
        } else if(opcode == 0x11) {
            debug::print(&utf8(b"GT"));
        } else if(opcode == 0x12) {
            debug::print(&utf8(b"SLT"));
        } else if(opcode == 0x13) {
            debug::print(&utf8(b"SGT"));
        } else if(opcode == 0x14) {
            debug::print(&utf8(b"EQ"));
        } else if(opcode == 0x15) {
            debug::print(&utf8(b"ISZERO"));
        } else if(opcode == 0x16) {
            debug::print(&utf8(b"AND"));
        } else if(opcode == 0x17) {
            debug::print(&utf8(b"OR"));
        } else if(opcode == 0x18) {
            debug::print(&utf8(b"XOR"));
        } else if(opcode == 0x19) {
            debug::print(&utf8(b"NOT"));
        } else if(opcode == 0x1a) {
            debug::print(&utf8(b"BYTE"));
        } else if(opcode == 0x1b) {
            debug::print(&utf8(b"SHL"));
        } else if(opcode == 0x1c) {
            debug::print(&utf8(b"SHR"));
        } else if(opcode == 0x1d) {
            debug::print(&utf8(b"SAR"));
        } else if(opcode == 0x20) {
            debug::print(&utf8(b"SHA3"));
        } else if(opcode == 0x30) {
            debug::print(&utf8(b"ADDRESS"));
        } else if(opcode == 0x31) {
            debug::print(&utf8(b"BALANCE"));
        } else if(opcode == 0x32) {
            debug::print(&utf8(b"ORIGIN"));
        } else if(opcode == 0x33) {
            debug::print(&utf8(b"CALLER"));
        } else if(opcode == 0x34) {
            debug::print(&utf8(b"CALLVALUE"));
        } else if(opcode == 0x35) {
            debug::print(&utf8(b"CALLDATALOAD"));
        } else if(opcode == 0x36) {
            debug::print(&utf8(b"CALLDATASIZE"));
        } else if(opcode == 0x37) {
            debug::print(&utf8(b"CALLDATACOPY"));
        } else if(opcode == 0x38) {
            debug::print(&utf8(b"CODESIZE"));
        } else if(opcode == 0x39) {
            debug::print(&utf8(b"CODECOPY"));
        } else if(opcode == 0x3a) {
            debug::print(&utf8(b"GASPRICE"));
        } else if(opcode == 0x3b) {
            debug::print(&utf8(b"EXTCODESIZE"));
        } else if(opcode == 0x3c) {
            debug::print(&utf8(b"EXTCODECOPY"));
        } else if(opcode == 0x3d) {
            debug::print(&utf8(b"RETURNDATASIZE"));
        } else if(opcode == 0x3e) {
            debug::print(&utf8(b"RETURNDATACOPY"));
        } else if(opcode == 0x40) {
            debug::print(&utf8(b"BLOCKHASH"));
        } else if(opcode == 0x41) {
            debug::print(&utf8(b"COINBASE"));
        } else if(opcode == 0x42) {
            debug::print(&utf8(b"TIMESTAMP"));
        } else if(opcode == 0x43) {
            debug::print(&utf8(b"NUMBER"));
        } else if(opcode == 0x44) {
            debug::print(&utf8(b"DIFFICULTY"));
        } else if(opcode == 0x45) {
            debug::print(&utf8(b"GASLIMIT"));
        } else if(opcode == 0x50) {
            debug::print(&utf8(b"POP"));
        } else if(opcode == 0x51) {
            debug::print(&utf8(b"MLOAD"));
        } else if(opcode == 0x52) {
            debug::print(&utf8(b"MSTORE"));
        } else if(opcode == 0x53) {
            debug::print(&utf8(b"MSTORE8"));
        } else if(opcode == 0x54) {
            debug::print(&utf8(b"SLOAD"));
        } else if(opcode == 0x55) {
            debug::print(&utf8(b"SSTORE"));
        } else if(opcode == 0x56) {
            debug::print(&utf8(b"JUMP"));
        } else if(opcode == 0x57) {
            debug::print(&utf8(b"JUMPI"));
        } else if(opcode == 0x58) {
            debug::print(&utf8(b"PC"));
        } else if(opcode == 0x59) {
            debug::print(&utf8(b"MSIZE"));
        } else if(opcode == 0x5a) {
            debug::print(&utf8(b"GAS"));
        } else if(opcode == 0x5b) {
            debug::print(&utf8(b"JUMPDEST"));
        } else if(opcode == 0x5c) {
            debug::print(&utf8(b"TLOAD"));
        } else if(opcode == 0x5d) {
            debug::print(&utf8(b"TSTORE"));
        }  else if(opcode == 0x5e) {
            debug::print(&utf8(b"MCOPY"));
        } else if(opcode == 0x5f) {
            debug::print(&utf8(b"PUSH0"));
        } else if(opcode == 0x60) {
            debug::print(&utf8(b"PUSH1"));
        } else if(opcode == 0x61) {
            debug::print(&utf8(b"PUSH2"));
        } else if(opcode == 0x62) {
            debug::print(&utf8(b"PUSH3"));
        } else if(opcode == 0x63) {
            debug::print(&utf8(b"PUSH4"));
        } else if(opcode == 0x64) {
            debug::print(&utf8(b"PUSH5"));
        } else if(opcode == 0x65) {
            debug::print(&utf8(b"PUSH6"));
        } else if(opcode == 0x66) {
            debug::print(&utf8(b"PUSH7"));
        } else if(opcode == 0x67) {
            debug::print(&utf8(b"PUSH8"));
        } else if(opcode == 0x68) {
            debug::print(&utf8(b"PUSH9"));
        } else if(opcode == 0x69) {
            debug::print(&utf8(b"PUSH10"));
        } else if(opcode == 0x6a) {
            debug::print(&utf8(b"PUSH11"));
        } else if(opcode == 0x6b) {
            debug::print(&utf8(b"PUSH12"));
        } else if(opcode == 0x6c) {
            debug::print(&utf8(b"PUSH13"));
        } else if(opcode == 0x6d) {
            debug::print(&utf8(b"PUSH14"));
        } else if(opcode == 0x6e) {
            debug::print(&utf8(b"PUSH15"));
        } else if(opcode == 0x6f) {
            debug::print(&utf8(b"PUSH16"));
        } else if(opcode == 0x70) {
            debug::print(&utf8(b"PUSH17"));
        } else if(opcode == 0x71) {
            debug::print(&utf8(b"PUSH18"));
        } else if(opcode == 0x72) {
            debug::print(&utf8(b"PUSH19"));
        } else if(opcode == 0x73) {
            debug::print(&utf8(b"PUSH20"));
        } else if(opcode == 0x74) {
            debug::print(&utf8(b"PUSH21"));
        } else if(opcode == 0x75) {
            debug::print(&utf8(b"PUSH22"));
        } else if(opcode == 0x76) {
            debug::print(&utf8(b"PUSH23"));
        } else if(opcode == 0x77) {
            debug::print(&utf8(b"PUSH24"));
        } else if(opcode == 0x78) {
            debug::print(&utf8(b"PUSH25"));
        } else if(opcode == 0x79) {
            debug::print(&utf8(b"PUSH26"));
        } else if(opcode == 0x7a) {
            debug::print(&utf8(b"PUSH27"));
        } else if(opcode == 0x7b) {
            debug::print(&utf8(b"PUSH28"));
        } else if (opcode == 0x7c) {
            debug::print(&utf8(b"PUSH29"));
        } else if (opcode == 0x7d) {
            debug::print(&utf8(b"PUSH30"));
        } else if (opcode == 0x7e) {
            debug::print(&utf8(b"PUSH31"));
        } else if (opcode == 0x7f) {
            debug::print(&utf8(b"PUSH32"));
        } else if (opcode == 0x80) {
            debug::print(&utf8(b"DUP1"));
        } else if (opcode == 0x81) {
            debug::print(&utf8(b"DUP2"));
        } else if (opcode == 0x82) {
            debug::print(&utf8(b"DUP3"));
        } else if (opcode == 0x83) {
            debug::print(&utf8(b"DUP4"));
        } else if (opcode == 0x84) {
            debug::print(&utf8(b"DUP5"));
        } else if (opcode == 0x85) {
            debug::print(&utf8(b"DUP6"));
        } else if (opcode == 0x86) {
            debug::print(&utf8(b"DUP7"));
        } else if (opcode == 0x87) {
            debug::print(&utf8(b"DUP8"));
        } else if (opcode == 0x88) {
            debug::print(&utf8(b"DUP9"));
        } else if (opcode == 0x89) {
            debug::print(&utf8(b"DUP10"));
        } else if (opcode == 0x8a) {
            debug::print(&utf8(b"DUP11"));
        } else if (opcode == 0x8b) {
            debug::print(&utf8(b"DUP12"));
        } else if (opcode == 0x8c) {
            debug::print(&utf8(b"DUP13"));
        } else if (opcode == 0x8d) {
            debug::print(&utf8(b"DUP14"));
        } else if (opcode == 0x8e) {
            debug::print(&utf8(b"DUP15"));
        } else if (opcode == 0x8f) {
            debug::print(&utf8(b"DUP16"));
        } else if(opcode == 0x90) {
            debug::print(&utf8(b"SWAP1"));
        } else if(opcode == 0x91) {
            debug::print(&utf8(b"SWAP2"));
        } else if(opcode == 0x92) {
            debug::print(&utf8(b"SWAP3"));
        } else if(opcode == 0x93) {
            debug::print(&utf8(b"SWAP4"));
        } else if(opcode == 0x94) {
            debug::print(&utf8(b"SWAP5"));
        } else if(opcode == 0x95) {
            debug::print(&utf8(b"SWAP6"));
        } else if(opcode == 0x96) {
            debug::print(&utf8(b"SWAP7"));
        } else if(opcode == 0x97) {
            debug::print(&utf8(b"SWAP8"));
        } else if(opcode == 0x98) {
            debug::print(&utf8(b"SWAP9"));
        } else if(opcode == 0x99) {
            debug::print(&utf8(b"SWAP10"));
        } else if(opcode == 0x9a) {
            debug::print(&utf8(b"SWAP11"));
        } else if(opcode == 0x9b) {
            debug::print(&utf8(b"SWAP12"));
        } else if(opcode == 0x9c) {
            debug::print(&utf8(b"SWAP13"));
        } else if(opcode == 0x9d) {
            debug::print(&utf8(b"SWAP14"));
        } else if(opcode == 0x9e) {
            debug::print(&utf8(b"SWAP15"));
        } else if(opcode == 0x9f) {
            debug::print(&utf8(b"SWAP16"));
        } else if(opcode == 0xa0) {
            debug::print(&utf8(b"LOG0"));
        } else if(opcode == 0xa1) {
            debug::print(&utf8(b"LOG1"));
        } else if(opcode == 0xa2) {
            debug::print(&utf8(b"LOG2"));
        } else if(opcode == 0xa3) {
            debug::print(&utf8(b"LOG3"));
        } else if(opcode == 0xa4) {
            debug::print(&utf8(b"LOG4"));
        } else if(opcode >= 0xa5 && opcode <= 0xaf) {
            debug::print(&utf8(b"Reserved for future use"));
        } else if(opcode >= 0xb0 && opcode <= 0xe0) {
            debug::print(&utf8(b"More Reserved Opcodes"));
        } else if(opcode == 0xf0) {
            debug::print(&utf8(b"CREATE"));
        } else if(opcode == 0xf1) {
            debug::print(&utf8(b"CALL"));
        } else if(opcode == 0xf2) {
            debug::print(&utf8(b"CALLCODE"));
        } else if(opcode == 0xf3) {
            debug::print(&utf8(b"RETURN"));
        } else if(opcode == 0xf4) {
            debug::print(&utf8(b"DELEGATECALL"));
        } else if(opcode == 0xf5) {
            debug::print(&utf8(b"CREATE2"));
        } else if(opcode == 0xfa) {
            debug::print(&utf8(b"STATICCALL"));
        } else if(opcode == 0xfd) {
            debug::print(&utf8(b"REVERT"));
        } else if(opcode == 0xfe) {
            debug::print(&utf8(b"INVALID"));
        } else if(opcode == 0xff) {
            debug::print(&utf8(b"SELFDESTRUCT"));
        } else {
            debug::print(&utf8(b"Unknown Opcode"));
        }
    }

    // public fun decode_legacy_tx(data: vector<u8>): (u64, u256, u256, vector<u8>, u256, vector<u8>, u64, vector<u8>, vector<u8>) {
    // public fun decode_legacy_tx(data: vector<u8>) {
    //     let first_byte = *vector::borrow(&data, 0);
    //     let len = (vector::length(&data) as u256);
    //     if(first_byte > 0xf7) {
    //         let l = ((first_byte - 0xf7) as u256);
    //         let ll = to_u64(slice(data, 1, l));
    //         assert!(ll > 56, TX_FORMAT);
    //         let inner_bytes = slice(data, l + 1, len - l - 1);
    //         while()
    //     }
    // }

    fun hex_length(len: u64): (u8, vector<u8>) {
        let res = 0;
        let bytes = vector::empty<u8>();
        while(len > 0) {
            res = res + 1;
            vector::push_back(&mut bytes, ((len % 256) as u8));
            len = len / 256;
        };
        vector::reverse(&mut bytes);
        (res, bytes)
    }

    fun encode_data(data: &vector<u8>, offset: u8): vector<u8> {
        let len = vector::length(data);
        let res = vector::empty<u8>();
        if(len < 56) {
            vector::push_back(&mut res, (len as u8) + offset);
        } else {
            let(hex_len, len_bytes) = hex_length(len);
            vector::push_back(&mut res, hex_len + offset + 55);
            vector::append(&mut res, len_bytes);
        };
        vector::append(&mut res, *data);
        res
    }
}

