
use std::u64;

use crate::{log_debug, natives::evm_natives::{
    arithmetic, constants::{gas_cost, limit, CallResult, TxResult, TxType}, gas::{calc_exec_gas, max_call_gas}, machine::Machine, precompile::{is_precompile_address, run_precompile}, runtime::Runtime, state::State, types::{Environment, ExecutionError, FrameType, Opcode, RunArgs, TransactArgs}, utils::{h160_to_u256, u256_to_bytes}
}};

use primitive_types::{H160, U256};
use ethers::utils::{get_contract_address, get_create2_address, keccak256};

struct CallFrame {
    machine: Machine,
    args: RunArgs,
    frame_type: FrameType,
}

impl CallFrame {
    pub fn new(stack_size_limit: usize, args: RunArgs, frame_type: FrameType) -> Self {
        Self {
            machine: Machine::new(stack_size_limit, &args.code),
            args,
            frame_type
        }
    }
}

fn calc_base_cost(data: &[u8], access_list_address_len: u64, access_list_slot_len: u64) -> u64 {
    let zero_data_len = (data.iter().filter(|v| **v == 0).count()) as u64;
	let non_zero_data_len = (data.len() as u64) - zero_data_len;
    let data_cost = zero_data_len * gas_cost::DATA_ZERO_COST + non_zero_data_len * gas_cost::DATA_NOT_ZERO_COST;
    let access_list_cost = access_list_address_len * gas_cost::ACCESS_LIST_ADDRESS +
                            access_list_slot_len * gas_cost::ACCESS_LIST_SLOT;
                            
    log_debug!("zero data {} {} {} {} {} {}", zero_data_len, non_zero_data_len, data_cost, access_list_address_len, access_list_slot_len, access_list_cost);
 
    data_cost + access_list_cost + gas_cost::TX_BASE
}


