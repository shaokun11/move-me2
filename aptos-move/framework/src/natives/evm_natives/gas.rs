use crate::natives::evm_natives::{
    state::State,
    types::Opcode,
    constants::{gas_cost, CallResult},
    machine::Machine,
    runtime::Runtime,
    utils::{u256_bytes_length, u256_to_address},
    precompile::is_precompile_address
};
use primitive_types::{H160, U256};


const EXP_BYTE: u64 = 50;
const CREATE_BASE_GAS: u64 = 32000;
const INIT_CODE_WORD_COST: u64 = 2;
const SHA3_PER_WORD_GAS: u64 = 6;
const SHA3_BASE_GAS: u64 = 30;
const COLD_SLOAD_COST: u64 = 2100;
const WARM_SLOAD_COST: u64 = 100;
const CALL_STIPEND: u64 = 2300;

const SSTORE_NOOP_GAS_EIP2200: u64 = 100;
const SSTORE_INIT_GAS_EIP2200: u64 = 20000;
const SSTORE_CLEAN_GAS_EIP2200: u64 = 2900;
const SSTORE_DIRTY_GAS_EIP2200: u64 = 100;
const SSTORE_CLEAR_REFUND_EIP2200: u64 = 4800;
const SSTORE_INIT_REFUND_EIP2200: u64 = 19900;
const SSTORE_CLEAN_REFUND_EIP2200: u64 = 2800;
const SSTORE_SENTRY_GAS_EIP2200: u64 = 2300;

/// Calculate the additional gas cost for cold address access
pub fn calc_cold_address_access(state: &mut State, address: H160) -> u64 {
    if state.is_cold_address(address) && !is_precompile_address(address) {
        2600 // Additional cost for cold address access
    } else {
        100 // Cost for warm address access
    }
}

/// Calculate the gas cost for memory expansion
pub fn calc_memory_expand(machine: &mut Machine, offset: U256, size: U256, gas_limit: u64) -> (CallResult, u64) {
    let current_words = machine.get_memory_word_size();
    let new_words = match offset.checked_add(size) {
        Some(end) => {
            if end > U256::from(u64::MAX) {
                return (CallResult::Exception, 0);  // Overflow
            }
            (end.as_u64().saturating_add(31) / 32) as u64
        },
        None => return (CallResult::Exception, 0),  // Overflow
    };

    if new_words <= current_words {
        return (CallResult::Success, 0);  // No expansion needed
    }

    // Calculate new memory cost
    let new_memory_cost = (new_words.saturating_mul(new_words) / 512).saturating_add(3 * new_words);
    let old_memory_cost = machine.get_memory_cost();

    // Calculate memory expansion gas cost
    let memory_expansion_cost = new_memory_cost.saturating_sub(old_memory_cost);

    // Check if the expansion cost exceeds the gas limit
    if memory_expansion_cost > gas_limit {
        return (CallResult::OutOfGas, 0);
    }

    // Update memory word size and memory cost in runtime
    machine.set_memory_word_size(new_words);
    machine.set_memory_cost(new_memory_cost);

    (CallResult::Success, memory_expansion_cost)
}

/// Calculate the gas cost for memory operations involving copying
pub fn calc_memory_copy_gas(
    machine: &mut Machine,
    memory_offset: U256,
    length: U256,
    gas_limit: u64,
    base_gas: u64,
    copy_gas_per_word: u64
) -> (CallResult, u64) {
    // Calculate memory expansion cost
    let (mem_result, mem_gas) = calc_memory_expand(machine, memory_offset, length, gas_limit);
    if mem_result != CallResult::Success {
        return (mem_result, 0);
    }

    let total_gas = if copy_gas_per_word == 0 {
        // If copy_gas_per_word is 0, we only need to consider base_gas and memory expansion
        base_gas.saturating_add(mem_gas)
    } else {
        // Calculate copy cost: copy_gas_per_word for each 32-byte word (rounded up)
        if length > U256::from(u64::MAX) {
            return (CallResult::OutOfGas, 0);  // Length is too large
        }
        let length_u64 = length.as_u64();
        let words = (length_u64 + 31) / 32;
        match words.checked_mul(copy_gas_per_word) {
            Some(copy_gas) => {
                match base_gas.checked_add(mem_gas).and_then(|sum| sum.checked_add(copy_gas)) {
                    Some(total) => total,
                    None => return (CallResult::OutOfGas, 0),  // Overflow
                }
            },
            None => return (CallResult::OutOfGas, 0),  // Overflow
        }
    };

    if total_gas > gas_limit {
        (CallResult::OutOfGas, 0)
    } else {
        (CallResult::Success, total_gas)
    }
}

