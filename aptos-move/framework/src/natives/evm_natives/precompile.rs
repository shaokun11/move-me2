use primitive_types::{H160, H256, U256};
use crate::natives::evm_natives::{
    constants::CallResult,
    eip152
};
use k256::ecdsa::{RecoveryId, Signature, VerifyingKey};
use sha3::{Digest, Keccak256};
use sha2::Sha256;
use ripemd::Ripemd160;
use num::{BigUint, Zero, One};
use bn::{pairing_batch, AffineG1, AffineG2, Fq, Fr, Fq2, Group, Gt, G1, G2};

const ECADD_GAS: u64 = 150;
const ECMUL_GAS: u64 = 6000;
const ECPAIRING_BASE_GAS: u64 = 45000;
const ECPAIRING_PER_POINT_GAS: u64 = 34000;
const BLAKE2_F_GAS: u64 = 1;

pub fn is_precompile_address(address: H160) -> bool {
    let num = U256::from(address.as_bytes());
    num >= U256::from(1) && num < U256::from(10)
}

pub fn run_precompile(code_address: H160, calldata: Vec<u8>, gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    match code_address.to_low_u64_be() {
        1 => ecrecover(&calldata),
        2 => sha256(&calldata),
        3 => ripemd160(&calldata),
        4 => identity(&calldata),
        5 => mod_exp(&calldata, gas_limit),
        6 => ecadd(&calldata, gas_limit),
        7 => ecmul(&calldata, gas_limit),
        8 => ecpairing(&calldata, gas_limit),
        9 => blake2f(&calldata, gas_limit),
        _ => (CallResult::Exception, gas_limit, Vec::new()),
    }
}

fn ecrecover(data: &[u8]) -> (CallResult, u64, Vec<u8>) {
    const COST_BASE: u64 = 3000;
    let mut input = [0u8; 128];
    input[..std::cmp::min(data.len(), 128)].copy_from_slice(&data[..std::cmp::min(data.len(), 128)]);

    // Check if the input is valid
    if input[32..63] != [0u8; 31] || ![27, 28].contains(&input[63]) {
        return (CallResult::Success, COST_BASE, vec![0u8; 32]);
    }

    let mut msg = [0u8; 32];
    let mut sig = [0u8; 64];

    // Extract message hash and signature components
    msg[0..32].copy_from_slice(&input[0..32]);
    sig[0..32].copy_from_slice(&input[64..96]); // r
    sig[32..64].copy_from_slice(&input[96..128]); // s

    // Parse the signature
    let sig = match Signature::from_bytes((&sig[..]).into()) {
        Ok(s) => s,
        Err(_) => return (CallResult::Success, COST_BASE, vec![0u8; 32]),
    };

    // Get the recovery ID
    let recid = match RecoveryId::from_byte(input[63] - 27) {
        Some(id) => id,
        None => return (CallResult::Success, COST_BASE, vec![0u8; 32]),
    };

    // Recover the public key
    let pubkey = match VerifyingKey::recover_from_prehash(&msg[..], &sig, recid) {
        Ok(key) => key,
        Err(_) => return (CallResult::Success, COST_BASE, vec![0u8; 32]),
    };

    // Compute the Ethereum address from the public key
    let mut address = H256::from_slice(Keccak256::digest(&pubkey.to_encoded_point(false).as_bytes()[1..]).as_slice());
    address.0[0..12].copy_from_slice(&[0u8; 12]);

    let mut output = [0u8; 32];
    output.copy_from_slice(&address.0);

    (CallResult::Success, COST_BASE, output.to_vec())
}

fn sha256(data: &[u8]) -> (CallResult, u64, Vec<u8>) {
    const COST_BASE: u64 = 60;
    const COST_WORD: u64 = 12;

    // Calculate the number of 32-byte words, rounding up
    let word_size = (data.len() as u64 + 31) / 32;

    // Calculate gas cost
    let gas_cost = match COST_BASE.checked_add(COST_WORD.checked_mul(word_size).unwrap_or(u64::MAX)) {
        Some(cost) => cost,
        None => return (CallResult::OutOfGas, 0, Vec::new()),
    };

    // Compute SHA256 hash
    let hash = <Sha256 as sha2::Digest>::digest(data);

    // Return the result
    (CallResult::Success, gas_cost, hash.to_vec())
}

