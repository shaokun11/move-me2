use crate::natives::evm_natives::{
    state::State,
    types::{Environment, RunArgs, TransactArgs, Opcode, ExecutionError},
    constants::{gas_cost, limit, CallResult, TxResult, TxType},
    runtime::Runtime,
    precompile::{is_precompile_address, run_precompile},
    machine::Machine,
    gas::{calc_exec_gas, max_call_gas},
    arithmetic,
    utils::{h160_to_u256, u256_to_bytes}
};

use primitive_types::{H160, U256};
use ethers::utils::{keccak256, get_create2_address, get_contract_address};


fn calc_base_cost(data: &[u8], access_list_address_len: u64, access_list_slot_len: u64) -> u64 {
    let zero_data_len = (data.iter().filter(|v| **v == 0).count()) as u64;
	let non_zero_data_len = (data.len() as u64) - zero_data_len;
    let data_cost = zero_data_len * gas_cost::DATA_ZERO_COST + non_zero_data_len * gas_cost::DATA_NOT_ZERO_COST;
    let access_list_cost = access_list_address_len * gas_cost::ACCESS_LIST_ADDRESS +
                            access_list_slot_len * gas_cost::ACCESS_LIST_SLOT;
    
    data_cost + access_list_cost + gas_cost::TX_BASE
}


pub fn new_tx(state: &mut State, run_args: &mut RunArgs, tx_args: &TransactArgs, env: &Environment, tx_type: TxType, access_list_address_len: u64, access_list_slot_len: u64) -> TxResult {
    
    let mut runtime = Runtime::new();
    runtime.new_checkpoint(tx_args.gas_limit.as_u64(), false);

    state.add_warm_address(run_args.caller);
    state.add_warm_address(env.block_coinbase);
    
    let data_size = run_args.data.len();
    let mut base_cost = calc_base_cost(&run_args.data, access_list_address_len, access_list_slot_len);

    // Check if gas_limit * gas_price + value overflows
    let up_cost = match tx_args.gas_price.checked_mul(tx_args.gas_limit) {
        Some(cost) => match cost.checked_add(run_args.value) {
            Some(total) => total,
            None => return TxResult::ExceptionGasLimitExceedBlockLimit,
        },
        None => return TxResult::ExceptionGasLimitExceedBlockLimit,
    };

    match tx_type {
        TxType::Eip1559 => {
            if env.block_base_fee_per_gas > tx_args.max_fee_per_gas || tx_args.max_priority_fee_per_gas > tx_args.max_fee_per_gas {
                return TxResult::Exception1559MaxFeeLowerThanBaseFee;
            }
        }
        _ => {
            if env.block_base_fee_per_gas > tx_args.gas_price {
                return TxResult::ExceptionLegacyGasPriceLowerThanBaseFee;
            }
        }
    }


    if tx_args.gas_limit > env.block_gas_limit {
        return TxResult::ExceptionGasLimitExceedBlockLimit;
    }

    if run_args.is_create {
        if data_size > limit::INIT_CODE_SIZE {
            return TxResult::ExceptionCreateContractCodeSizeExceed;
        }
        let word_count = ((data_size + 31) / 32) as u64; 
        base_cost = base_cost
            .saturating_add(word_count.saturating_mul(gas_cost::CREATE_SIZE_PER_BYTES))
            .saturating_add(gas_cost::CREATE_BASE);
    }

    

    let from_balance = state.get_balance(run_args.caller);
    if from_balance < up_cost {
        return TxResult::ExceptionInsufficientBalanceToSendTx;
    }

    if state.get_code_length(run_args.caller) > 0 {
        return TxResult::ExceptionSenderNotEOA;
    }

    if tx_args.gas_limit.as_u64() < base_cost {
        return TxResult::ExceptionOutOfGas;
    }

    state.sub_balance(run_args.caller, tx_args.gas_limit.saturating_mul(tx_args.gas_price));
    runtime.add_gas_usage(base_cost);
    let mut created_address = H160::zero();
    let mut exception = TxResult::ExceptionNone;
    let mut message = Vec::new();
    let result;

    if run_args.is_create {
        let evm_contract = get_contract_address(run_args.caller, state.get_nonce(run_args.caller));
        if state.is_contract_or_created_account(evm_contract) {
            runtime.add_gas_usage(tx_args.gas_limit.as_u64());
            return TxResult::ExceptionCreateContractCodeSizeExceed;
        } else {
            let gas_left = runtime.get_gas_left();
            handle_new_checkpoint(state, &mut runtime, gas_left, false);
            run_args.address = evm_contract;
            result = run(state, &mut runtime, run_args, env, true, 0);

            match result.0 {
                CallResult::Success => {
                    created_address = evm_contract;
                    state.set_code(evm_contract, result.1);
                }
                CallResult::OutOfGas => {
                    exception = TxResult::ExceptionOutOfGas;
                }
                CallResult::Revert => {
                    exception = TxResult::ExceptionExecuteRevert;
                    message = result.1;
                }
                CallResult::Exception => {
                    exception = TxResult::ExceptionExecuteRevert;
                }
                CallResult::Exit => {
                    exception = TxResult::ExecptionExit;
                }
            }
        }
    } else {
        let call_gas_limit = tx_args.gas_limit.as_u64().saturating_sub(base_cost);
        if is_precompile_address(run_args.address) {
            result = precompile(run_args, &mut runtime, state, call_gas_limit, true, run_args.address);
        } else {
            handle_new_checkpoint(state, &mut runtime, call_gas_limit, false);
            result = run(state, &mut runtime, run_args, env, true, 0);
        }

        match result.0 {
            CallResult::Success => {}
            CallResult::OutOfGas => {
                exception = TxResult::ExceptionOutOfGas;
            }
            CallResult::Exit => {
                exception = TxResult::ExecptionExit;
            }
            _ => {
                exception = TxResult::ExceptionExecuteRevert;
            }
        }
    }

    let gas_refund = runtime.get_gas_refund();
    let gas_left = runtime.get_gas_left();
    let mut gas_usage = tx_args.gas_limit.as_u64().saturating_sub(gas_left);
    let gas_refund = if gas_refund > gas_usage / 5 {
        gas_usage / 5
    } else {
        gas_refund
    };
    gas_usage = gas_usage.saturating_sub(gas_refund);

    state.inc_nonce(run_args.caller);
    
    let basefee = env.block_base_fee_per_gas;
    if basefee < tx_args.gas_price {
        let miner_value = (tx_args.gas_price - basefee).saturating_mul(U256::from(gas_usage));
        state.add_balance(env.block_coinbase, miner_value);
    }
    
    state.add_balance(run_args.caller, tx_args.gas_price.saturating_mul(U256::from(gas_left + gas_refund)));

    // println!()
    let exec_cost = gas_usage - base_cost;
    println!("Execution cost: {:?} {:?} {:?}", exec_cost, gas_usage, gas_refund);
    println!("Created address: {:?}", created_address);
    println!("Ret value {:?}", message);
    exception
}

