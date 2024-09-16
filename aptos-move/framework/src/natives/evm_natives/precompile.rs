use primitive_types::{H160, H256, U256};
use crate::natives::evm_natives::{
    constants::CallResult,
    eip152
};
use sha3::{Digest, Keccak256};
use sha2::Sha256;
use ripemd::Ripemd160;
use num::{BigUint, FromPrimitive, ToPrimitive, Zero, One};
use bn::{pairing_batch, AffineG1, AffineG2, Fq, Fq2, Group, Gt, G1, G2};

const ECADD_GAS: u64 = 150;
const ECMUL_GAS: u64 = 6000;
const ECPAIRING_BASE_GAS: u64 = 45000;
const ECPAIRING_PER_POINT_GAS: u64 = 34000;

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
        9 => blake2f(&calldata),
        _ => (CallResult::Exception, gas_limit, Vec::new()),
    }
}

fn ecrecover(data: &[u8]) -> (CallResult, u64, Vec<u8>) {
    const COST_BASE: u64 = 3000;
    let mut input = [0u8; 128];
    let len = std::cmp::min(data.len(), 128);
    input[..len].copy_from_slice(&data[..len]);

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

    
    let msg = match libsecp256k1::Message::parse_slice(&msg) {
        Ok(msg) => msg,
        Err(_) => {
            return (CallResult::Success, COST_BASE, vec![0u8; 32])
        },
    };

    // NOTE(Gas): O(1) cost
    let rid = match libsecp256k1::RecoveryId::parse(input[63] - 27) {
        Ok(rid) => rid,
        Err(_) => return (CallResult::Success, COST_BASE, vec![0u8; 32]),
    };

    // NOTE(Gas): O(1) deserialization cost
    // which seems to be 64 bytes, so O(1) cost for all intents and purposes.
    let signature = match libsecp256k1::Signature::parse_standard_slice(&sig) {
        Ok(sig) => sig,
        Err(_) => return (CallResult::Success, COST_BASE, vec![0u8; 32])
    };

    // NOTE(Gas): O(1) cost: a size-2 multi-scalar multiplication
    let pubkey = match libsecp256k1::recover(&msg, &signature, &rid) {
        Ok(pk) => pk,
        Err(_) => return (CallResult::Success, COST_BASE, vec![0u8; 32])
    };

    // Compute the Ethereum address from the public key
    let mut address = H256::from_slice(Keccak256::digest(&pubkey.serialize()[1..].to_vec()).as_slice());
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

fn read_input(source: &[u8], target: &mut [u8], source_offset: &mut usize) {
    // We move the offset by the len of the target, regardless of what we
    // actually copy.
    let offset = *source_offset;
    *source_offset += target.len();

    // Out of bounds, nothing to copy.
    if source.len() <= offset {
        return;
    }

    // Find len to copy up to target len, but not out of bounds.
    let len = core::cmp::min(target.len(), source.len() - offset);
    target[..len].copy_from_slice(&source[offset..][..len]);
}

fn mod_exp(data: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    const MIN_GAS_COST: u64 = 200;

    let mut input_offset = 0;

    // Ensure we have at least 96 bytes of data, padding with zeros if necessary
    let mut base_len_buf = [0u8; 32];
	read_input(data, &mut base_len_buf, &mut input_offset);
	let mut exp_len_buf = [0u8; 32];
	read_input(data, &mut exp_len_buf, &mut input_offset);
	let mut mod_len_buf = [0u8; 32];
	read_input(data, &mut mod_len_buf, &mut input_offset);

    let max_size_big = BigUint::from_u32(1024).expect("can't create BigUint");

	let base_len_big = BigUint::from_bytes_be(&base_len_buf);
	if base_len_big > max_size_big {
		return (CallResult::OutOfGas, 0, Vec::new());
	}

	let exp_len_big = BigUint::from_bytes_be(&exp_len_buf);
	if exp_len_big > max_size_big {
		return (CallResult::OutOfGas, 0, Vec::new());
	}

	let mod_len_big = BigUint::from_bytes_be(&mod_len_buf);
	if mod_len_big > max_size_big {
		return (CallResult::OutOfGas, 0, Vec::new());
	}


    let base_len = base_len_big.to_usize().unwrap();
    let exp_len = exp_len_big.to_usize().unwrap();
    let mod_len = mod_len_big.to_usize().unwrap();
    
    if base_len == 0 && mod_len == 0 {
        return (CallResult::Success, MIN_GAS_COST, Vec::new());
    }

    let mut base_buf = vec![0u8; base_len];
	read_input(data, &mut base_buf, &mut input_offset);
	let base = BigUint::from_bytes_be(&base_buf);

	let mut exp_buf = vec![0u8; exp_len];
	read_input(data, &mut exp_buf, &mut input_offset);
	let exponent = BigUint::from_bytes_be(&exp_buf);

	let mut mod_buf = vec![0u8; mod_len];
	read_input(data, &mut mod_buf, &mut input_offset);
	let modulus = BigUint::from_bytes_be(&mod_buf);

    let gas_cost = calculate_modexp_gas(base_len, exp_len, mod_len, &exp_buf);
    // Check if gas cost exceeds gas limit
    if gas_cost > gas_limit {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    println!("mod exp {} {} {} {}", base_len, exp_len, mod_len, gas_cost);

    // Perform modular exponentiation
    let result = if modulus.is_zero() || modulus.is_one() {
        vec![0u8; mod_len]
    } else {
        let result = base.modpow(&exponent, &modulus);
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

    println!("123 {} {}", multiplication_complexity, iteration_count);
    let gas_cost = std::cmp::max(
        MIN_GAS_COST,
        multiplication_complexity.saturating_mul(iteration_count) / 3
    );

    gas_cost

    // // Check if modulus is even (last byte's least significant bit is 0)
    // let mod_is_even = mod_len > 0 && exp_head.len() >= mod_len && (exp_head[mod_len - 1] & 1 == 0);
    
    // gas_cost.saturating_mul(if mod_is_even { 20 } else { 1 })
}

fn read_point_input(source: &[u8], target: &mut [u8], offset: usize) {
	// Out of bounds, nothing to copy.
	if source.len() <= offset {
		return;
	}

	// Find len to copy up to target len, but not out of bounds.
	let len = core::cmp::min(target.len(), source.len() - offset);
	target[..len].copy_from_slice(&source[offset..][..len]);
}

fn read_point(input: &[u8], start_inx: usize) -> Result<bn::G1, CallResult> {
	let mut px_buf = [0u8; 32];
    let mut py_buf = [0u8; 32];
    read_point_input(input, &mut px_buf, start_inx);
    read_point_input(input, &mut py_buf, start_inx + 32);

    let px = Fq::from_slice(&px_buf).map_err(|_| CallResult::Exception)?;
    let py = Fq::from_slice(&py_buf).map_err(|_| CallResult::Exception)?;

    Ok(if px == Fq::zero() && py == Fq::zero() {
        G1::zero()
    } else {
        AffineG1::new(px, py).map_err(|_| CallResult::Exception)?.into()
    })
}

fn read_fr(input: &[u8], start_inx: usize) -> Result<bn::Fr, CallResult> {
    let mut buf = [0u8; 32];
    read_point_input(input, &mut buf, start_inx);

    let ret = bn::Fr::from_slice(&buf).map_err(|_| CallResult::Exception)?;
    Ok(ret)
}

fn ecadd(input: &[u8], gas_limit: u64) -> (CallResult, u64, Vec<u8>) {
    if gas_limit < ECADD_GAS {
        return (CallResult::OutOfGas, 0, Vec::new());
    }

    let expected_len = 128;
    let mut padded_input = vec![0u8; expected_len];
    let len = std::cmp::min(input.len(), expected_len);
    padded_input[..len].copy_from_slice(&input[..len]);

    // Parse the input into two points
    let p1 = match read_point(&padded_input, 0) {
        Ok(point) => point,
        Err(e) => return (e, 0, Vec::new()),
    };

    let p2 = match read_point(&padded_input, 64) {
        Ok(point) => point,
        Err(e) => return (e, 0, Vec::new()),
    };

    // Perform the addition
    let result = match AffineG1::from_jacobian(p1 + p2) {
        Some(res) => res,
        None => return (CallResult::Exception, 0, Vec::new()),
    };
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

    let expected_len = 96;
    let mut padded_input = vec![0u8; expected_len];
    let len = std::cmp::min(input.len(), expected_len);
    padded_input[..len].copy_from_slice(&input[..len]);

    // Parse the input point
    let p = match read_point(&padded_input, 0) {
        Ok(point) => point,
        Err(e) => return (e, 0, Vec::new()),
    };

    // Parse the scalar
    let scalar = match read_fr(&padded_input, 64) {
        Ok(s) => s,
        Err(e) => return (e, 0, Vec::new()),
    };

    // Perform the scalar multiplication
    let result = match AffineG1::from_jacobian(p * scalar) {
        Some(res) => res,
        None => return (CallResult::Exception, 0, Vec::new()),
    };

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

    let expected_len = point_count * 192;
    let mut padded_input = vec![0u8; expected_len];
    let len = std::cmp::min(input.len(), expected_len);
    padded_input[..len].copy_from_slice(&input[..len]);


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

fn blake2f(input: &[u8]) -> (CallResult, u64, Vec<u8>) {
    let expected_len = 213;

    if input.len() != expected_len {
        return (CallResult::Exception, 0, Vec::new());;
    }

    let result;

    let mut rounds_buf: [u8; 4] = [0; 4];
    rounds_buf.copy_from_slice(&input[0..4]);
    let rounds: u32 = u32::from_be_bytes(rounds_buf);

    let gas_cost: u64 = rounds as u64;

// we use from_le_bytes below to effectively swap byte order to LE if architecture is BE
    let mut h_buf: [u8; 64] = [0; 64];
    h_buf.copy_from_slice(&input[4..68]);
    let mut h = [0u64; 8];
    let mut ctr = 0;
    for state_word in &mut h {
        let mut temp: [u8; 8] = Default::default();
        temp.copy_from_slice(&h_buf[(ctr * 8)..(ctr + 1) * 8]);
        *state_word = u64::from_le_bytes(temp);
        ctr += 1;
    }

    let mut m_buf: [u8; 128] = [0; 128];
    m_buf.copy_from_slice(&input[68..196]);
    let mut m = [0u64; 16];
    ctr = 0;
    for msg_word in &mut m {
        let mut temp: [u8; 8] = Default::default();
        temp.copy_from_slice(&m_buf[(ctr * 8)..(ctr + 1) * 8]);
        *msg_word = u64::from_le_bytes(temp);
        ctr += 1;
    }

    let mut t_0_buf: [u8; 8] = [0; 8];
    t_0_buf.copy_from_slice(&input[196..204]);
    let t_0 = u64::from_le_bytes(t_0_buf);

    let mut t_1_buf: [u8; 8] = [0; 8];
    t_1_buf.copy_from_slice(&input[204..212]);
    let t_1 = u64::from_le_bytes(t_1_buf);

    let f = if input[212] == 1 {
        true
    } else if input[212] == 0 {
        false
    } else {
        return (CallResult::Success, gas_cost, Vec::new());
    };


    eip152::compress(&mut h, m, [t_0, t_1], f, rounds as usize);
    let mut output_buf = [0u8; u64::BITS as usize];
    for (i, state_word) in h.iter().enumerate() {
        output_buf[i * 8..(i + 1) * 8].copy_from_slice(&state_word.to_le_bytes());
    }
    result = output_buf.to_vec();

    (CallResult::Success, gas_cost, result)
}