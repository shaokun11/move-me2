use primitive_types::{H160, U256};

#[macro_export]
macro_rules! log_debug {
    ($($arg:tt)*) => {
        #[cfg(debug_assertions)]
        {
            println!($($arg)*);
        }
    };
}

pub fn get_word_count(bytes_size: U256) -> U256 {
    let mut word_count = bytes_size / 32;
    if bytes_size % 32 != U256::zero() {
        word_count = word_count.saturating_add(U256::one());
    }
    word_count
}


pub fn u256_bytes_length(value: U256) -> u64 {
    if value.is_zero() {
        return 0;
    }
    
    ((value.bits() + 7) / 8) as u64
}

pub fn h160_to_u256(address: H160) -> U256 {
    U256::from_big_endian(address.as_bytes())
}

pub fn u256_to_bytes(value: U256) -> Vec<u8> {
    let mut bytes = vec![0u8; 32];
    value.to_big_endian(&mut bytes);
    bytes
}

pub fn u256_to_address(value: U256) -> H160 {
    let mut bytes = [0u8; 32];
    value.to_big_endian(&mut bytes);
    H160::from_slice(&bytes[12..32])
}

pub fn bytes_to_h160(bytes: &Vec<u8>) -> H160 {
	let end_slice = &bytes[bytes.len() - 20..];
    H160::from_slice(end_slice)
}