fn precompile(run_args: &RunArgs, runtime: &mut Runtime, state: &mut State, gas_limit: u64, transfer_eth: bool, code_address: H160) -> (CallResult, Vec<u8>) {
    if transfer_eth {
        if state.get_balance(run_args.caller) < run_args.value {
            return (CallResult::Exception, vec![])
        }
    }


    let (call_result, mut gas, ret_val) = run_precompile(code_address, run_args.data.clone(), gas_limit);
    if call_result != CallResult::Success || gas > gas_limit  {
        gas = gas_limit;
    }
    
    println!("precompile result {:?} {:?}", call_result, gas);
    runtime.add_gas_usage(gas);

    if call_result == CallResult::Success && transfer_eth && run_args.value > U256::zero() {
        state.sub_balance(run_args.caller, run_args.value);
        state.add_balance(run_args.address, run_args.value);
    }

    (call_result, ret_val)
}

macro_rules! pop_stack {
    ($stack:expr) => {
        $stack.pop()?
    };
}

 
fn run(state: &mut State, runtime: &mut Runtime, args: &RunArgs, env: &Environment, transfer_eth: bool, depth: usize) -> (CallResult, Vec<u8>) {
    state.add_warm_address(args.address);

    if args.is_create {
        state.new_account(args.address, vec![], U256::zero(), U256::one());
    }

    if transfer_eth {
        if !state.transfer(args.caller, args.address, args.value) {
            return (CallResult::Exception, vec![])
        }
    }

    let mut machine = Machine::new(limit::STACK_SIZE, &args.code);
    let len = args.code.len();
    while machine.pc < len {
        let opcode = Opcode(args.code[machine.pc]);
        
        println!("{}", opcode);


        let (gas_result, gas_cost) = calc_exec_gas(state, opcode, &args.address, &mut machine, runtime);
        println!("gas_cost {}", gas_cost);
        println!("gas_left {:?}", runtime.get_gas_left());
        println!("pc {}", machine.pc);
        let out_of_gas = !runtime.add_gas_usage(gas_cost);
        if out_of_gas {
            handle_unexpect_revert(state, runtime);
            println!("Out of gas");
            return (CallResult::OutOfGas, machine.get_ret_value());
        }

        machine.add_pc(1);
        if gas_result != CallResult::Success {
            handle_unexpect_revert(state, runtime);
            println!("gas result {:?}", gas_result);
            return (gas_result, machine.get_ret_value());
        }
        
        match step(opcode, args, &mut machine, state, runtime, env, depth) {
            Err(ExecutionError::Stop) => {
                println!("Step result: Stop");
                break;
            }
            Err(ExecutionError::Revert) => {
                println!("Step result: Revert");
                return (CallResult::Revert, machine.get_ret_value());
            }
            Ok(_) => {

            }
            Err(ExecutionError::Exit) => {
                return (CallResult::Exit, machine.get_ret_value());
            }
            Err(err) => {
                println!("Step result: Unexpected error - {:?}", err);
                handle_unexpect_revert(state, runtime);
                return (CallResult::Exception, machine.get_ret_value());
            }
        }

        println!("{:?}", machine.stack.data());
    }

    if args.is_create {
        let deployed_code_size = machine.get_ret_value().len();
        let out_of_gas = !runtime.add_gas_usage(200 * deployed_code_size as u64);
        if out_of_gas {
            handle_unexpect_revert(state, runtime);
            return (CallResult::OutOfGas, vec![]);
        }
        let ret_value = machine.get_ret_value();
        if deployed_code_size > limit::INIT_CODE_SIZE || (deployed_code_size > 0 && ret_value[0] == 0xef){
            handle_unexpect_revert(state, runtime);
            return (CallResult::Exception, vec![]);
        }


    }

    handle_commit(state, runtime);
    (CallResult::Success, machine.get_ret_value())
}