pub fn calc_base_cost(data: &[u8], access_list_address_len: u64, access_list_slot_len: u64) -> u64 {
    let zero_data_len = (data.iter().filter(|v| **v == 0).count()) as u64;
	let non_zero_data_len = (data.len() as u64) - zero_data_len;
    let data_cost = zero_data_len * gas_cost::DATA_ZERO_COST + non_zero_data_len * gas_cost::DATA_NOT_ZERO_COST;
    let access_list_cost = access_list_address_len * gas_cost::ACCESS_LIST_ADDRESS +
                            access_list_slot_len * gas_cost::ACCESS_LIST_SLOT;
    
    data_cost + access_list_cost
} 

fn calc_exp_gas(machine: &Machine) -> (CallResult, u64) {
    if machine.stack.len() < 1 {
        return (CallResult::Exception, 0);
    }
    let exponent = machine.stack.peek(1).unwrap_or_default();

    if exponent.is_zero() {
        return (CallResult::Success, 0);
    }

    let byte_length = u256_bytes_length(exponent);
    (CallResult::Success, EXP_BYTE * byte_length + 10) 
}

/// Calculate gas cost for call operations (CALL, CALLCODE, DELEGATECALL, STATICCALL)
fn calc_call_gas(
    opcode: Opcode,
    machine: &mut Machine,
    state: &mut State,
    gas_limit: u64,
) -> (CallResult, u64) {
    let address_index = 1;
    let (value_index, in_offset_index, in_size_index, out_offset_index, out_size_index, required_stack_items) = match opcode {
        Opcode::CALL | Opcode::CALLCODE => (2, 3, 4, 5, 6, 7),
        Opcode::DELEGATECALL | Opcode::STATICCALL => (usize::MAX, 2, 3, 4, 5, 6),
        _ => unreachable!(),
    };

    if machine.stack.len() < required_stack_items {
        return (CallResult::Exception, 0);
    }

    let address = u256_to_address(machine.stack.peek(address_index).unwrap_or_default());
    let cold_cost = calc_cold_address_access(state, address);
    
    let in_offset = machine.stack.peek(in_offset_index).unwrap_or_default();
    let in_size = machine.stack.peek(in_size_index).unwrap_or_default();
    let out_offset = machine.stack.peek(out_offset_index).unwrap_or_default();
    let out_size = machine.stack.peek(out_size_index).unwrap_or_default();

    let (result, in_gas) = calc_memory_copy_gas(machine, in_offset, in_size, gas_limit, 0, 0);
    if result != CallResult::Success {
        return (result, 0);
    }

    let (result, out_gas) = calc_memory_copy_gas(machine, out_offset, out_size, gas_limit, 0, 0);
    if result != CallResult::Success {
        return (result, 0);
    }

    let mut extra_gas: u64 = 0;

    // Check if the call has a value (only for CALL and CALLCODE)
    if opcode == Opcode::CALL || opcode == Opcode::CALLCODE {
        let value = machine.stack.peek(value_index).unwrap_or_default();
        if value != U256::zero() {
            extra_gas = extra_gas.saturating_add(9000);

            // Check if the account exists
            if !state.exist(address) && (opcode == Opcode::CALL) {
                extra_gas = extra_gas.saturating_add(25000);
            }
        }
    }

    let total_gas = cold_cost
        .saturating_add(in_gas)
        .saturating_add(out_gas)
        .saturating_add(extra_gas);

    if total_gas > gas_limit {
        (CallResult::OutOfGas, 0)
    } else {
        (CallResult::Success, total_gas)
    }
}