pub fn new_tx(state: &mut State, run_args: RunArgs, tx_args: &TransactArgs, env: &Environment, tx_type: TxType, access_list_address_len: u64, access_list_slot_len: u64) -> TxResult {
    
    let mut runtime = Runtime::new();
    runtime.new_checkpoint(tx_args.gas_limit.as_u64(), false);

    state.add_warm_address(run_args.caller);
    state.add_warm_address(env.block_coinbase);
    
    let (mut base_cost, data_size) = if run_args.is_create {
        (calc_base_cost(&run_args.code, access_list_address_len, access_list_slot_len), run_args.code.len())
    } else {
        (calc_base_cost(&run_args.data, access_list_address_len, access_list_slot_len), run_args.data.len())
    };

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

    if state.get_nonce(run_args.caller) >= U256::from(u64::MAX) {
        return TxResult::ExceptionInvalidNonce;
    }

    state.sub_balance(run_args.caller, tx_args.gas_limit.saturating_mul(tx_args.gas_price));
    runtime.add_gas_usage(base_cost);
    let created_address = H160::zero();
    let mut exception = TxResult::ExceptionNone;
    let mut message = Vec::new();
    let ret_value;
    let call_frames = &mut Vec::new();
    call_frames.push(CallFrame::new(limit::STACK_SIZE, run_args.clone(), FrameType::MainCall));

    if run_args.is_create {
        if state.is_contract_or_created_account(run_args.address) {
            runtime.add_gas_usage(tx_args.gas_limit.as_u64());
        } else {
            let gas_left = runtime.get_gas_left();
            handle_new_call(state, &mut runtime, &run_args, gas_left, false);
            // result = run(state, &mut runtime, run_args, env, true, 0);
            match execute(state, &mut runtime, env, call_frames) {
                Ok(value) => {
                    ret_value = value;
                }
                Err(ExecutionError::OutOfGas) => {
                    exception = TxResult::ExceptionOutOfGas;
                }
                Err(ExecutionError::Revert(ret_value)) => {
                    exception = TxResult::ExceptionExecuteRevert;
                    message = ret_value;
                }
                Err(ExecutionError::Exit) => {
                    exception = TxResult::ExecptionExit;
                }
                Err(_) => {
                    exception = TxResult::ExecptionUnexpectError;
                }
            }
        }
    } else {
        let call_gas_limit = tx_args.gas_limit.as_u64().saturating_sub(base_cost);
        if is_precompile_address(run_args.address) {
            let result = precompile(&run_args, &mut runtime, state, call_gas_limit, true, run_args.address);
            ret_value = result.1;
        } else {
            handle_new_call(state, &mut runtime, &run_args, call_gas_limit, false);
            match execute(state, &mut runtime, env, call_frames) {
                Ok(value) => {
                    ret_value = value;
                }
                Err(ExecutionError::OutOfGas) => {
                    exception = TxResult::ExceptionOutOfGas;
                }
                Err(ExecutionError::Revert(value)) => {
                    exception = TxResult::ExceptionExecuteRevert;
                    message = value;
                }
                Err(ExecutionError::Exit) => {
                    exception = TxResult::ExecptionExit;
                }
                Err(_) => {
                    exception = TxResult::ExecptionUnexpectError;
                }
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

    log_debug!("Execution cost: {:?} {:?} {:?} {:?}", base_cost, gas_usage - base_cost, gas_usage, gas_refund);
    log_debug!("Created address: {:?}", created_address);
    log_debug!("Ret value {:?}", message);
    // log_debug!("State {:?}", state);
    exception
}

fn precompile(run_args: &RunArgs, runtime: &mut Runtime, state: &mut State, gas_limit: u64, transfer_eth: bool, code_address: H160) -> (CallResult, Vec<u8>) {
    if transfer_eth {
        if state.get_balance(run_args.caller) < run_args.value {
            return (CallResult::Exception, vec![])
        }
    }


    let (mut call_result, mut gas, ret_val) = run_precompile(code_address, run_args.data.clone(), gas_limit);
    if call_result != CallResult::Success {
        gas = gas_limit;
    } else if gas > gas_limit  {
        gas = gas_limit;
        call_result = CallResult::OutOfGas;
    }
    
    log_debug!("precompile result {:?} {:?} {:?}", call_result, gas, ret_val);
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

fn execute(state: &mut State, runtime: &mut Runtime, env: &Environment, call_frames: &mut Vec<CallFrame>) -> Result<Vec<u8>, ExecutionError> {
    while !call_frames.is_empty() {
       loop {
            let result = {
                let frame = call_frames.last_mut().unwrap();
                let machine = &mut frame.machine;
                let args = &frame.args;
                if machine.pc >= args.code.len() {
                    Err(ExecutionError::Stop(machine.get_ret_value()))
                } else {
                    let opcode = Opcode(args.code[machine.pc]);
                    machine.pc += 1;
                    log_debug!("{:?}", machine.stack.data());
                    
                    step(opcode, &frame.args, machine, state, runtime, env)
                }
            };

            match result {
                Err(ExecutionError::Stop(value)) => {
                    let finished_frame = call_frames.pop().unwrap();
                    if let Some(last_frame) = call_frames.last_mut() {
                        let machine = &mut last_frame.machine;
                        match finished_frame.frame_type {
                            FrameType::Create => {
                                match after_created(state, runtime, finished_frame.args.address, value) {
                                    Ok(_) => {
                                        machine.stack.push(h160_to_u256(finished_frame.args.address))?;
                                    }
                                    _ => {
                                        machine.stack.push(U256::zero())?;
                                    }
                                } 
                            }
                            FrameType::SubCall => {
                                machine.stack.push(U256::one())?;
                                if value.len() > 0 {
                                    machine.memory.copy_large(machine.ret_pos, U256::zero(), machine.ret_len, &value)?;
                                }
                                machine.set_ret_bytes(value);
                                handle_commit(state, runtime);
                            }
                            _ => {
                                return Ok(value);
                            }
                        }
                    } else {
                        if finished_frame.args.is_create {
                            return after_created(state, runtime, finished_frame.args.address, value)
                        } else {
                            handle_commit(state, runtime);
                            return Ok(value);
                        }
                    }
                    break;
                }
                Err(ExecutionError::Revert(value)) => {
                    let finished_frame = call_frames.pop().unwrap();
                    if let Some(last_frame) = call_frames.last_mut() {
                        let machine = &mut last_frame.machine;
                        match finished_frame.frame_type {
                            FrameType::Create => {
                                machine.set_ret_bytes(value);
                                machine.stack.push(U256::zero())?;
                            }
                            FrameType::SubCall => {
                                machine.stack.push(U256::zero())?;
                                machine.memory.copy_large(machine.ret_pos, U256::zero(), machine.ret_len, &value)?;
                                machine.set_ret_bytes(value);
                            }
                            _ => {
                                return Ok(value);
                            }
                        }   
                    }
                    break;
                }
                Err(ExecutionError::Create(args)) => {
                    log_debug!("new sub create {:?}", args);
                    call_frames.push(CallFrame::new(limit::STACK_SIZE, args, FrameType::Create));
                    break;
                }
                Err(ExecutionError::SubCall(args)) => {
                    log_debug!("new sub call {:?}", args);
                    call_frames.push(CallFrame::new(limit::STACK_SIZE, args, FrameType::SubCall));
                    break;
                }
                Err(ExecutionError::Exit) => {
                    return Err(ExecutionError::Exit);
                }
                Err(err) => {
                    log_debug!("Step result: Unexpected error - {:?}", err);
                    handle_unexpect_revert(state, runtime);
                    let finished_frame = call_frames.pop().unwrap();
                    if let Some(last_frame) = call_frames.last_mut() {
                        match finished_frame.frame_type {
                            FrameType::Create | FrameType::SubCall => {
                                last_frame.machine.set_ret_bytes(finished_frame.machine.get_ret_value());
                                last_frame.machine.stack.push(U256::zero())?;
                            }
                            _ => {
                                return Err(err);
                            }
                        }   
                    }
                    break;
                }
                Ok(_) => {
                    continue;
                }
            }
       }
    }

    Ok(vec![])
}


fn step(opcode: Opcode, args: &RunArgs, machine: &mut Machine, state: &mut State, runtime: &mut Runtime, env: &Environment) -> Result<(), ExecutionError> {
    let (gas_result, gas_cost) = calc_exec_gas(state, opcode, &args.address, machine, runtime);

    log_debug!("opcode {} {} {}", opcode, machine.pc, args.depth);
    log_debug!("gas_cost {}", gas_cost);
    log_debug!("gas_left 0x{:x}", runtime.get_gas_left());
    
    
    let out_of_gas = !runtime.add_gas_usage(gas_cost);
    if out_of_gas || gas_result != CallResult::Success  {
        log_debug!("Out of gas");
        return Err(ExecutionError::OutOfGas);
    } else {
        match opcode {
            Opcode::STOP => Err(ExecutionError::Stop(machine.get_ret_value())),
            Opcode::RETURN => {
                let start = pop_stack!(machine.stack);
                let len = pop_stack!(machine.stack);
                machine.memory.resize_offset(start, len)?;
                machine.memory.resize_to_range(start..(start + len));
                machine.memory.swap_and_clear(&mut machine.ret_value);
                Err(ExecutionError::Stop(machine.get_ret_value()))
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

                let total_offset = return_data_offset.checked_add(len);
                if total_offset.is_none() || total_offset.unwrap() > U256::from(machine.ret_bytes.len()) {
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
                machine.stack.push(env.block_timestamp.into())
            },
            Opcode::NUMBER => {
                machine.stack.push(env.block_number.into())
            },
            Opcode::DIFFICULTY => {
                machine.stack.push(U256::from_big_endian(&env.block_random))
            },
            Opcode::GASLIMIT => {
                machine.stack.push(env.block_gas_limit.into())
            },
            Opcode::CHAINID => {
                machine.stack.push(env.chain_id.into())
            },
            Opcode::SELFBALANCE => {
                let balance = state.get_balance(args.address);
                machine.stack.push(balance)
            },
            Opcode::BASEFEE => {
                machine.stack.push(env.block_base_fee_per_gas.into())
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
    
                let dest_code = state.get_code(code_address);
                let is_contract_call = dest_code.len() > 0;
                let new_args = RunArgs {
                    origin: args.origin,
                    caller: call_from,
                    address: call_to,
                    value: msg_value,
                    code: dest_code,
                    data: params,
                    gas_price: args.gas_price,
                    is_create: false,
                    transfer_eth,
                    depth: args.depth + 1
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
    
                } else if is_contract_call {
                    machine.ret_pos = ret_pos;
                    machine.ret_len = ret_len;
                    if new_args.depth > limit::DEPTH_SIZE || state.get_balance(new_args.caller) < new_args.value {
                        output = U256::zero()
                    } else {
                        handle_new_call(state, runtime, &new_args, call_gas_limit, is_static);
                        return Err(ExecutionError::SubCall(new_args));
                    }
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

                if runtime.get_is_static() {
                    return Err(ExecutionError::StaticStateChange);
                }
    
                let init_code = machine.memory.get(offset.as_usize(), size.as_usize());
                let new_address = get_contract_address(args.address, state.get_nonce(args.address));
    
                let new_args = RunArgs {
                    origin: args.origin,
                    caller: args.address,
                    address: new_address,
                    value: value,
                    code: init_code.clone(),
                    data: Vec::new(),
                    gas_price: args.gas_price,
                    is_create: true,
                    transfer_eth: true,
                    depth: args.depth + 1
                };
    
                create_internal(&new_args, machine, state, runtime)?;
                Ok(())
            }
            Opcode::CREATE2 => {
                let value = pop_stack!(machine.stack);
                let offset = pop_stack!(machine.stack);
                let size = pop_stack!(machine.stack);
                let salt = pop_stack!(machine.stack);

                if runtime.get_is_static() {
                    return Err(ExecutionError::StaticStateChange);
                }
    
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
                    transfer_eth: true,
                    depth: args.depth + 1
                };
    
                create_internal(&new_args, machine, state, runtime)?;
                Ok(())
            }
            Opcode::REVERT => {
                let offset = pop_stack!(machine.stack);
                let size = pop_stack!(machine.stack);
                
                handle_normal_revert(state, runtime);
    
                let revert_data = machine.memory.get(offset.as_usize(), size.as_usize());
                machine.set_ret_value(revert_data.clone());
    
                Err(ExecutionError::Revert(revert_data))
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

    
}

fn create_internal(args: &RunArgs, machine: &mut Machine, state: &mut State, runtime: &mut Runtime) -> Result<(), ExecutionError> {
    machine.set_ret_bytes(vec![]);

    if state.get_balance(args.caller) < args.value || 
        args.code.len() > limit::INIT_CODE_SIZE ||
        args.depth > limit::DEPTH_SIZE || 
        state.get_nonce(args.caller) >= U256::from(u64::MAX) {
        return machine.stack.push(U256::zero());
    }

    state.inc_nonce(args.caller);
    state.add_warm_address(args.address);

    let gas_left = runtime.get_gas_left();
    let (call_gas_limit, _) = max_call_gas(U256::from(gas_left), U256::from(gas_left), args.value, false);

    if state.is_contract_or_created_account(args.address) {
        runtime.add_gas_usage(call_gas_limit);
        return machine.stack.push(U256::zero());
    }

    handle_new_call(state, runtime, args, call_gas_limit, false);
    Err(ExecutionError::Create(args.clone()))
}

fn after_created(state: &mut State, runtime: &mut Runtime, created_address: H160, code: Vec<u8>) -> Result<Vec<u8>, ExecutionError> {
    let deployed_code_size = code.len();
    let out_of_gas = !runtime.add_gas_usage(200 * deployed_code_size as u64);
    if out_of_gas {
        handle_unexpect_revert(state, runtime);
        return Err(ExecutionError::OutOfGas);
    }
    if deployed_code_size > limit::DEPLOY_CODE_SIZE || (deployed_code_size > 0 && code[0] == 0xef){
        handle_unexpect_revert(state, runtime);
        return Err(ExecutionError::InitCodeSizeExceed);
    }
    handle_commit(state, runtime);
    state.set_code(created_address, code.clone());
    Ok(code)
}

fn handle_new_call(state: &mut State, runtime: &mut Runtime, args: &RunArgs, gas_limit: u64, is_static: bool) {
    runtime.new_checkpoint(gas_limit, is_static);
    state.push_substate();

    state.add_warm_address(args.address);

    if args.transfer_eth {
        state.transfer(args.caller, args.address, args.value);
    }

    if args.is_create {
        state.new_account(args.address, vec![], U256::zero(), U256::one());
    }
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

