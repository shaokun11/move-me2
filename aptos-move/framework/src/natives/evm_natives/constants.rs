pub mod gas_cost {
    pub const DATA_ZERO_COST: u64 = 4;
    pub const DATA_NOT_ZERO_COST: u64 = 16;
    pub const CREATE_SIZE_PER_BYTES: u64 = 2;
    pub const ACCESS_LIST_SLOT: u64 = 1900;
    pub const ACCESS_LIST_ADDRESS: u64 = 2400;
    pub const TX_BASE: u64 = 21000;
    pub const CREATE_BASE: u64 = 32000;
}

pub enum TxType {
    Normal = 1,
    Eip1559 = 2
}

impl From<u8> for TxType {
    fn from(value: u8) -> Self {
        match value {
            2 => TxType::Eip1559,
            _ => TxType::Normal,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CallResult {
    Success,
    Revert,
    OutOfGas,
    Exception,
    Exit
}

#[derive(Debug)]
pub enum TxResult {
    ExceptionNone = 200,
    Exception1559MaxFeeLowerThanBaseFee = 201,
    ExceptionLegacyGasPriceLowerThanBaseFee = 202,
    ExceptionGasLimitExceedBlockLimit = 203,
    ExceptionCreateContractCodeSizeExceed = 204,
    ExceptionInsufficientBalanceToSendTx = 205,
    ExceptionSenderNotEOA = 206,
    ExceptionInvalidNonce = 207,
    ExceptionOutOfGas = 208,
    ExceptionExecuteRevert = 209,
    ExceptionInsufficientBalanceToWithdraw = 210,
    ExecptionUnexpectError = 211,
    ExecptionExit = 301
}

pub mod limit {
    pub const INIT_CODE_SIZE: usize = 49152;
    pub const DEPLOY_CODE_SIZE: usize = 24576;
    pub const STACK_SIZE: usize = 1024;
    pub const DEPTH_SIZE: usize = 1024;
}