/// Calculate gas cost for EXTCODECOPY operation
fn calc_extcodecopy_gas(
    machine: &mut Machine,
    state: &mut State,
    gas_limit: u64,
) -> (CallResult, u64) {
    if machine.stack.len() < 4 {
        return (CallResult::Exception, 0);
    }
    let address = u256_to_address(machine.stack.peek(0).unwrap_or_default());
    let memory_offset = machine.stack.peek(1).unwrap_or_default();
    let length = machine.stack.peek(3).unwrap_or_default();

    // Calculate cold address access cost
    let cold_cost = calc_cold_address_access(state, address);

    // Calculate memory expansion and copy cost
    let (mem_result, mem_copy_gas) = calc_memory_copy_gas(machine, memory_offset, length, gas_limit, 0, 3);
    if mem_result != CallResult::Success {
        return (mem_result, 0);
    }

    // Total gas is cold_cost + memory expansion and copy gas
    match cold_cost.checked_add(mem_copy_gas) {
        Some(total_gas) => {
            if total_gas > gas_limit {
                (CallResult::OutOfGas, 0)
            } else {
                (CallResult::Success, total_gas)
            }
        },
        None => (CallResult::OutOfGas, 0), // Overflow
    }
}

/// Calculate gas cost for KECCAK256 (SHA3) operation
fn calc_keccak256_gas(
    machine: &mut Machine,
    gas_limit: u64,
) -> (CallResult, u64) {
    if machine.stack.len() < 2 {
        return (CallResult::Exception, 0);
    }
    let offset = machine.stack.peek(0).unwrap_or_default();
    let size = machine.stack.peek(1).unwrap_or_default();

    // Calculate memory expansion cost
    let (mem_result, mem_gas) = calc_memory_copy_gas(machine, offset, size, gas_limit, 0, 0);
    if mem_result != CallResult::Success {
        return (mem_result, mem_gas);
    }

    // Calculate KECCAK256 operation cost
    // Base cost is 30 gas, plus 6 gas for every 32-byte word (rounded up)
    let words = (size + U256::from(31)) / U256::from(32);
    let keccak_gas = U256::from(30) + words * U256::from(6);

    // Total gas is memory expansion gas + KECCAK256 operation gas
    let total_gas = U256::from(mem_gas).saturating_add(keccak_gas);

    // Convert total_gas to u64 and check for overflow
    match u64::try_from(total_gas) {
        Ok(gas) => (CallResult::Success, gas),
        Err(_) => (CallResult::OutOfGas, 0),
    }
}

/// Calculate gas cost for LOG operations
fn calc_log_gas(
    opcode: Opcode,
    machine: &mut Machine,
    gas_limit: u64,
) -> (CallResult, u64) {
    // Calculate LOG operation cost
    // Base cost is 375 gas, plus 375 gas per topic, plus 8 gas per byte of data
    let topic_count = match opcode {
        Opcode::LOG0 => 0,
        Opcode::LOG1 => 1,
        Opcode::LOG2 => 2,
        Opcode::LOG3 => 3,
        Opcode::LOG4 => 4,
        _ => unreachable!(),
    };

    if machine.stack.len() < topic_count + 2 {
        return (CallResult::Exception, 0);
    }
    let offset = machine.stack.peek(0).unwrap_or_default();
    let size = machine.stack.peek(1).unwrap_or_default();

    // Calculate memory expansion cost
    let (mem_result, mem_gas) = calc_memory_copy_gas(machine, offset, size, gas_limit, 0, 0);
    if mem_result != CallResult::Success {
        return (mem_result, mem_gas);
    }

    let log_gas = U256::from(375)
        .saturating_add(U256::from(topic_count * 375))
        .saturating_add(size * U256::from(8));

    // Total gas is memory expansion gas + LOG operation gas
    let total_gas = U256::from(mem_gas).saturating_add(log_gas);

    // Convert total_gas to u64 and check for overflow
    match u64::try_from(total_gas) {
        Ok(gas) => (CallResult::Success, gas),
        Err(_) => (CallResult::OutOfGas, 0),
    }
}

