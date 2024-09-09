use crate::natives::evm_natives::{
    memory::Memory,
    stack::Stack,
    types::Valids
};


pub struct Machine {
    pub highest_memory_cost: u64,
    pub highest_memory_word_size: u64,
    pub memory: Memory,
    pub pc: usize,
    pub stack: Stack,
    pub ret_bytes: Vec<u8>,
    pub ret_value: Vec<u8>,
    pub valids: Valids
}

impl Machine {
    pub fn new(stack_size_limit: usize, code: &Vec<u8>) -> Self {
        Self {
            highest_memory_cost: 0,
            highest_memory_word_size: 0,
            pc: 0,
            memory: Memory::new(u32::MAX as usize),
            stack: Stack::new(stack_size_limit),
            ret_bytes: vec![],
            ret_value: vec![],
            valids: Valids::new(code)
        }
    }

    pub fn get_memory_cost(&self) -> u64 {
        self.highest_memory_cost
    }

    pub fn set_memory_cost(&mut self, cost: u64) {
        self.highest_memory_cost = cost;
    }

    pub fn get_memory_word_size(&self) -> u64 {
        self.highest_memory_word_size
    }

    pub fn set_memory_word_size(&mut self, size: u64) {
        self.highest_memory_word_size = size;
    }

    pub fn get_ret_bytes(&self) -> &Vec<u8> {
        &self.ret_bytes
    }

    pub fn set_ret_bytes(&mut self, bytes: Vec<u8>) {
        self.ret_bytes = bytes;
    }

    pub fn get_ret_size(&self) -> usize {
        self.ret_bytes.len()
    }

    pub fn get_ret_value(&self) -> Vec<u8> {
        self.ret_value.clone()
    }

    pub fn set_ret_calue(&mut self, bytes: Vec<u8>) {
        self.ret_value = bytes;
    }

    pub fn add_pc(&mut self, len: usize) {
        self.pc += len;
    }

    pub fn set_pc(&mut self, dest: usize) {
        self.pc = dest;
    }

    
}