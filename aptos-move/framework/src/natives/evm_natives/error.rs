pub enum FrameType {
    MainCall,
    SubCall,
    Create
}

#[derive(Debug)]
struct CallFrame {
    machine: Machine,
    args: RunArgs,
    transfer_eth: bool,
    depth: usize,
    frame_type: FrameType
}


#[derive(Debug)]
pub enum ExecutionError {
	Stop,
    StackOverflow,
    DepthOverflow,
    StackUnderflow,
    MemoryError,
    InvalidOpcode,
    ConversionError,
    OutOfBounds,
    InvalidJump,
	InvalidRange,
    StaticStateChange,
    InsufficientBalance,
    InitCodeSizeExceed,
    InvalidNonce,
    InvalidCreated,
    Revert,
	NotSupported,
	OutOfGas,
	Create(CallFrame),
	SubCall(CallFrame),
	Exit
}