/// Calculate initial gas cost for CREATE operation
fn calc_create_gas(
    machine: &mut Machine,
    gas_limit: u64,
) -> (CallResult, u64) {
    if machine.stack.len() < 3 {
        return (CallResult::Exception, 0);
    }

    let offset = machine.stack.peek(1).unwrap_or_default();
    let size = machine.stack.peek(2).unwrap_or_default();

    // Calculate memory expansion cost
    let (mem_result, mem_gas) = calc_memory_copy_gas(machine, offset, size, gas_limit, 0, 0);
    if mem_result != CallResult::Success {
        return (mem_result, mem_gas);
    }

    // Calculate init code cost
    let words = (size + U256::from(31)) / U256::from(32);
    let init_code_cost = words * U256::from(INIT_CODE_WORD_COST);

    // Total initial gas is memory expansion gas + CREATE base cost + init code cost
    let total_gas = U256::from(mem_gas)
        .saturating_add(U256::from(CREATE_BASE_GAS))
        .saturating_add(init_code_cost);

    // Convert total_gas to u64 and check for overflow
    match u64::try_from(total_gas) {
        Ok(gas) => (CallResult::Success, gas),
        Err(_) => (CallResult::OutOfGas, 0),
    }
}

/// Calculate initial gas cost for CREATE2 operation
fn calc_create2_gas(
    machine: &mut Machine,
    gas_limit: u64,
) -> (CallResult, u64) {
    if machine.stack.len() < 4 {
        return (CallResult::Exception, 0);
    }

    let offset = machine.stack.peek(1).unwrap_or_default();
    let size = machine.stack.peek(2).unwrap_or_default();

    // Calculate memory expansion cost
    let (mem_result, mem_gas) = calc_memory_copy_gas(machine, offset, size, gas_limit, 0, 0);
    if mem_result != CallResult::Success {
        return (mem_result, mem_gas);
    }

    // Calculate init code cost
    let words = (size + U256::from(31)) / U256::from(32);
    let init_code_cost = words * U256::from(INIT_CODE_WORD_COST);

    // Additional cost for SHA3 operation (used to compute the contract address)
    let sha3_gas = words * U256::from(SHA3_PER_WORD_GAS) + U256::from(SHA3_BASE_GAS);

    // Total initial gas is memory expansion gas + CREATE2 base cost + init code cost + SHA3 cost
    let total_gas = U256::from(mem_gas)
        .saturating_add(U256::from(CREATE_BASE_GAS))
        .saturating_add(init_code_cost)
        .saturating_add(sha3_gas);

    // Convert total_gas to u64 and check for overflow
    match u64::try_from(total_gas) {
        Ok(gas) => (CallResult::Success, gas),
        Err(_) => (CallResult::OutOfGas, 0),
    }
}

/// Calculate gas cost for SLOAD operation
fn calc_sload_gas(
    machine: &Machine,
    state: &mut State,
    address: &H160,
) -> (CallResult, u64) {
    if machine.stack.len() < 1 {
        return (CallResult::Exception, 0);
    }

    let key = machine.stack.peek(0).unwrap_or_default();

    if state.is_cold_slot(*address, key) {
        (CallResult::Success, COLD_SLOAD_COST)
    } else {
        (CallResult::Success, WARM_SLOAD_COST)
    }
}

/// Calculate gas cost for SSTORE operation
fn calc_sstore_gas(
    machine: &Machine,
    state: &mut State,
    address: &H160,
    runtime: &mut Runtime,
) -> (CallResult, u64) {
    if runtime.get_gas_left() < SSTORE_SENTRY_GAS_EIP2200 {
        return (CallResult::OutOfGas, 0);
    };

    if machine.stack.len() < 2 {
        return (CallResult::Exception, 0);
    }

    let key = machine.stack.peek(0).unwrap_or_default();
    let new = machine.stack.peek(1).unwrap_or_default();

    let (is_cold_slot, origin) = state.get_origin(*address, key);
    let current = state.get_storage(*address, key);

    let cold_cost = if is_cold_slot { COLD_SLOAD_COST } else { 0 };
    let mut gas_cost = cold_cost;

    if current == new {
        gas_cost += SSTORE_NOOP_GAS_EIP2200;
    } else {
        if origin == current {
            if origin == U256::zero() {
                gas_cost += SSTORE_INIT_GAS_EIP2200;
            } else {
                if new == U256::zero() {
                    runtime.add_gas_refund(SSTORE_CLEAR_REFUND_EIP2200);
                }
                gas_cost += SSTORE_CLEAN_GAS_EIP2200;
            }
        } else {
            gas_cost += SSTORE_DIRTY_GAS_EIP2200;
            if origin != U256::zero() {
                if current == U256::zero() {
                    runtime.sub_gas_refund(SSTORE_CLEAR_REFUND_EIP2200);
                } else if new == U256::zero() {
                    runtime.add_gas_refund(SSTORE_CLEAR_REFUND_EIP2200);
                }
            }
            if new == origin {
                if origin == U256::zero() {
                    runtime.add_gas_refund(SSTORE_INIT_REFUND_EIP2200);
                } else {
                    runtime.add_gas_refund(SSTORE_CLEAN_REFUND_EIP2200);
                }
            }
        }
    }

    (CallResult::Success, gas_cost)
}