fn ripemd160(data: &[u8]) -> (CallResult, u64, Vec<u8>) {
    const COST_BASE: u64 = 600;
    const COST_WORD: u64 = 120;

    // Calculate the number of 32-byte words, rounding up
    let word_size = (data.len() as u64 + 31) / 32;

    // Calculate gas cost
    let gas_cost = match COST_BASE.checked_add(COST_WORD.checked_mul(word_size).unwrap_or(u64::MAX)) {
        Some(cost) => cost,
        None => return (CallResult::OutOfGas, 0, Vec::new()),
    };

    // Compute RIPEMD160 hash
    let hash = <Ripemd160 as ripemd::Digest>::digest(data);

    // Prepare the output: 12 zero bytes followed by the 20-byte RIPEMD160 hash
    let mut output = vec![0u8; 32];
    output[12..].copy_from_slice(&hash);

    // Return the result
    (CallResult::Success, gas_cost, output)
}

fn identity(data: &[u8]) -> (CallResult, u64, Vec<u8>) {
    const COST_BASE: u64 = 15;
    const COST_WORD: u64 = 3;

    // Calculate the number of 32-byte words, rounding up
    let word_size = (data.len() as u64 + 31) / 32;

    // Calculate gas cost
    let gas_cost = match COST_BASE.checked_add(COST_WORD.checked_mul(word_size).unwrap_or(u64::MAX)) {
        Some(cost) => cost,
        None => return (CallResult::OutOfGas, 0, Vec::new()),
    };

    // The identity function simply returns the input data
    (CallResult::Success, gas_cost, data.to_vec())
}

