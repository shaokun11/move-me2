// /// Stepping result returned by interpreter.
// pub enum InterpreterResult {
// 	/// The VM has already stopped.
// 	Stopped,
// 	/// The VM has just finished execution in the current step.
// 	Done(vm::Result<GasLeft>),
// 	/// The VM can continue to run.
// 	Continue,
// 	Trap(TrapKind),
// }
use schedule::Schedule;
use action_params::ActionParams;
use std::marker::PhantomData;

pub struct Interpreter<Cost: CostType> {
	mem: Vec<u8>,
	cache: Arc<SharedCache>,
	params: ActionParams,
	reader: CodeReader,
	return_data: ReturnData,
	informant: informant::EvmInformant,
	do_trace: bool,
	done: bool,
	valid_jump_destinations: Option<Arc<BitSet>>,
	gasometer: Option<Gasometer<Cost>>,
	stack: VecStack<U256>,
	resume_output_range: Option<(U256, U256)>,
	resume_result: Option<InstructionResult<Cost>>,
	last_stack_ret_len: usize,
	_type: PhantomData<Cost>,
}

/// Abstraction over raw vector of Bytes. Easier state management of PC.
struct CodeReader {
	position: ProgramCounter,
	code: Arc<Bytes>,
}

impl CodeReader {
	/// Create new code reader - starting at position 0.
	fn new(code: Arc<Bytes>) -> Self {
		CodeReader {
			code,
			position: 0,
		}
	}

// 	/// Get `no_of_bytes` from code and convert to U256. Move PC
// 	fn read(&mut self, no_of_bytes: usize) -> U256 {
// 		let pos = self.position;
// 		self.position += no_of_bytes;
// 		let max = cmp::min(pos + no_of_bytes, self.code.len());
// 		U256::from(&self.code[pos..max])
// 	}

// 	fn len(&self) -> usize {
// 		self.code.len()
// 	}
// }


impl Interpreter {
    pub fn create(mut params: ActionParams, schedule: &Schedule, depth: usize) -> Box<dyn Exec> {
        let reader = CodeReader::new(params.code.take().expect("VM always called with code; qed"));
		let gasometer = Cost::from_u256(params.gas).ok().map(|gas| Gasometer::<Cost>::new(gas));
		let stack = VecStack::with_capacity(schedule.stack_limit, U256::zero());
		let valid_jump_destinations = None;

		Interpreter {
			cache, params, reader, informant,
			valid_jump_destinations, gasometer, stack,
			done: false,
			// Overridden in `step_inner` based on
			// the result of `ext.trace_next_instruction`.
			do_trace: true,
			mem: Vec::new(),
			return_data: ReturnData::empty(),
			last_stack_ret_len: 0,
			resume_output_range: None,
			resume_result: None,
			_type: PhantomData,
		}
    }
}


// fn exec(mut self: Box<Self>, ext: &mut dyn vm::Ext) -> vm::ExecTrapResult<GasLeft> {
//     loop {
//         let result = self.step(ext);
//         match result {
//             InterpreterResult::Continue => {},
//             InterpreterResult::Done(value) => return Ok(value),
//             InterpreterResult::Trap(trap) => match trap {
//                 TrapKind::Call(params) => {
//                     return Err(TrapError::Call(params, self));
//                 },
//                 TrapKind::Create(params, address) => {
//                     return Err(TrapError::Create(params, address, self));
//                 },
//             },
//             InterpreterResult::Stopped => panic!("Attempted to execute an already stopped VM.")
//         }
//     }
// }