pub fn calc_create_storage_gas(code_size: usize) -> u64 {
    // 200 gas per byte of the resulting contract code
    200 * code_size as u64
}

pub fn max_call_gas(gas_left: u64, gas_limit: u64, value: U256, need_stipend: bool) ->(u64, u64) {
    let gas_allow = gas_left - gas_left / 64;
    let mut gas_limit = if gas_limit > gas_allow { gas_allow } else { gas_limit };
    let mut gas_stipend = 0;
    if need_stipend && value != U256::zero() {
        gas_stipend = gas_stipend + CALL_STIPEND;
        gas_limit = gas_limit + CALL_STIPEND;
    };
    (gas_limit, gas_stipend)
}

pub fn calc_exec_gas(state: &mut State, opcode: Opcode, address: &H160, machine: &mut Machine, runtime: &mut Runtime) -> (CallResult, u64) {
    let gas_limit = runtime.get_gas_left();
    match opcode {
        Opcode::STOP => (CallResult::Success, 0),
        Opcode::ADD => (CallResult::Success, 3),
        Opcode::MUL => (CallResult::Success, 5),
        Opcode::SUB => (CallResult::Success, 3),
        Opcode::DIV => (CallResult::Success, 5),
        Opcode::SDIV => (CallResult::Success, 5),
        Opcode::MOD => (CallResult::Success, 5),
        Opcode::SMOD => (CallResult::Success, 5),
        Opcode::ADDMOD => (CallResult::Success, 8),
        Opcode::MULMOD => (CallResult::Success, 8),
        Opcode::SIGNEXTEND => (CallResult::Success, 5),
        Opcode::LT => (CallResult::Success, 3),
        Opcode::GT => (CallResult::Success, 3),
        Opcode::SLT => (CallResult::Success, 3),
        Opcode::SGT => (CallResult::Success, 3),
        Opcode::EQ => (CallResult::Success, 3),
        Opcode::ISZERO => (CallResult::Success, 3),
        Opcode::AND => (CallResult::Success, 3),
        Opcode::OR => (CallResult::Success, 3),
        Opcode::XOR => (CallResult::Success, 3),
        Opcode::NOT => (CallResult::Success, 3),
        Opcode::BYTE => (CallResult::Success, 3),
        Opcode::SHL => (CallResult::Success, 3),
        Opcode::SHR => (CallResult::Success, 3),
        Opcode::SAR => (CallResult::Success, 3),
        Opcode::ADDRESS => (CallResult::Success, 2),
        Opcode::ORIGIN => (CallResult::Success, 2),
        Opcode::CALLER => (CallResult::Success, 2),
        Opcode::CALLVALUE => (CallResult::Success, 2),
        Opcode::CALLDATALOAD => (CallResult::Success, 3),
        Opcode::CALLDATASIZE => (CallResult::Success, 2),
        Opcode::CODESIZE => (CallResult::Success, 2),
        Opcode::GASPRICE => (CallResult::Success, 2),
        Opcode::RETURNDATASIZE => (CallResult::Success, 2),
        Opcode::BLOCKHASH => (CallResult::Success, 20),
        Opcode::COINBASE => (CallResult::Success, 2),
        Opcode::TIMESTAMP => (CallResult::Success, 2),
        Opcode::NUMBER => (CallResult::Success, 2),
        Opcode::DIFFICULTY => (CallResult::Success, 2),
        Opcode::GASLIMIT => (CallResult::Success, 2),
        Opcode::CHAINID => (CallResult::Success, 2),
        Opcode::SELFBALANCE => (CallResult::Success, 5),
        Opcode::BASEFEE => (CallResult::Success, 2),
        Opcode::BLOBHASH => (CallResult::Success, 3),
        Opcode::BLOBBASEFEE => (CallResult::Success, 2),
        Opcode::POP => (CallResult::Success, 2),
        Opcode::JUMP => (CallResult::Success, 8),
        Opcode::JUMPI => (CallResult::Success, 10),
        Opcode::PC => (CallResult::Success, 2),
        Opcode::MSIZE => (CallResult::Success, 2),
        Opcode::GAS => (CallResult::Success, 2),
        Opcode::JUMPDEST => (CallResult::Success, 1),
        Opcode::TLOAD => (CallResult::Success, 100),
        Opcode::TSTORE => (CallResult::Success, 100),
        Opcode::PUSH0 => (CallResult::Success, 2),
        Opcode(op) if (0x60..=0x7f).contains(&op) => (CallResult::Success, 3),  // PUSH1 to PUSH32
        Opcode(op) if (0x80..=0x8f).contains(&op) => (CallResult::Success, 3),  // DUP1 to DUP16
        Opcode(op) if (0x90..=0x9f).contains(&op) => (CallResult::Success, 3),  // SWAP1 to SWAP16
        Opcode::EXP => calc_exp_gas(machine),  // return calc_exp_gas
        Opcode::MSTORE | Opcode::MLOAD => {
            let offset = machine.stack.peek(0).unwrap_or_default();
            calc_memory_copy_gas(machine, offset, U256::from(32), gas_limit, 3, 0)
        },
        Opcode::MSTORE8 => {
            let offset = machine.stack.peek(0).unwrap_or_default();
            calc_memory_copy_gas(machine, offset, U256::from(1), gas_limit, 3, 0)
        },
        Opcode::CALLDATACOPY | Opcode::CODECOPY | Opcode::RETURNDATACOPY => {
            let memory_offset = machine.stack.peek(0).unwrap_or_default();
            let length = machine.stack.peek(2).unwrap_or_default();
            calc_memory_copy_gas(machine, memory_offset, length, gas_limit, 3, 3)
        },
        Opcode::MCOPY => {
            let dest_offset = machine.stack.peek(0).unwrap_or_default();
            let source_offset = machine.stack.peek(1).unwrap_or_default();
            let length = machine.stack.peek(2).unwrap_or_default();
            
            // Calculate gas for reading from source memory
            let (read_result, read_gas) = calc_memory_copy_gas(machine, source_offset, length, gas_limit, 0, 0);
            if read_result != CallResult::Success {
                return (read_result, read_gas);
            }
            
            // Calculate gas for writing to destination memory
            let (write_result, write_gas) = calc_memory_copy_gas(machine, dest_offset, length, gas_limit, 3, 3);
            if write_result != CallResult::Success {
                return (write_result, write_gas);
            }
            
            (CallResult::Success, read_gas + write_gas)
        },
        Opcode::CALL | Opcode::CALLCODE | Opcode::DELEGATECALL | Opcode::STATICCALL => {
            calc_call_gas(opcode, machine, state, gas_limit)
        },
        Opcode::BALANCE | Opcode::EXTCODESIZE | Opcode::EXTCODEHASH => {
            let address = u256_to_address(machine.stack.peek(0).unwrap_or_default());
            let cold_cost = calc_cold_address_access(state, address);
            (CallResult::Success, cold_cost)
        },
        Opcode::EXTCODECOPY => calc_extcodecopy_gas(machine, state, gas_limit),
        Opcode::SHA3 => calc_keccak256_gas(machine, gas_limit),
        Opcode::LOG0 | Opcode::LOG1 | Opcode::LOG2 | Opcode::LOG3 | Opcode::LOG4 => {
            calc_log_gas(opcode, machine, gas_limit)
        },
        Opcode::CREATE => calc_create_gas(machine, gas_limit),
        Opcode::CREATE2 => calc_create2_gas(machine, gas_limit),
        Opcode::SLOAD => calc_sload_gas(machine, state, address),
        Opcode::SSTORE => calc_sstore_gas(machine, state, address, runtime),
        Opcode::RETURN | Opcode::REVERT => {
            let offset = machine.stack.peek(0).unwrap_or_default();
            let size = machine.stack.peek(1).unwrap_or_default();
            calc_memory_copy_gas(machine, offset, size, gas_limit, 0, 0)
        },
        _ => (CallResult::Success, 3), 
    }
}