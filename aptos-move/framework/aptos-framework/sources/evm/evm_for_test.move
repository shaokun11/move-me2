module aptos_framework::evm_for_test {
    use aptos_framework::account::{create_resource_address};
    use std::vector;
    use aptos_std::aptos_hash::keccak256;
    use aptos_std::debug;
    use aptos_framework::evm_util::{slice, to_32bit, get_contract_address, to_int256, data_to_u256, u256_to_data, mstore, copy_to_memory, to_u256};
    use aptos_framework::timestamp::now_microseconds;
    use aptos_framework::block;
    use std::string::utf8;
    use aptos_framework::event::EventHandle;
    use aptos_std::table::{Table};
    use aptos_std::secp256k1::{ecdsa_signature_from_bytes, ecdsa_recover, ecdsa_raw_public_key_to_bytes};
    use std::option::borrow;
    use aptos_framework::precompile::{is_precompile_address, run_precompile};
    use aptos_std::simple_map;
    use aptos_std::simple_map::SimpleMap;
    use aptos_framework::evm_arithmetic::add_sign;

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

    // struct Acc

    struct TestAccount has store, copy, drop {
        balance: u256,
        code: vector<u8>,
        nonce: u256,
        storage: SimpleMap<u256, u256>
    }

    struct Account has key{
        balance: u256,
        nonce: u64,
        is_contract: bool,
        code: vector<u8>,
        storage: Table<u256, vector<u8>>,
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
    );

    native fun decode_raw_tx(
        raw_tx: vector<u8>
    ): (u64, u64, vector<u8>, vector<u8>, u256, vector<u8>);

    native fun mul_mod(a: u256, b: u256, n: u256): u256;
    native fun mul(a: u256, b: u256): u256;
    native fun exp(a: u256, b: u256): u256;

    fun get_code(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): vector<u8> {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).code
        } else {
            x""
        }
    }

    fun get_nonce(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).nonce
        } else {
            0
        }
    }

    fun get_balance(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(simple_map::contains_key(trie, &contract_addr)) {
            simple_map::borrow(trie, &contract_addr).balance
        } else {
            0
        }
    }

    fun get_storage(contract_addr: vector<u8>, key: u256, trie: &SimpleMap<vector<u8>, TestAccount>): u256 {
        if(!simple_map::contains_key(trie, &contract_addr)) {
            return 0
        };
        let account = simple_map::borrow(trie, &contract_addr);
        if(simple_map::contains_key(&account.storage, &key)) {
            *simple_map::borrow( &account.storage, &key)
        } else {
            0
        }
    }


    fun add_nonce(contract_addr: vector<u8>, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account =  simple_map::borrow_mut(trie, &contract_addr);
        account.nonce = account.nonce + 1;
    }

    fun set_storage(contract_addr: vector<u8>, key: u256, value: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account =  simple_map::borrow_mut(trie, &contract_addr);
        simple_map::upsert(&mut account.storage, key, value);
        // simple_map::upsert(trie, contract_addr, *account);
        // debug::print(&account.storage);
    }

    fun exist_contract(contract_addr: vector<u8>, trie: &SimpleMap<vector<u8>, TestAccount>): bool {
        simple_map::contains_key(trie, &contract_addr)
    }

    fun sub_balance(contract_addr: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        debug::print(&contract_addr);
        let account = simple_map::borrow_mut(trie, &contract_addr);
        assert!(account.balance >= amount, 2);
        account.balance = account.balance - amount;
    }

    fun add_balance(contract_addr: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        let account = simple_map::borrow_mut(trie, &contract_addr);
        account.balance = account.balance + amount;
    }

    fun transfer(from: vector<u8>, to: vector<u8>, amount: u256, trie: &mut SimpleMap<vector<u8>, TestAccount>) {
        sub_balance(from, amount, trie);
        add_balance(to, amount, trie);
    }

    fun pre_init(addresses: vector<vector<u8>>,
                  codes: vector<vector<u8>>,
                  nonces: vector<u64>,
                  balances: vector<vector<u8>>): SimpleMap<vector<u8>, TestAccount> {
        let trie = simple_map::new<vector<u8>, TestAccount>();
        let pre_len = vector::length(&addresses);
        let i = 0;
        while(i < pre_len) {
            simple_map::add(&mut trie, to_32bit(*vector::borrow(&addresses, i)), TestAccount {
                balance: to_u256(*vector::borrow(&balances, i)),
                code: *vector::borrow(&codes, i),
                nonce: (*vector::borrow(&nonces, i) as u256),
                storage: simple_map::new<u256, u256>(),
            });
            i = i + 1;
        };
        trie
    }

    public entry fun run_test(addresses: vector<vector<u8>>,
                              codes: vector<vector<u8>>,
                              nonces: vector<u64>,
                              balances: vector<vector<u8>>,
                              from: vector<u8>,
                              to: vector<u8>,
                              data: vector<u8>,
                              value_bytes: vector<u8>) acquires Account {
        let value = to_u256(value_bytes);
        let trie = pre_init(addresses, codes, nonces, balances);
        let transient = simple_map::new<u256, u256>();
        from = to_32bit(from);
        to = to_32bit(to);
        // debug::print(&trie);
        run(from, from, to, get_code(to, &trie), data, value, &mut trie, &mut transient);
        add_nonce(from, &mut trie);
        calculate_root(trie);
        // debug::print(&trie);
    }

    fun run(
            origin: vector<u8>,
            sender: vector<u8>,
            to: vector<u8>,
            code: vector<u8>,
            data: vector<u8>,
            value: u256,
            trie: &mut SimpleMap<vector<u8>, TestAccount>,
            transient: &mut SimpleMap<u256, u256>
        ): (bool, vector<u8>) acquires Account {

        if (is_precompile_address(to)) {
            return (true, precompile(sender, to, value, data, trie))
        };
        transfer(sender, to, value, trie);

        // let to_account = simple_map::borrow_mut(&mut trie, &to);

        let stack = &mut vector::empty<u256>();
        let memory = &mut vector::empty<u8>();
        let to_code = get_code(to, trie);
        let len = vector::length(&to_code);
        let i = 0;
        let runtime_code = vector::empty<u8>();
        let ret_bytes = vector::empty<u8>();
        let _events = simple_map::new<u256, vector<u8>>();

        while (i < len) {
            // Fetch the current opcode from the bytecode.
            let opcode: u8 = *vector::borrow(&to_code, i);
            // debug::print(&i);
            // debug::print(&opcode);

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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                ret_bytes = slice(*memory, pos, len);
                // debug::print(&ret_bytes);
                break
            }
                //add
            else if(opcode == 0x01) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                if(a > 0 && b >= (U256_MAX - a + 1)) {
                    vector::push_back(stack, b - (U256_MAX - a + 1));
                } else {
                    vector::push_back(stack, a + b);
                };
                i = i + 1;
            }
                //mul
            else if(opcode == 0x02) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, mul(a, b));
                i = i + 1;
            }
                //sub
            else if(opcode == 0x03) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                if(a >= b) {
                    vector::push_back(stack, a - b);
                } else {
                    vector::push_back(stack, U256_MAX - b + a + 1);
                };
                i = i + 1;
            }
                //div
            else if(opcode == 0x04) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, if(b == 0) 0 else a / b);
                i = i + 1;
            }
                //sdiv
            else if(opcode == 0x05) {
                let(sg_a, num_a) = to_int256(vector::pop_back(stack));
                let(sg_b, num_b) = to_int256(vector::pop_back(stack));
                let num_c = num_a / num_b;
                vector::push_back(stack, add_sign(num_c, (!sg_a && sg_b) || (sg_a && !sg_b)));
                i = i + 1;
            }
                //mod
            else if(opcode == 0x06) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, a % b);
                i = i + 1;
            }
                //smod
            else if(opcode == 0x07) {
                let(sg_a, num_a) = to_int256(vector::pop_back(stack));
                let(_sg_b, num_b) = to_int256(vector::pop_back(stack));
                let num_c = num_a % num_b;
                vector::push_back(stack, add_sign(num_c, sg_a));
                i = i + 1;
            }
                //addmod
            else if(opcode == 0x08) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                let n = vector::pop_back(stack);
                vector::push_back(stack, (a + b) % n);
                i = i + 1;
            }
                //mulmod
            else if(opcode == 0x09) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                let n = vector::pop_back(stack);
                vector::push_back(stack, mul_mod(a, b, n));
                i = i + 1;
            }
                //exp
            else if(opcode == 0x0a) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, exp(a, b));
                i = i + 1;
            }
                //signextend
            else if(opcode == 0x0b) {
                let b = vector::pop_back(stack);
                let value = vector::pop_back(stack);
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
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                if(a < b) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //gt
            else if(opcode == 0x11) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                if(a > b) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //slt
            else if(opcode == 0x12) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
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
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
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
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                if(a == b) {
                    vector::push_back(stack, 1);
                } else {
                    vector::push_back(stack, 0);
                };
                i = i + 1;
            }
                //and
            else if(opcode == 0x16) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, a & b);
                i = i + 1;
            }
                //or
            else if(opcode == 0x17) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, a | b);
                i = i + 1;
            }
                //xor
            else if(opcode == 0x18) {
                let a = vector::pop_back(stack);
                let b = vector::pop_back(stack);
                vector::push_back(stack, a ^ b);
                i = i + 1;
            }
                //not
            else if(opcode == 0x19) {
                // 10 1010
                // 6 0101
                let n = vector::pop_back(stack);
                vector::push_back(stack, U256_MAX - n);
                i = i + 1;
            }
                //byte
            else if(opcode == 0x1a) {
                let ith = vector::pop_back(stack);
                let x = vector::pop_back(stack);
                if(ith >= 32) {
                    vector::push_back(stack, 0);
                } else {
                    vector::push_back(stack, (x >> ((248 - ith * 8) as u8)) & 0xFF);
                };

                i = i + 1;
            }
                //shl
            else if(opcode == 0x1b) {
                let b = vector::pop_back(stack);
                let a = vector::pop_back(stack);
                if(b >= 256) {
                    vector::push_back(stack, 0);
                } else {
                    vector::push_back(stack, a << (b as u8));
                };
                i = i + 1;
            }
                //shr
            else if(opcode == 0x1c) {
                let b = vector::pop_back(stack);
                let a = vector::pop_back(stack);
                if(b >= 256) {
                    vector::push_back(stack, 0);
                } else {
                    vector::push_back(stack, a >> (b as u8));
                };

                i = i + 1;
            }
                //sar
            else if(opcode == 0x1d) {
                let b = vector::pop_back(stack);
                let a = vector::pop_back(stack);
                let(neg, num_a) = to_int256(a);
                let c = 0;
                if(b == 0 || b >= 256) {
                    if(neg) {
                        c = U256_MAX;
                    }
                } else {
                    if(neg) {
                        let n = num_a >> (b as u8);
                        c = if(n > 0) U256_MAX - n + 1 else 0;
                    } else {
                        c = a >> (b as u8);
                    }
                };

                vector::push_back(stack, c);
                i = i + 1;
            }
                //push0
            else if(opcode == 0x5f) {
                vector::push_back(stack, 0);
                i = i + 1;
            }
                // push1 -> push32
            else if(opcode >= 0x60 && opcode <= 0x7f)  {
                let n = ((opcode - 0x60) as u64);
                let number = data_to_u256(to_code, ((i + 1) as u256), ((n + 1) as u256));
                vector::push_back(stack, number);
                i = i + n + 2;
            }
                // pop
            else if(opcode == 0x50) {
                vector::pop_back(stack);
                i = i + 1
            }
                //address
            else if(opcode == 0x30) {
                vector::push_back(stack, data_to_u256(to, 0, 32));
                i = i + 1;
            }
                //balance
            else if(opcode == 0x31) {
                let target = slice(u256_to_data(vector::pop_back(stack)), 12, 20);
                let target_address = create_resource_address(&@aptos_framework, to_32bit(target));
                if(exists<Account>(target_address)) {
                    let account_store = borrow_global<Account>(target_address);
                    vector::push_back(stack, account_store.balance);
                } else {
                    vector::push_back(stack, 0)
                };
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
                let pos = vector::pop_back(stack);
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
                let m_pos = vector::pop_back(stack);
                let d_pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let end = d_pos + len;
                // debug::print(&utf8(b"calldatacopy"));
                // debug::print(&data);
                while (d_pos < end) {
                    // debug::print(&d_pos);
                    // debug::print(&end);
                    let bytes = if(end - d_pos >= 32) {
                        slice(data, d_pos, 32)
                    } else {
                        slice(data, d_pos, end - d_pos)
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
                let m_pos = vector::pop_back(stack);
                let d_pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                runtime_code = slice(code, d_pos, d_pos + len);
                copy_to_memory(memory, m_pos, d_pos, len, code);
                i = i + 1
            }
                //extcodesize
            else if(opcode == 0x3b) {
                let target = slice(u256_to_data(vector::pop_back(stack)), 12, 20);
                let code = get_code(to_32bit(target), trie);
                vector::push_back(stack, (vector::length(&code) as u256));
                i = i + 1;
            }
                //extcodecopy
            else if(opcode == 0x3c) {
                let target = slice(u256_to_data(vector::pop_back(stack)), 12, 20);
                let code = get_code(to_32bit(target), trie);
                let m_pos = vector::pop_back(stack);
                let d_pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                copy_to_memory(memory, m_pos, d_pos, len, code);
                i = i + 1;
            }
                //returndatacopy
            else if(opcode == 0x3e) {
                // mstore()
                let m_pos = vector::pop_back(stack);
                let d_pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let bytes = slice(ret_bytes, d_pos, len);
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
                let pos = vector::pop_back(stack);
                vector::push_back(stack, data_to_u256(slice(*memory, pos, 32), 0, 32));
                i = i + 1;
            }
                // mstore
            else if(opcode == 0x52) {
                let pos = vector::pop_back(stack);
                let value = vector::pop_back(stack);
                mstore(memory, pos, u256_to_data(value));
                // debug::print(memory);
                i = i + 1;

            }
                //mstore8
            else if(opcode == 0x53) {
                let pos = vector::pop_back(stack);
                let value = vector::pop_back(stack);
                *vector::borrow_mut(memory, (pos as u64)) = ((value & 0xff) as u8);
                // mstore(memory, pos, u256_to_data(value & 0xff));
                // debug::print(memory);
                i = i + 1;

            }
                // sload
            else if(opcode == 0x54) {
                let key = vector::pop_back(stack);
                vector::push_back(stack, get_storage(to, key, trie));
                i = i + 1;
            }
                // sstore
            else if(opcode == 0x55) {
                let key = vector::pop_back(stack);
                let value = vector::pop_back(stack);
                debug::print(&utf8(b"store"));
                debug::print(&to);
                debug::print(&key);
                debug::print(&value);
                set_storage(to, key, value, trie);
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
                let value = vector::pop_back(stack);
                if(value == 0) {
                    vector::push_back(stack, 1)
                } else {
                    vector::push_back(stack, 0)
                };
                i = i + 1;
            }
                //jump
            else if(opcode == 0x56) {
                let dest = vector::pop_back(stack);
                i = (dest as u64) + 1
            }
                //jumpi
            else if(opcode == 0x57) {
                let dest = vector::pop_back(stack);
                let condition = vector::pop_back(stack);
                if(condition > 0) {
                    i = (dest as u64) + 1
                } else {
                    i = i + 1
                }
            }
                //gas
            else if(opcode == 0x5a) {
                vector::push_back(stack, 0);
                i = i + 1
            }
                //jump dest (no action, continue execution)
            else if(opcode == 0x5b) {
                i = i + 1
            }
                //TLOAD
            else if(opcode == 0x5c) {
                let key = vector::pop_back(stack);
                if(simple_map::contains_key(transient, &key)) {
                    vector::push_back(stack, *simple_map::borrow(transient, &key));
                } else {
                    vector::push_back(stack, 0);
                };

                i = i + 1
            }
                //TSTORE
            else if(opcode == 0x5d) {
                let key = vector::pop_back(stack);
                let value = vector::pop_back(stack);
                simple_map::upsert(transient, key, value);
                i = i + 1
            }
                //MCOPY
            else if(opcode == 0x5e) {
                let m_pos = vector::pop_back(stack);
                let d_pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let bytes = slice(*memory, d_pos, len);
                mstore(memory, m_pos, bytes);
                i = i + 1;
            }
                //sha3
            else if(opcode == 0x20) {
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let bytes = slice(*memory, pos, len);
                // debug::print(&value);
                let value = data_to_u256(keccak256(bytes), 0, 32);
                vector::push_back(stack, value);
                i = i + 1
            }
                //call 0xf1 static call 0xfa delegate call 0xf4
            else if(opcode == 0xf1 || opcode == 0xfa || opcode == 0xf4) {
                let _gas = vector::pop_back(stack);
                let evm_dest_addr = to_32bit(u256_to_data(vector::pop_back(stack)));
                // let move_dest_addr = create_resource_address(&@aptos_framework, evm_dest_addr);
                let msg_value = if (opcode == 0xf1) vector::pop_back(stack) else 0;
                let m_pos = vector::pop_back(stack);
                let m_len = vector::pop_back(stack);
                let ret_pos = vector::pop_back(stack);
                let ret_len = vector::pop_back(stack);
                let ret_end = ret_len + ret_pos;
                let params = slice(*memory, m_pos, m_len);

                // debug::print(&utf8(b"call 222"));
                // debug::print(&opcode);
                // debug::print(&dest_addr);
                if (is_precompile_address(evm_dest_addr) || exist_contract(evm_dest_addr, trie)) {
                    let dest_code = get_code(evm_dest_addr, trie);

                    let target = if (opcode == 0xf4) to else evm_dest_addr;
                    let from = if (opcode == 0xf4) sender else to;
                    let (call_res, bytes) = run(sender, from, target, dest_code, params, msg_value, trie, transient);
                    ret_bytes = bytes;
                    let index = 0;

                    while (ret_pos < ret_end) {
                        let bytes = if (ret_end - ret_pos >= 32) {
                            slice(bytes, index, 32)
                        } else {
                            slice(bytes, index, ret_end - ret_pos)
                        };
                        mstore(memory, ret_pos, bytes);
                        ret_pos = ret_pos + 32;
                        index = index + 32;
                    };
                    vector::push_back(stack,  if(call_res) 1 else 0);
                } else {
                    transfer(to, evm_dest_addr, msg_value, trie);
                    vector::push_back(stack, 1);
                };
                // debug::print(&opcode);
                i = i + 1
            }
                //create
            else if(opcode == 0xf0) {
                let msg_value = vector::pop_back(stack);
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let new_codes = slice(*memory, pos, len);
                // let contract_store = borrow_global_mut<Account>(move_contract_address);
                let nonce = get_nonce(to, trie);
                // must be 20 bytes

                let new_evm_contract_addr = get_contract_address(to, (nonce as u64));
                debug::print(&utf8(b"create start"));
                add_nonce(to, trie);


                let(create_res, bytes) = run(sender, to, new_evm_contract_addr, new_codes, x"", msg_value, trie, transient);
                if(create_res) {
                    simple_map::add(trie, new_evm_contract_addr, TestAccount {
                        balance: 0,
                        code: bytes,
                        nonce: 1,
                        storage: simple_map::new<u256, u256>(),
                    });
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
                let msg_value = vector::pop_back(stack);
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let salt = u256_to_data(vector::pop_back(stack));
                let new_codes = slice(*memory, pos, len);
                let p = vector::empty<u8>();
                // let contract_store = ;
                vector::append(&mut p, x"ff");
                // must be 20 bytes
                vector::append(&mut p, slice(to, 12, 20));
                vector::append(&mut p, salt);
                vector::append(&mut p, keccak256(new_codes));
                let new_evm_contract_addr = to_32bit(slice(keccak256(p), 12, 20));

                // to_account.nonce = to_account.nonce + 1;
                add_nonce(to, trie);
                let (create_res, bytes) = run(to, sender, new_evm_contract_addr, new_codes, x"", msg_value, trie, transient);

                if(create_res) {
                    simple_map::add(trie, new_evm_contract_addr, TestAccount {
                        balance: 0,
                        code: bytes,
                        nonce: 1,
                        storage: simple_map::new<u256, u256>(),
                    });

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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let bytes = slice(*memory, pos, len);
                debug::print(&utf8(b"revert"));
                debug::print(&bytes);
                revert(bytes);
            }
                //log0
            else if(opcode == 0xa0) {
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let _data = slice(*memory, pos, len);
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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let _data = slice(*memory, pos, len);
                let _topic0 = u256_to_data(vector::pop_back(stack));
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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let _data = slice(*memory, pos, len);
                let _topic0 = u256_to_data(vector::pop_back(stack));
                let _topic1 = u256_to_data(vector::pop_back(stack));
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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let _data = slice(*memory, pos, len);
                let _topic0 = u256_to_data(vector::pop_back(stack));
                let _topic1 = u256_to_data(vector::pop_back(stack));
                let _topic2 = u256_to_data(vector::pop_back(stack));
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
                let pos = vector::pop_back(stack);
                let len = vector::pop_back(stack);
                let _data = slice(*memory, pos, len);
                let _topic0 = u256_to_data(vector::pop_back(stack));
                let _topic1 = u256_to_data(vector::pop_back(stack));
                let _topic2 = u256_to_data(vector::pop_back(stack));
                let _topic3 = u256_to_data(vector::pop_back(stack));
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
            // debug::print(stack);
            // debug::print(&vector::length(stack));
        };


        (true, ret_bytes)
    }


    // This function is used to execute precompile EVM contracts.
    fun precompile(sender: vector<u8>, to: vector<u8>, value: u256, calldata: vector<u8>, trie: &mut SimpleMap<vector<u8>, TestAccount>): vector<u8> {
        transfer(sender, to, value, trie);
        run_precompile(to, calldata, CHAIN_ID)
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
        vector::append(&mut p, slice(sender, 12, 20));
        vector::append(&mut p, keccak256(salt));
        vector::append(&mut p, hash);
        to_32bit(slice(keccak256(p), 12, 20))
    }

    fun verify_nonce(addr: address, nonce: u64) acquires Account {
        let coin_store_from = borrow_global_mut<Account>(addr);
        assert!(coin_store_from.nonce == nonce, NONCE);
        coin_store_from.nonce = coin_store_from.nonce + 1;
    }

    fun verify_signature(from: vector<u8>, message_hash: vector<u8>, r: vector<u8>, s: vector<u8>, v: u64) {
        let input_bytes = r;
        vector::append(&mut input_bytes, s);
        let signature = ecdsa_signature_from_bytes(input_bytes);
        let recovery_id = if(v > 28) ((v - (CHAIN_ID * 2) - 35) as u8) else ((v - 27) as u8);
        let pk_recover = ecdsa_recover(message_hash, recovery_id, &signature);
        let pk = keccak256(ecdsa_raw_public_key_to_bytes(borrow(&pk_recover)));
        debug::print(&slice(pk, 12, 20));
        assert!(slice(pk, 12, 20) == from, SIGNATURE);
    }

    #[test]
    public fun test_run() acquires Account {
        debug::print(&u256_to_data(0x0ba1a9ce0ba1a9ce));
        let balance = u256_to_data(0x0ba1a9ce0ba1a9ce);
        debug::print(&to_u256(balance));
        run_test(vector[
                x"0000000000000000000000000000000000001000",
                x"0000000000000000000000000000000000001001",
                x"0000000000000000000000000000000000001002",
                x"0000000000000000000000000000000000001003",
                x"0000000000000000000000000000000000001004",
                x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
                x"cccccccccccccccccccccccccccccccccccccccc"
            ],
            vector[
                x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500",
                x"60047fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500",
                x"60017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0160005500",
                x"600060000160005500",
                x"7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff60010160005500",
                x"",
                x"600060006000600060006004356110000162fffffff100"
            ],
            vector[
                0, 0, 0, 0, 0, 0, 0
            ],
            vector[
                balance, balance, balance, balance, balance, balance, balance
            ],
            x"a94f5374fce5edbc8e2a8697c15331677e6ebf0b",
            x"cccccccccccccccccccccccccccccccccccccccc",
            x"693c61390000000000000000000000000000000000000000000000000000000000000000",
            u256_to_data(0x1)
        );
    }


}
