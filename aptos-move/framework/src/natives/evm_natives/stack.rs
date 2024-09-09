use primitive_types::{U256, H160};

use crate::natives::evm_natives::types::ExecutionError;

/// EVM stack.
#[derive(Debug)]
pub struct Stack {
	data: Vec<U256>,
	limit: usize,
}

impl Stack {
	/// Create a new stack with given limit.
	#[must_use]
	pub const fn new(limit: usize) -> Self {
		Self {
			data: Vec::new(),
			limit,
		}
	}

	/// Stack limit.
	#[inline]
	#[must_use]
	pub const fn limit(&self) -> usize {
		self.limit
	}

	/// Stack length.
	#[inline]
	#[must_use]
	pub fn len(&self) -> usize {
		self.data.len()
	}

	/// Whether the stack is empty.
	#[inline]
	#[must_use]
	pub fn is_empty(&self) -> bool {
		self.data.is_empty()
	}

	/// Stack data.
	#[inline]
	#[must_use]
	pub const fn data(&self) -> &Vec<U256> {
		&self.data
	}

	/// Clear the stack.
	pub fn clear(&mut self) {
		self.data.clear();
	}

	/// Pop a value from the stack.
	/// If the stack is already empty, returns the `StackUnderflow` error.
	#[inline]
	pub fn pop(&mut self) -> Result<U256, ExecutionError> {
		self.data.pop().ok_or(ExecutionError::StackUnderflow)
	}

	#[inline] 
	pub fn pop_address(&mut self) -> Result<H160, ExecutionError> {
        let value: U256 = self.pop().map_err(|_| ExecutionError::StackUnderflow)?;
		let mut bytes = [0u8; 32];
    	value.to_big_endian(&mut bytes);
        Ok(H160::from_slice(&bytes[12..32]))
    }

	/// Push a new value into the stack.
	/// If it exceeds the stack limit, returns `StackOverflow` error and
	/// leaves the stack unchanged.
	#[inline]
	pub fn push(&mut self, value: U256) -> Result<(), ExecutionError> {
		if self.data.len() + 1 > self.limit {
			return Err(ExecutionError::StackOverflow);
		}
		self.data.push(value);
		Ok(())
	}

	/// Check whether it's possible to pop and push enough items in the stack.
	pub fn check_pop_push(&self, pop: usize, push: usize) -> Result<(), ExecutionError> {
		if self.data.len() < pop {
			return Err(ExecutionError::StackUnderflow);
		}
		if self.data.len() - pop + push + 1 > self.limit {
			return Err(ExecutionError::StackOverflow);
		}
		Ok(())
	}

	/// Peek a value at given index for the stack, where the top of
	/// the stack is at index `0`. If the index is too large,
	/// `StackError::Underflow` is returned.
	#[inline]
	pub fn peek(&self, no_from_top: usize) -> Result<U256, ExecutionError> {
		if self.data.len() > no_from_top {
			Ok(self.data[self.data.len() - no_from_top - 1])
		} else {
			Err(ExecutionError::StackUnderflow)
		}
	}

	/// Set a value at given index for the stack, where the top of the
	/// stack is at index `0`. If the index is too large,
	/// `StackError::Underflow` is returned.
	#[inline]
	pub fn set(&mut self, no_from_top: usize, val: U256) -> Result<(), ExecutionError> {
		if self.data.len() > no_from_top {
			let len = self.data.len();
			self.data[len - no_from_top - 1] = val;
			Ok(())
		} else {
			Err(ExecutionError::StackUnderflow)
		}
	}
}
