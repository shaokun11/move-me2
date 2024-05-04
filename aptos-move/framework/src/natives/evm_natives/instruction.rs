macro_rules! enum_with_from_u8 {
	(
		$( #[$enum_attr:meta] )*
		pub enum $name:ident {
			$( $( #[$variant_attr:meta] )* $variant:ident = $discriminator:expr ),+,
		}
	) => {
		$( #[$enum_attr] )*
		pub enum $name {
			$( $( #[$variant_attr] )* $variant = $discriminator ),+,
		}

		impl $name {
			#[doc = "Convert from u8 to the given enum"]
			pub fn from_u8(value: u8) -> Option<Self> {
				match value {
					$( $discriminator => Some($variant) ),+,
					_ => None,
				}
			}
		}
	};
}

enum_with_from_u8! {
	#[doc = "Virtual machine bytecode instruction."]
	#[repr(u8)]
	#[derive(Eq, PartialEq, Ord, PartialOrd, Clone, Copy, Debug, Hash)]
	pub enum Instruction {
		#[doc = "halts execution"]
		STOP = 0x00,
		#[doc = "addition operation"]
		ADD = 0x01,
		#[doc = "mulitplication operation"]
		MUL = 0x02,
		#[doc = "subtraction operation"]
		SUB = 0x03,
		#[doc = "integer division operation"]
		DIV = 0x04,
		#[doc = "signed integer division operation"]
		SDIV = 0x05,
		#[doc = "modulo remainder operation"]
		MOD = 0x06,
		#[doc = "signed modulo remainder operation"]
		SMOD = 0x07,
		#[doc = "unsigned modular addition"]
		ADDMOD = 0x08,
		#[doc = "unsigned modular multiplication"]
		MULMOD = 0x09,
		#[doc = "exponential operation"]
		EXP = 0x0a,
		#[doc = "extend length of signed integer"]
		SIGNEXTEND = 0x0b,

		#[doc = "less-than comparision"]
		LT = 0x10,
		#[doc = "greater-than comparision"]
		GT = 0x11,
		#[doc = "signed less-than comparision"]
		SLT = 0x12,
		#[doc = "signed greater-than comparision"]
		SGT = 0x13,
		#[doc = "equality comparision"]
		EQ = 0x14,
		#[doc = "simple not operator"]
		ISZERO = 0x15,
		#[doc = "bitwise AND operation"]
		AND = 0x16,
		#[doc = "bitwise OR operation"]
		OR = 0x17,
		#[doc = "bitwise XOR operation"]
		XOR = 0x18,
		#[doc = "bitwise NOT opertation"]
		NOT = 0x19,
		#[doc = "retrieve single byte from word"]
		BYTE = 0x1a,
		#[doc = "shift left operation"]
		SHL = 0x1b,
		#[doc = "logical shift right operation"]
		SHR = 0x1c,
		#[doc = "arithmetic shift right operation"]
		SAR = 0x1d,

		#[doc = "compute SHA3-256 hash"]
		SHA3 = 0x20,

		#[doc = "get address of currently executing account"]
		ADDRESS = 0x30,
		#[doc = "get balance of the given account"]
		BALANCE = 0x31,
		#[doc = "get execution origination address"]
		ORIGIN = 0x32,
		#[doc = "get caller address"]
		CALLER = 0x33,
		#[doc = "get deposited value by the instruction/transaction responsible for this execution"]
		CALLVALUE = 0x34,
		#[doc = "get input data of current environment"]
		CALLDATALOAD = 0x35,
		#[doc = "get size of input data in current environment"]
		CALLDATASIZE = 0x36,
		#[doc = "copy input data in current environment to memory"]
		CALLDATACOPY = 0x37,
		#[doc = "get size of code running in current environment"]
		CODESIZE = 0x38,
		#[doc = "copy code running in current environment to memory"]
		CODECOPY = 0x39,
		#[doc = "get price of gas in current environment"]
		GASPRICE = 0x3a,
		#[doc = "get external code size (from another contract)"]
		EXTCODESIZE = 0x3b,
		#[doc = "copy external code (from another contract)"]
		EXTCODECOPY = 0x3c,
		#[doc = "get the size of the return data buffer for the last call"]
		RETURNDATASIZE = 0x3d,
		#[doc = "copy return data buffer to memory"]
		RETURNDATACOPY = 0x3e,
		#[doc = "return the keccak256 hash of contract code"]
		EXTCODEHASH = 0x3f,

		#[doc = "get hash of most recent complete block"]
		BLOCKHASH = 0x40,
		#[doc = "get the block's coinbase address"]
		COINBASE = 0x41,
		#[doc = "get the block's timestamp"]
		TIMESTAMP = 0x42,
		#[doc = "get the block's number"]
		NUMBER = 0x43,
		#[doc = "get the block's difficulty"]
		DIFFICULTY = 0x44,
		#[doc = "get the block's gas limit"]
		GASLIMIT = 0x45,
		#[doc = "get chain ID"]
		CHAINID = 0x46,
		#[doc = "get balance of own account"]
		SELFBALANCE = 0x47,

		#[doc = "remove item from stack"]
		POP = 0x50,
		#[doc = "load word from memory"]
		MLOAD = 0x51,
		#[doc = "save word to memory"]
		MSTORE = 0x52,
		#[doc = "save byte to memory"]
		MSTORE8 = 0x53,
		#[doc = "load word from storage"]
		SLOAD = 0x54,
		#[doc = "save word to storage"]
		SSTORE = 0x55,
		#[doc = "alter the program counter"]
		JUMP = 0x56,
		#[doc = "conditionally alter the program counter"]
		JUMPI = 0x57,
		#[doc = "get the program counter"]
		PC = 0x58,
		#[doc = "get the size of active memory"]
		MSIZE = 0x59,
		#[doc = "get the amount of available gas"]
		GAS = 0x5a,
		#[doc = "set a potential jump destination"]
		JUMPDEST = 0x5b,

		#[doc = "place 1 byte item on stack"]
		PUSH1 = 0x60,
		#[doc = "place 2 byte item on stack"]
		PUSH2 = 0x61,
		#[doc = "place 3 byte item on stack"]
		PUSH3 = 0x62,
		#[doc = "place 4 byte item on stack"]
		PUSH4 = 0x63,
		#[doc = "place 5 byte item on stack"]
		PUSH5 = 0x64,
		#[doc = "place 6 byte item on stack"]
		PUSH6 = 0x65,
		#[doc = "place 7 byte item on stack"]
		PUSH7 = 0x66,
		#[doc = "place 8 byte item on stack"]
		PUSH8 = 0x67,
		#[doc = "place 9 byte item on stack"]
		PUSH9 = 0x68,
		#[doc = "place 10 byte item on stack"]
		PUSH10 = 0x69,
		#[doc = "place 11 byte item on stack"]
		PUSH11 = 0x6a,
		#[doc = "place 12 byte item on stack"]
		PUSH12 = 0x6b,
		#[doc = "place 13 byte item on stack"]
		PUSH13 = 0x6c,
		#[doc = "place 14 byte item on stack"]
		PUSH14 = 0x6d,
		#[doc = "place 15 byte item on stack"]
		PUSH15 = 0x6e,
		#[doc = "place 16 byte item on stack"]
		PUSH16 = 0x6f,
		#[doc = "place 17 byte item on stack"]
		PUSH17 = 0x70,
		#[doc = "place 18 byte item on stack"]
		PUSH18 = 0x71,
		#[doc = "place 19 byte item on stack"]
		PUSH19 = 0x72,
		#[doc = "place 20 byte item on stack"]
		PUSH20 = 0x73,
		#[doc = "place 21 byte item on stack"]
		PUSH21 = 0x74,
		#[doc = "place 22 byte item on stack"]
		PUSH22 = 0x75,
		#[doc = "place 23 byte item on stack"]
		PUSH23 = 0x76,
		#[doc = "place 24 byte item on stack"]
		PUSH24 = 0x77,
		#[doc = "place 25 byte item on stack"]
		PUSH25 = 0x78,
		#[doc = "place 26 byte item on stack"]
		PUSH26 = 0x79,
		#[doc = "place 27 byte item on stack"]
		PUSH27 = 0x7a,
		#[doc = "place 28 byte item on stack"]
		PUSH28 = 0x7b,
		#[doc = "place 29 byte item on stack"]
		PUSH29 = 0x7c,
		#[doc = "place 30 byte item on stack"]
		PUSH30 = 0x7d,
		#[doc = "place 31 byte item on stack"]
		PUSH31 = 0x7e,
		#[doc = "place 32 byte item on stack"]
		PUSH32 = 0x7f,

		#[doc = "copies the highest item in the stack to the top of the stack"]
		DUP1 = 0x80,
		#[doc = "copies the second highest item in the stack to the top of the stack"]
		DUP2 = 0x81,
		#[doc = "copies the third highest item in the stack to the top of the stack"]
		DUP3 = 0x82,
		#[doc = "copies the 4th highest item in the stack to the top of the stack"]
		DUP4 = 0x83,
		#[doc = "copies the 5th highest item in the stack to the top of the stack"]
		DUP5 = 0x84,
		#[doc = "copies the 6th highest item in the stack to the top of the stack"]
		DUP6 = 0x85,
		#[doc = "copies the 7th highest item in the stack to the top of the stack"]
		DUP7 = 0x86,
		#[doc = "copies the 8th highest item in the stack to the top of the stack"]
		DUP8 = 0x87,
		#[doc = "copies the 9th highest item in the stack to the top of the stack"]
		DUP9 = 0x88,
		#[doc = "copies the 10th highest item in the stack to the top of the stack"]
		DUP10 = 0x89,
		#[doc = "copies the 11th highest item in the stack to the top of the stack"]
		DUP11 = 0x8a,
		#[doc = "copies the 12th highest item in the stack to the top of the stack"]
		DUP12 = 0x8b,
		#[doc = "copies the 13th highest item in the stack to the top of the stack"]
		DUP13 = 0x8c,
		#[doc = "copies the 14th highest item in the stack to the top of the stack"]
		DUP14 = 0x8d,
		#[doc = "copies the 15th highest item in the stack to the top of the stack"]
		DUP15 = 0x8e,
		#[doc = "copies the 16th highest item in the stack to the top of the stack"]
		DUP16 = 0x8f,

		#[doc = "swaps the highest and second highest value on the stack"]
		SWAP1 = 0x90,
		#[doc = "swaps the highest and third highest value on the stack"]
		SWAP2 = 0x91,
		#[doc = "swaps the highest and 4th highest value on the stack"]
		SWAP3 = 0x92,
		#[doc = "swaps the highest and 5th highest value on the stack"]
		SWAP4 = 0x93,
		#[doc = "swaps the highest and 6th highest value on the stack"]
		SWAP5 = 0x94,
		#[doc = "swaps the highest and 7th highest value on the stack"]
		SWAP6 = 0x95,
		#[doc = "swaps the highest and 8th highest value on the stack"]
		SWAP7 = 0x96,
		#[doc = "swaps the highest and 9th highest value on the stack"]
		SWAP8 = 0x97,
		#[doc = "swaps the highest and 10th highest value on the stack"]
		SWAP9 = 0x98,
		#[doc = "swaps the highest and 11th highest value on the stack"]
		SWAP10 = 0x99,
		#[doc = "swaps the highest and 12th highest value on the stack"]
		SWAP11 = 0x9a,
		#[doc = "swaps the highest and 13th highest value on the stack"]
		SWAP12 = 0x9b,
		#[doc = "swaps the highest and 14th highest value on the stack"]
		SWAP13 = 0x9c,
		#[doc = "swaps the highest and 15th highest value on the stack"]
		SWAP14 = 0x9d,
		#[doc = "swaps the highest and 16th highest value on the stack"]
		SWAP15 = 0x9e,
		#[doc = "swaps the highest and 17th highest value on the stack"]
		SWAP16 = 0x9f,

		#[doc = "Makes a log entry, no topics."]
		LOG0 = 0xa0,
		#[doc = "Makes a log entry, 1 topic."]
		LOG1 = 0xa1,
		#[doc = "Makes a log entry, 2 topics."]
		LOG2 = 0xa2,
		#[doc = "Makes a log entry, 3 topics."]
		LOG3 = 0xa3,
		#[doc = "Makes a log entry, 4 topics."]
		LOG4 = 0xa4,

		#[doc = "create a new account with associated code"]
		CREATE = 0xf0,
		#[doc = "message-call into an account"]
		CALL = 0xf1,
		#[doc = "message-call with another account's code only"]
		CALLCODE = 0xf2,
		#[doc = "halt execution returning output data"]
		RETURN = 0xf3,
		#[doc = "like CALLCODE but keeps caller's value and sender"]
		DELEGATECALL = 0xf4,
		#[doc = "create a new account and set creation address to sha3(sender + sha3(init code)) % 2**160"]
		CREATE2 = 0xf5,
		#[doc = "stop execution and revert state changes. Return output data."]
		REVERT = 0xfd,
		#[doc = "like CALL but it does not take value, nor modify the state"]
		STATICCALL = 0xfa,
		#[doc = "halt execution and register account for later deletion"]
		SUICIDE = 0xff,
	}
}

impl Instruction {
	/// Returns true if given instruction is `PUSHN` instruction.
	pub fn is_push(&self) -> bool {
		*self >= PUSH1 && *self <= PUSH32
	}

	/// Returns number of bytes to read for `PUSHN` instruction
	/// PUSH1 -> 1
	pub fn push_bytes(&self) -> Option<usize> {
		if self.is_push() {
			Some(((*self as u8) - (PUSH1 as u8) + 1) as usize)
		} else {
			None
		}
	}

	/// Returns stack position of item to duplicate
	/// DUP1 -> 0
	pub fn dup_position(&self) -> Option<usize> {
		if *self >= DUP1 && *self <= DUP16 {
			Some(((*self as u8) - (DUP1 as u8)) as usize)
		} else {
			None
		}
	}

	/// Returns stack position of item to SWAP top with
	/// SWAP1 -> 1
	pub fn swap_position(&self) -> Option<usize> {
		if *self >= SWAP1 && *self <= SWAP16 {
			Some(((*self as u8) - (SWAP1 as u8) + 1) as usize)
		} else {
			None
		}
	}

	/// Returns number of topics to take from stack
	/// LOG0 -> 0
	pub fn log_topics(&self) -> Option<usize> {
		if *self >= LOG0 && *self <= LOG4 {
			Some(((*self as u8) - (LOG0 as u8)) as usize)
		} else {
			None
		}
	}

	/// Returns the instruction info.
	pub fn info(&self) -> &'static InstructionInfo {
		INSTRUCTIONS[*self as usize].as_ref().expect("A instruction is defined in Instruction enum, but it is not found in InstructionInfo struct; this indicates a logic failure in the code.")
	}
}