fn mod_exp(data: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    const MIN_GAS_COST: u64 = 200;
    // Ensure we have at least 96 bytes of data, padding with zeros if necessary
    let mut input = vec![0u8; 96];
    input[..std::cmp::min(data.len(), 96)].copy_from_slice(&data[..std::cmp::min(data.len(), 96)]);

    let base_len = U256::from_big_endian(&input[0..32]);
    let exp_len = U256::from_big_endian(&input[32..64]);
    let mod_len = U256::from_big_endian(&input[64..96]);

    // Check if lengths are valid
    if base_len > U256::from(u32::MAX) || exp_len > U256::from(u32::MAX) || mod_len > U256::from(u32::MAX) {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let base_len = base_len.as_u64() as usize;
    let exp_len = exp_len.as_u64() as usize;
    let mod_len = mod_len.as_u64() as usize;

    if input.len() < 96 + base_len {
        input.resize(96 + base_len, 0);
    }

    // Calculate gas cost
    let gas_cost = calculate_modexp_gas(base_len, exp_len, mod_len, &input[96 + base_len..]);

    if base_len == 0 && mod_len == 0 {
        return (CallResult::Success, MIN_GAS_COST, Vec::new());
    }

    // Check if gas cost exceeds gas limit
    if gas_cost > gas_limit {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    // Extend input if necessary
    if input.len() < 96 + base_len + exp_len + mod_len {
        input.resize(96 + base_len + exp_len + mod_len, 0);
    }

    

    let base = BigUint::from_bytes_be(&input[96..96 + base_len]);
    let exp = BigUint::from_bytes_be(&input[96 + base_len..96 + base_len + exp_len]);
    let modulus = BigUint::from_bytes_be(&input[96 + base_len + exp_len..96 + base_len + exp_len + mod_len]);

    // Perform modular exponentiation
    let result = if modulus.is_zero() || modulus.is_one() {
        vec![0u8; mod_len]
    } else {
        let result = base.modpow(&exp, &modulus);
        let result_bytes = result.to_bytes_be();
        if result_bytes.len() < mod_len {
            let mut padded = vec![0u8; mod_len - result_bytes.len()];
            padded.extend_from_slice(&result_bytes);
            padded
        } else {
            result_bytes
        }
    };

    (CallResult::Success, gas_cost, result)
}

fn calculate_modexp_gas(base_len: usize, exp_len: usize, mod_len: usize, exp_head: &[u8]) -> u64 {
    const MIN_GAS_COST: u64 = 200;
    fn calculate_multiplication_complexity(base_length: u64, mod_length: u64) -> u64 {
        let max_length = std::cmp::max(base_length, mod_length);
        let mut words = max_length / 8;
        if max_length % 8 > 0 {
            words += 1;
        }
        words * words
    }

    fn calculate_iteration_count(exp_len: usize, exp_head: &[u8]) -> u64 {
        if exp_len <= 32 && exp_head.iter().all(|&b| b == 0) {
            0
        } else if exp_len <= 32 {
            let exp = BigUint::from_bytes_be(exp_head);
            exp.bits() - 1
        } else {
            let exp_head = BigUint::from_bytes_be(&exp_head[..32]);
            (8 * (exp_len as u64 - 32)) + exp_head.bits() - 1
        }
    }

    let multiplication_complexity = calculate_multiplication_complexity(base_len as u64, mod_len as u64);
    let iteration_count = std::cmp::max(calculate_iteration_count(exp_len, exp_head), 1);
    
    let gas_cost = std::cmp::max(
        MIN_GAS_COST,
        multiplication_complexity.saturating_mul(iteration_count) / 3
    );

    // Check if modulus is even (last byte's least significant bit is 0)
    let mod_is_even = mod_len > 0 && exp_head.len() >= mod_len && (exp_head[mod_len - 1] & 1 == 0);
    
    gas_cost.saturating_mul(if mod_is_even { 20 } else { 1 })
}

fn ecadd(input: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    if gas_limit < ECADD_GAS {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let mut padded_input = vec![0u8; 128];
    padded_input[..input.len()].copy_from_slice(input);

    // Parse the input into two points
    let mut buf = [0u8; 32];

    buf.copy_from_slice(&padded_input[0..32]);
    let x1 = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    buf.copy_from_slice(&padded_input[32..64]);
    let y1 = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    buf.copy_from_slice(&padded_input[64..96]);
    let x2 = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    buf.copy_from_slice(&padded_input[96..128]);
    let y2 = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    // Create affine points
    let p1 = if x1.is_zero() && y1.is_zero() {
        G1::zero()
    } else {
        AffineG1::new(x1, y1).map(Into::into).unwrap_or(G1::zero())
    };

    let p2 = if x2.is_zero() && y2.is_zero() {
        G1::zero()
    } else {
        AffineG1::new(x2, y2).map(Into::into).unwrap_or(G1::zero())
    };

    // Perform the addition
    let result = AffineG1::from_jacobian(p1 + p2).unwrap_or_else(|| AffineG1::new(Fq::zero(), Fq::zero()).unwrap());

    // Encode the result
    let mut output = vec![0u8; 64];
    result.x().to_big_endian(&mut output[0..32]).unwrap();
    result.y().to_big_endian(&mut output[32..64]).unwrap();

    (CallResult::Success, ECADD_GAS, output)
}

fn ecmul(input: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    if gas_limit < ECMUL_GAS {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let mut padded_input = vec![0u8; 96];
    padded_input[..input.len()].copy_from_slice(input);

    // Parse the input point and scalar
    let mut buf = [0u8; 32];

    buf.copy_from_slice(&padded_input[0..32]);
    let x = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    buf.copy_from_slice(&padded_input[32..64]);
    let y = Fq::from_slice(&buf).unwrap_or(Fq::zero());

    buf.copy_from_slice(&padded_input[64..96]);
    let scalar = Fr::from_slice(&buf).unwrap_or(Fr::zero());

    // Create affine point
    let p = if x.is_zero() && y.is_zero() {
        G1::zero()
    } else {
        AffineG1::new(x, y).map(Into::into).unwrap_or(G1::zero())
    };

    // Perform the scalar multiplication
    let result = AffineG1::from_jacobian(p * scalar).unwrap_or_else(|| AffineG1::new(Fq::zero(), Fq::zero()).unwrap());

    // Encode the result
    let mut output = vec![0u8; 64];
    result.x().to_big_endian(&mut output[0..32]).unwrap();
    result.y().to_big_endian(&mut output[32..64]).unwrap();

    (CallResult::Success, ECMUL_GAS, output)
}

fn ecpairing(input: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    let point_count = (input.len() + 191) / 192; // Round up
    let gas = ECPAIRING_BASE_GAS + (point_count as u64 * ECPAIRING_PER_POINT_GAS);

    if gas > gas_limit {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let mut padded_input = vec![0u8; point_count * 192];
    padded_input[..input.len()].copy_from_slice(input);

    let mut pairs = vec![];

    for chunk in padded_input.chunks(192) {
        let mut buf = [0u8; 32];

        buf.copy_from_slice(&chunk[0..32]);
        let ax = Fq::from_slice(&buf).unwrap_or(Fq::zero());
        buf.copy_from_slice(&chunk[32..64]);
        let ay = Fq::from_slice(&buf).unwrap_or(Fq::zero());
        let a = if ax.is_zero() && ay.is_zero() {
            G1::zero()
        } else {
            AffineG1::new(ax, ay).map(Into::into).unwrap_or(G1::zero())
        };

        buf.copy_from_slice(&chunk[64..96]);
        let bx_re = Fq::from_slice(&buf).unwrap_or(Fq::zero());
        buf.copy_from_slice(&chunk[96..128]);
        let bx_im = Fq::from_slice(&buf).unwrap_or(Fq::zero());
        buf.copy_from_slice(&chunk[128..160]);
        let by_re = Fq::from_slice(&buf).unwrap_or(Fq::zero());
        buf.copy_from_slice(&chunk[160..192]);
        let by_im = Fq::from_slice(&buf).unwrap_or(Fq::zero());

        let b = if bx_re.is_zero() && bx_im.is_zero() && by_re.is_zero() && by_im.is_zero() {
            G2::zero()
        } else {
            AffineG2::new(
                Fq2::new(bx_re, bx_im),
                Fq2::new(by_re, by_im),
            ).map(Into::into).unwrap_or(G2::zero())
        };

        pairs.push((a, b));
    }

    let result = pairing_batch(&pairs);

    let mut output = vec![0u8; 32];
    if result == Gt::one() {
        output[31] = 1;
    }

    (CallResult::Success, gas, output)
}

fn blake2f(input: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    let mut padded_input = vec![0u8; 213];
    padded_input[..input.len()].copy_from_slice(input);

    let mut rounds_buf = [0u8; 4];
    rounds_buf.copy_from_slice(&padded_input[0..4]);
    let rounds = u32::from_be_bytes(rounds_buf);

    let gas_cost = u64::from(rounds) * BLAKE2_F_GAS;

    if gas_cost > gas_limit {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let mut h = [0u64; 8];
    for (i, state_word) in h.iter_mut().enumerate() {
        let mut temp = [0u8; 8];
        temp.copy_from_slice(&padded_input[4 + i * 8..12 + i * 8]);
        *state_word = u64::from_le_bytes(temp);
    }

    let mut m = [0u64; 16];
    for (i, msg_word) in m.iter_mut().enumerate() {
        let mut temp = [0u8; 8];
        temp.copy_from_slice(&padded_input[68 + i * 8..76 + i * 8]);
        *msg_word = u64::from_le_bytes(temp);
    }

    let mut t_0_buf = [0u8; 8];
    t_0_buf.copy_from_slice(&padded_input[196..204]);
    let t_0 = u64::from_le_bytes(t_0_buf);

    let mut t_1_buf = [0u8; 8];
    t_1_buf.copy_from_slice(&padded_input[204..212]);
    let t_1 = u64::from_le_bytes(t_1_buf);

    let f = padded_input[212] != 0;

    eip152::compress(&mut h, m, [t_0, t_1], f, rounds as usize);

    let mut output = Vec::with_capacity(64);
    for state_word in &h {
        output.extend_from_slice(&state_word.to_le_bytes());
    }

    (CallResult::Success, gas_cost, output)
}