fn step(opcode: Opcode, args: &RunArgs, machine: &mut Machine, state: &mut State, runtime: &mut Runtime, env: &Environment, depth: usize) -> Result<(), ExecutionError> {
    match opcode {
        Opcode::STOP => Err(ExecutionError::Stop),
        Opcode::RETURN => {
            let start = pop_stack!(machine.stack);
            let len = pop_stack!(machine.stack);
            machine.memory.resize_offset(start, len)?;
            machine.memory.resize_to_range(start..(start + len));
            machine.memory.swap_and_clear(&mut machine.ret_value);
            Err(ExecutionError::Stop)
        },
        Opcode::ADD => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a.overflowing_add(b).0;
            machine.stack.push(result)
        },
        Opcode::MUL => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a.overflowing_mul(b).0;
            machine.stack.push(result)
        },
        Opcode::SUB => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a.overflowing_sub(b).0;
            machine.stack.push(result)
        },
        Opcode::DIV => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = if b.is_zero() { U256::zero() } else { a / b };
            machine.stack.push(result)
        },
        Opcode::SDIV => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::sdiv(a, b))
        }
        Opcode::MOD => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            
            let result = if b.is_zero() {
                U256::zero()
            } else {
                a % b
            };
            
            machine.stack.push(result)
        },
        Opcode::SMOD => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::smod(a, b))
        },
        Opcode::ADDMOD => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let c = pop_stack!(machine.stack);
        
            machine.stack.push(arithmetic::addmod(a, b, c))
        },
        Opcode::MULMOD => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let c = pop_stack!(machine.stack);
        
            machine.stack.push(arithmetic::mulmod(a, b, c))
        },
        Opcode::EXP => {
            let base = pop_stack!(machine.stack);
            let exponent = pop_stack!(machine.stack);
            let result = base.overflowing_pow(exponent).0;
            machine.stack.push(result)
        },
        Opcode::SIGNEXTEND => {
            let op1 = pop_stack!(machine.stack);
            let op2 = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::signextend(op1, op2))
        },
        Opcode::LT => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = if a < b { U256::one() } else { U256::zero() };
            machine.stack.push(result)
        },
        Opcode::GT => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = if a > b { U256::one() } else { U256::zero() };
            machine.stack.push(result)
        },
        Opcode::SLT => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::slt(a, b))
        },
        Opcode::SGT => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::sgt(a, b))
        },
        Opcode::EQ => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = if a == b { U256::one() } else { U256::zero() };
            machine.stack.push(result)
        },
        Opcode::ISZERO => {
            let value = pop_stack!(machine.stack);
            let result = if value.is_zero() { U256::one() } else { U256::zero() };
            machine.stack.push(result)
        },
        Opcode::AND => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a & b;
            machine.stack.push(result)
        },
        Opcode::OR => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a | b;
            machine.stack.push(result)
        },
        Opcode::XOR => {
            let a = pop_stack!(machine.stack);
            let b = pop_stack!(machine.stack);
            let result = a ^ b;
            machine.stack.push(result)
        },
        Opcode::NOT => {
            let a = pop_stack!(machine.stack);
            let result = !a;
            machine.stack.push(result)
        },
        Opcode::BYTE => {
            let n = pop_stack!(machine.stack);
            let x = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::byte(n, x))
        },
        Opcode::SHL => {
            let shift = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::shl(shift, value))
        },
        Opcode::SHR => {
            let shift = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            machine.stack.push(arithmetic::shr(shift, value))
        },
        Opcode::SAR => {
            let shift = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            let result = arithmetic::sar(shift, value);
            machine.stack.push(result)
        },
        Opcode::PUSH0 => {
            machine.stack.push(U256::zero())
        },
        //push1 - push32
        Opcode(op) if (0x60..=0x7f).contains(&op) => {
            let push_size = (op - 0x60 + 1) as usize;
            let mut value = U256::zero();
            for i in 0..push_size {
                if machine.pc + i < args.code.len() {
                    let byte = args.code[machine.pc + i];
                    value = (value << 8) | U256::from(byte);
                } else {
                    return Err(ExecutionError::OutOfBounds);
                }
            }
            machine.add_pc(push_size);
            machine.stack.push(value)
        },
        Opcode::POP => {
            pop_stack!(machine.stack);
            Ok(())
        },
        Opcode::ADDRESS => {
            machine.stack.push(h160_to_u256(args.address)).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::BALANCE => {
            let address = machine.stack.pop_address()?;
            let balance = state.get_balance(address);
            machine.stack.push(balance).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::ORIGIN => {
            machine.stack.push(h160_to_u256(args.origin)).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CALLER => {
            machine.stack.push(h160_to_u256(args.caller)).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CALLVALUE => {
            machine.stack.push(args.value).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CALLDATALOAD => {
            let index = pop_stack!(machine.stack);
            let mut load = [0u8; 32];
            for i in 0..32 {
                if let Some(p) = index.checked_add(U256::from(i)) {
                    if p <= U256::from(usize::MAX) {
                        let p = p.as_usize();
                        if p < args.data.len() {
                            load[i] = args.data[p];
                        }
                    }
                }
            }
            machine.stack.push(U256::from(load)).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CALLDATASIZE => {
            let size = U256::from(args.data.len());
            machine.stack.push(size).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CALLDATACOPY => {
            let memory_offset = pop_stack!(machine.stack);
            let data_offset = pop_stack!(machine.stack);
            let len = pop_stack!(machine.stack);

            machine.memory.resize_offset(memory_offset, len).map_err(|_| ExecutionError::MemoryError)?;
            if len == U256::zero() {
                return Ok(());
            }

            machine.memory.copy_large(memory_offset, data_offset, len, &args.data)
        },
        Opcode::CODESIZE => {
            let size = U256::from(args.code.len());
            machine.stack.push(size)
        },
        Opcode::CODECOPY => {
            let memory_offset = pop_stack!(machine.stack);
            let code_offset = pop_stack!(machine.stack);
            let len = pop_stack!(machine.stack);

            machine.memory.resize_offset(memory_offset, len)?;
            if len == U256::zero() {
                return Ok(());
            }

            machine.memory.copy_large(memory_offset, code_offset, len, &args.code)
        },
        Opcode::GASPRICE => {
            machine.stack.push(args.gas_price)
        },
        Opcode::EXTCODESIZE => {
            let address: H160 = machine.stack.pop_address()?;
            let code_size = state.get_code_length(address);
            machine.stack.push(U256::from(code_size))
        },
        Opcode::EXTCODECOPY => {
            let address: H160 = machine.stack.pop_address()?;
            let memory_offset = pop_stack!(machine.stack);
            let code_offset = pop_stack!(machine.stack);
            let len = pop_stack!(machine.stack);

            machine.memory.resize_offset(memory_offset, len)?;
            if len == U256::zero() {
                return Ok(());
            }

            let code = state.get_code(address);
            machine.memory.copy_large(memory_offset, code_offset, len, &code)
        },
        Opcode::RETURNDATASIZE => {
            let return_data_size = U256::from(machine.ret_bytes.len());
            machine.stack.push(return_data_size.into())
        },
        Opcode::RETURNDATACOPY => {
            let memory_offset = pop_stack!(machine.stack);
            let return_data_offset = pop_stack!(machine.stack);
            let len = pop_stack!(machine.stack);

            machine.memory.resize_offset(memory_offset, len).map_err(|_| ExecutionError::MemoryError)?;
            if len == U256::zero() {
                return Ok(());
            }

            if return_data_offset + len > U256::from(machine.ret_bytes.len()) {
                return Err(ExecutionError::OutOfBounds);
            }

            machine.memory.copy_large(memory_offset, return_data_offset, len, &machine.ret_bytes)
        },
        Opcode::EXTCODEHASH => {
            let address: H160 = machine.stack.pop_address()?;
            let code_hash = state.get_code_hash(address);
            machine.stack.push(U256::from_big_endian(&code_hash.0))
        },
        Opcode::BLOCKHASH => {
            pop_stack!(machine.stack);
            machine.stack.push(U256::zero())
        },
        Opcode::COINBASE => {
            machine.stack.push(h160_to_u256(env.block_coinbase))
        },
        Opcode::TIMESTAMP => {
            machine.stack.push(env.block_timestamp.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::NUMBER => {
            machine.stack.push(env.block_number.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::DIFFICULTY => {
            machine.stack.push(env.block_difficulty.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::GASLIMIT => {
            machine.stack.push(env.block_gas_limit.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::CHAINID => {
            machine.stack.push(env.chain_id.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::SELFBALANCE => {
            let balance = state.get_balance(args.address);
            machine.stack.push(balance).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::BASEFEE => {
            machine.stack.push(env.block_base_fee_per_gas.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::MLOAD => {
            let index = pop_stack!(machine.stack);
            let index_usize: usize = index.try_into().map_err(|_| ExecutionError::ConversionError)?;
            machine.memory.resize_offset(index, U256::from(32)).map_err(|_| ExecutionError::MemoryError)?;

            let value = U256::from(&machine.memory.get(index_usize, 32)[..]);
            machine.stack.push(value)
        },
        Opcode::MSTORE => {
            let index = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);

            let mut bytes = [0u8; 32];
            value.to_big_endian(&mut bytes);

            machine.memory.resize_offset(index, U256::from(32)).map_err(|_| ExecutionError::MemoryError)?;

            let index_usize: usize = index.try_into().map_err(|_| ExecutionError::ConversionError)?;
            machine.memory.set(index_usize, &bytes, Some(32))
        },
        Opcode::MSTORE8 => {
            let index = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            let byte_value = (value.low_u32() & 0xFF) as u8;
            machine.memory.resize_offset(index, U256::from(1)).map_err(|_| ExecutionError::MemoryError)?;
            let index_usize: usize = index.try_into().map_err(|_| ExecutionError::ConversionError)?;
            machine.memory.set(index_usize, &[byte_value], Some(1)).map_err(|_| ExecutionError::MemoryError)?;
            Ok(())
        },
        Opcode::SLOAD => {
            let index = pop_stack!(machine.stack);
            let value = state.get_storage(args.address, index);
            machine.stack.push(value).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::SSTORE => {
            let index = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }
            state.set_storage(args.address, index, value);
            Ok(())
        },
        Opcode::PC => {
            let pc = U256::from(machine.pc - 1);
            machine.stack.push(pc.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::MSIZE => {
            let size = machine.memory.effective_len();
            machine.stack.push(size.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        //dup1 - dup16
        Opcode(op) if (0x80..=0x8f).contains(&op) => {
            let dup_size = (op - 0x7f) as usize;
            if machine.stack.len() < dup_size {
                return Err(ExecutionError::StackUnderflow);
            }
            let value = machine.stack.peek(dup_size - 1)?;
            machine.stack.push(value)
        },
        //swap1 - swap16
        Opcode(op) if (0x90..=0x9f).contains(&op) => {
            let n = (op - 0x8f) as usize;
            
            let val1: U256 = machine.stack.peek(0)?;
            let val2: U256 = machine.stack.peek(n)?;
            
            machine.stack.set(0, val2)?;
            machine.stack.set(n, val1)?;
            
            Ok(())
        },
        Opcode::JUMP => {
            let dest = pop_stack!(machine.stack);
            let dest_usize: usize = dest.try_into().map_err(|_| ExecutionError::ConversionError)?;
            if !machine.valids.is_valid(dest_usize) {
                return Err(ExecutionError::InvalidJump);
            }
            machine.set_pc(dest_usize);
            Ok(())
        },
        Opcode::JUMPI => {
            let dest = pop_stack!(machine.stack);
            let condition = pop_stack!(machine.stack);
            if !condition.is_zero() {
                let dest_usize: usize = dest.try_into().map_err(|_| ExecutionError::ConversionError)?;
                if !machine.valids.is_valid(dest_usize) {
                    return Err(ExecutionError::InvalidJump);
                }
                machine.set_pc(dest_usize);
            }
            Ok(())
        },
        Opcode::GAS => {
            let gas_left = runtime.get_gas_left();
            machine.stack.push(gas_left.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::JUMPDEST => {
            // JUMPDEST is a no-op, but it marks a valid jump destination
            Ok(())
        },
        Opcode::TLOAD => {
            let index = pop_stack!(machine.stack);
            let value = state.get_transient_storage(args.address, index);
            machine.stack.push(value.into()).map_err(|_| ExecutionError::StackOverflow)?;
            Ok(())
        },
        Opcode::TSTORE => {
            let index = pop_stack!(machine.stack);
            let value = pop_stack!(machine.stack);
            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }
            state.set_transient_storage(args.address, index, value);
            Ok(())
        },
        Opcode::MCOPY => {
            let dest_offset = pop_stack!(machine.stack);
            let src_offset = pop_stack!(machine.stack);
            let length = pop_stack!(machine.stack);

            machine.memory.resize_offset(std::cmp::max(dest_offset, src_offset), length).map_err(|_| ExecutionError::MemoryError)?;

            if length == U256::zero() {
                return Ok(());
            }

            let dest_offset_usize: usize = dest_offset.try_into().map_err(|_| ExecutionError::ConversionError)?;
            let src_offset_usize: usize = src_offset.try_into().map_err(|_| ExecutionError::ConversionError)?;
            let length_usize: usize = length.try_into().map_err(|_| ExecutionError::ConversionError)?;

            machine.memory.copy(dest_offset_usize, src_offset_usize, length_usize);
            Ok(())
        },
        Opcode::SHA3 => {
            let offset = pop_stack!(machine.stack);
            let length = pop_stack!(machine.stack);

            machine.memory.resize_offset(offset, length).map_err(|_| ExecutionError::MemoryError)?;
            let data = if length == U256::zero() {
                Vec::new()
            } else {
                let offset_usize: usize = offset.try_into().map_err(|_| ExecutionError::ConversionError)?;
                let length_usize: usize = length.try_into().map_err(|_| ExecutionError::ConversionError)?;
                machine.memory.get(offset_usize, length_usize)
            };
            
            let hash = keccak256(&data);
            machine.stack.push(U256::from(hash))
        },
        Opcode::CALL | Opcode::CALLCODE | Opcode::DELEGATECALL | Opcode::STATICCALL => {
            let is_static = opcode == Opcode::STATICCALL;
            let gas_left = runtime.get_gas_left();
            let gas = pop_stack!(machine.stack);
            let evm_dest_addr: H160 = machine.stack.pop_address()?;
            let need_stipend = opcode == Opcode::CALL || opcode == Opcode::CALLCODE;
            let msg_value = match opcode {
                Opcode::CALL | Opcode::CALLCODE => pop_stack!(machine.stack),
                Opcode::DELEGATECALL => args.value,
                _ => U256::zero()
            };
            let (call_gas_limit, gas_stipend) = max_call_gas(U256::from(gas_left), gas, msg_value, need_stipend);
            if gas_stipend > 0 {
                runtime.add_gas_left(gas_stipend);
            };
            let m_pos = pop_stack!(machine.stack);
            let m_len = pop_stack!(machine.stack);
            let ret_pos = pop_stack!(machine.stack);
            let ret_len = pop_stack!(machine.stack);

            let m_pos_usize: usize = m_pos.try_into().map_err(|_| ExecutionError::ConversionError)?;
            let m_len_usize: usize = m_len.try_into().map_err(|_| ExecutionError::ConversionError)?;

            let params = machine.memory.get(m_pos_usize, m_len_usize);
            let code_address = evm_dest_addr;
            let (call_from, call_to) = match opcode {
                Opcode::CALL | Opcode::STATICCALL => (args.address, evm_dest_addr),
                Opcode::CALLCODE => (args.address, args.address),
                _ => (args.caller, args.address),
            };
            let is_precompile = is_precompile_address(evm_dest_addr);
            let transfer_eth = (opcode == Opcode::CALL || opcode == Opcode::CALLCODE) && msg_value != U256::zero();
            machine.set_ret_bytes(vec![]);
            if runtime.get_is_static() && transfer_eth && call_from != call_to {
                return Err(ExecutionError::StaticStateChange);
            }
            let output;

            if depth >= limit::DEPTH_SIZE {
                return Err(ExecutionError::DepthOverflow);
            } 

            let dest_code = state.get_code(code_address);
            let new_args = RunArgs {
                origin: args.origin,
                caller: call_from,
                address: call_to,
                value: msg_value,
                code: dest_code,
                data: params,
                gas_price: args.gas_price,
                is_create: false
            };
            

            if is_precompile {
                let (call_result, bytes) = precompile(&new_args, runtime, state, call_gas_limit, transfer_eth, code_address);
                output = if call_result == CallResult::Success {
                    machine.set_ret_bytes(bytes.clone());
                    machine.memory.copy_large(ret_pos, U256::zero(), ret_len, &bytes)?;
                    U256::one()
                } else {
                    U256::zero()
                }

            } else if state.get_code_length(call_to) > 0 {
                handle_new_checkpoint(state, runtime, call_gas_limit, is_static);

                let (result, bytes) = run(state, runtime, &new_args, env, transfer_eth, depth + 1);
                if result == CallResult::Exit {
                    return Err(ExecutionError::Exit);
                }
                
                if result == CallResult::Success || result == CallResult::Revert {
                    machine.set_ret_bytes(bytes.clone());
                    machine.memory.copy_large(ret_pos, U256::zero(), ret_len, &bytes.clone())?;
                }

                output = if result == CallResult::Success {
                    U256::one()
                } else {
                    U256::zero()
                };
            } else {
                output = if transfer_eth && !state.transfer(call_from, call_to, msg_value) {
                    U256::zero()
                } else {
                    U256::one()
                };
            }
            machine.stack.push(output)
        }
        Opcode::CREATE => {
            let value = pop_stack!(machine.stack);
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);

            let init_code = machine.memory.get(offset.as_usize(), size.as_usize());
            let new_address = get_contract_address(args.address, state.get_nonce(args.address));

            let new_args = RunArgs {
                origin: args.origin,
                caller: args.address,
                address: new_address,
                value: value,
                code: init_code,
                data: Vec::new(),
                gas_price: args.gas_price,
                is_create: true,
            };

            create_internal(&new_args, machine, state, runtime, env, depth)?;

            Ok(())
        }
        Opcode::CREATE2 => {
            let value = pop_stack!(machine.stack);
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            let salt = pop_stack!(machine.stack);

            let init_code = machine.memory.get(offset.as_usize(), size.as_usize());
            let new_address = get_create2_address(args.address, u256_to_bytes(salt), init_code.clone());

            let new_args = RunArgs {
                origin: args.origin,
                caller: args.address,
                address: new_address,
                value: value,
                code: init_code.clone(),
                data: Vec::new(),
                gas_price: args.gas_price,
                is_create: true,
            };

            create_internal(&new_args, machine, state, runtime, env, depth)?;

            Ok(())
        }
        Opcode::REVERT => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            
            handle_normal_revert(state, runtime);

            let revert_data = machine.memory.get(offset.as_usize(), size.as_usize());
            machine.set_ret_calue(revert_data);

            Err(ExecutionError::Revert)
        }
        Opcode::LOG0 => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);

            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }

            let _data = machine.memory.get(offset.as_usize(), size.as_usize());
            //state.add_log(args.address, vec![], data);
            Ok(())
        }
        Opcode::LOG1 => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            let _topic1 = pop_stack!(machine.stack);

            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }

            let _data = machine.memory.get(offset.as_usize(), size.as_usize());
            // state.add_log(args.address, vec![topic1], data);
            Ok(())
        }
        Opcode::LOG2 => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            let _topic1 = pop_stack!(machine.stack);
            let _topic2 = pop_stack!(machine.stack);

            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }

            let _data = machine.memory.get(offset.as_usize(), size.as_usize());
            // state.add_log(args.address, vec![topic1, topic2], data);
            Ok(())
        }
        Opcode::LOG3 => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            let _topic1 = pop_stack!(machine.stack);
            let _topic2 = pop_stack!(machine.stack);
            let _topic3 = pop_stack!(machine.stack);

            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }

            let _data = machine.memory.get(offset.as_usize(), size.as_usize());
            // state.add_log(args.address, vec![topic1, topic2, topic3], data);
            Ok(())
        }
        Opcode::LOG4 => {
            let offset = pop_stack!(machine.stack);
            let size = pop_stack!(machine.stack);
            let _topic1 = pop_stack!(machine.stack);
            let _topic2 = pop_stack!(machine.stack);
            let _topic3 = pop_stack!(machine.stack);
            let _topic4 = pop_stack!(machine.stack);

            if runtime.get_is_static() {
                return Err(ExecutionError::StaticStateChange);
            }

            let _data = machine.memory.get(offset.as_usize(), size.as_usize());
            // state.add_log(args.address, vec![topic1, topic2, topic3, topic4], data);
            Ok(())
        },
        Opcode::INVALID => {
            Err(ExecutionError::InvalidOpcode)
        }


        _ => Err(ExecutionError::Exit),
    }
}

fn create_internal(args: &RunArgs, machine: &mut Machine, state: &mut State, runtime: &mut Runtime, env: &Environment, depth: usize) -> Result<(), ExecutionError> {
    machine.set_ret_bytes(vec![]);
    if args.data.len() > limit::INIT_CODE_SIZE {
        return Err(ExecutionError::InitCodeSizeExceed)
    }

    if runtime.get_is_static() {
        return Err(ExecutionError::StaticStateChange)
    }

    if depth >= limit::DEPTH_SIZE {
        return Err(ExecutionError::DepthOverflow);
    }

    if state.get_balance(args.caller) < args.value {
        return Err(ExecutionError::InsufficientBalance);
    }

    if state.get_nonce(args.caller) > U256::from(u64::MAX) {
        return Err(ExecutionError::InvalidNonce);
    }

    state.inc_nonce(args.caller);
    state.add_warm_address(args.address);

    let gas_left = runtime.get_gas_left();
    let (call_gas_limit, _) = max_call_gas(U256::from(gas_left), U256::from(gas_left), args.value, false);

    if state.is_contract_or_created_account(args.address) {
        runtime.add_gas_usage(call_gas_limit);
        return Err(ExecutionError::InvalidCreated);
    }

    handle_new_checkpoint(state, runtime, call_gas_limit, false);
    let (create_res, bytes) = run(state, runtime, args, env, true, depth + 1);
    
    match create_res {
        CallResult::Success => {
            state.set_code(args.address, bytes);
            machine.stack.push(h160_to_u256(args.address))
        }
        CallResult::Revert => {
            machine.set_ret_bytes(bytes);
            machine.stack.push(U256::zero())
        }
        CallResult::Exit => {
            return Err(ExecutionError::Exit);
        }
        _ => {
            machine.stack.push(U256::zero())
        }
    }
}

fn handle_new_checkpoint(state: &mut State, runtime: &mut Runtime, gas_limit: u64, is_static: bool) {
    runtime.new_checkpoint(gas_limit, is_static);
    state.push_substate();
}

fn handle_normal_revert(state: &mut State, runtime: &mut Runtime) {
    state.revert_substate();
    runtime.clear_gas_refund();
    runtime.commit_checkpoint();
}

fn handle_unexpect_revert(state: &mut State, runtime: &mut Runtime) {
    state.revert_substate();
    runtime.revert_checkpoint();
}

fn handle_commit(state: &mut State, runtime: &mut Runtime) {
    state.commit_substate();
    runtime.commit_checkpoint();
}

