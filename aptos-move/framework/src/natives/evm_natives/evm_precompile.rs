use crate::natives::evm_natives::{
    eip152
};

use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};
use core::cmp::max;
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use ethers::types::{U256};
use num::{BigUint, FromPrimitive, Integer, One, ToPrimitive, Zero};
use bn::{pairing_batch, AffineG1, AffineG2, Fq, Fq2, Group, Gt, G1, G2};

fn native_ecrecover(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut arguments: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let signature = safely_pop_arg!(arguments, Vec<u8>);
    let recovery_id = safely_pop_arg!(arguments, u8);
    let msg = safely_pop_arg!(arguments, Vec<u8>);

    // NOTE(Gas): O(1) cost
    // (In reality, O(|msg|) deserialization cost, with |msg| < libsecp256k1_core::util::MESSAGE_SIZE
    // which seems to be 32 bytes, so O(1) cost for all intents and purposes.)
    let msg = match libsecp256k1::Message::parse_slice(&msg) {
        Ok(msg) => msg,
        Err(_) => {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        },
    };

    // NOTE(Gas): O(1) cost
    let rid = match libsecp256k1::RecoveryId::parse(recovery_id) {
        Ok(rid) => rid,
        Err(_) => {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        },
    };

    // NOTE(Gas): O(1) deserialization cost
    // which seems to be 64 bytes, so O(1) cost for all intents and purposes.
    let sig = match libsecp256k1::Signature::parse_standard_slice(&signature) {
        Ok(sig) => sig,
        Err(_) => {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        },
    };

    // NOTE(Gas): O(1) cost: a size-2 multi-scalar multiplication
    match libsecp256k1::recover(&msg, &sig, &rid) {
        Ok(pk) => Ok(smallvec![
            Value::bool(true),
            Value::vector_u8(pk.serialize()[1..].to_vec()),
        ]),
        Err(_) => Ok(smallvec![Value::bool(false), Value::vector_u8([0u8; 0])]),
    }
}

fn native_blake_2f(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let input = safely_pop_arg!(args, Vec<u8>);
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
        return Ok(smallvec![
            Value::bool(false),
            Value::u64(gas_cost),
            Value::vector_u8(Vec::new())
        ])  
    };


    eip152::compress(&mut h, m, [t_0, t_1], f, rounds as usize);
    let mut output_buf = [0u8; u64::BITS as usize];
    for (i, state_word) in h.iter().enumerate() {
        output_buf[i * 8..(i + 1) * 8].copy_from_slice(&state_word.to_le_bytes());
    }
    result = output_buf.to_vec();

    Ok(smallvec![
        Value::bool(true),
        Value::u64(gas_cost),
        Value::vector_u8(result)
    ])  
}

/// Copy bytes from input to target.
fn read_extend_input(source: &[u8], target: &mut [u8], source_offset: &mut usize) {
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

/// Copy bytes from input to target.
fn read_input(source: &[u8], target: &mut [u8], offset: usize) {
    // Out of bounds, nothing to copy.
    if source.len() <= offset {
        return;
    }

    // Find len to copy up to target len, but not out of bounds.
    let len = core::cmp::min(target.len(), source.len() - offset);
    target[..len].copy_from_slice(&source[offset..][..len]);
}

fn read_fr(input: &[u8], start_inx: usize) -> Result<bn::Fr, String> {
    let mut buf = [0u8; 32];
    read_input(input, &mut buf, start_inx);

    let ret = bn::Fr::from_slice(&buf)
        .map_err(|_| "Invalid field element")?;
    Ok(ret)
}

fn read_fq(input: &[u8], start_inx: usize) -> Result<bn::Fq, String> {
    let mut buf = [0u8; 32];
    read_input(input, &mut buf, start_inx);

    let ret = bn::Fq::from_slice(&buf)
        .map_err(|_| "Invalid field element")?;
    Ok(ret)
}

fn read_point(input: &[u8], start_inx: usize) -> Result<bn::G1, String> {
    let mut px_buf = [0u8; 32];
    let mut py_buf = [0u8; 32];
    read_input(input, &mut px_buf, start_inx);
    read_input(input, &mut py_buf, start_inx + 32);

    let px = Fq::from_slice(&px_buf)
        .map_err(|_| "Invalid point x coordinate")?;

    let py = Fq::from_slice(&py_buf)
        .map_err(|_| "Invalid point y coordinate")?;

    Ok(if px == Fq::zero() && py == Fq::zero() {
        G1::zero()
    } else {
        AffineG1::new(px, py)
            .map_err(|_| "Invalid curve point")?
            .into()
    })
}

fn native_bn128_add(_context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let input = safely_pop_arg!(args, Vec<u8>);
    // let success =
    let p1 = read_point(&input, 0);
    let p2 = read_point(&input, 64);

    if !p1.is_ok() || !p2.is_ok() {
        return Ok(smallvec![
            Value::bool(false),
            Value::vector_u8(Vec::new())
        ])
    }

    let mut buf = [0u8; 64];
    if let Some(sum) = AffineG1::from_jacobian(p1.unwrap() + p2.unwrap()) {
    // point not at infinity
        if let Err(_) = sum.x().to_big_endian(&mut buf[0..32]) {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        }
        if let Err(_) = sum.y().to_big_endian(&mut buf[32..64]) {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        }
    }
    Ok(smallvec![
        Value::bool(true),
        Value::vector_u8(buf.to_vec())
    ]) 
}

fn native_bn128_mul(_context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let input = safely_pop_arg!(args, Vec<u8>);
    // let success =
    let p = read_point(&input, 0);
    let fr = read_fr(&input, 64);

    if !p.is_ok() || !fr.is_ok() {
        return Ok(smallvec![
            Value::bool(false),
            Value::vector_u8(Vec::new())
        ])
    }

    let mut buf = [0u8; 64];
    if let Some(sum) = AffineG1::from_jacobian(p.unwrap() * fr.unwrap()) {
    // point not at infinity
        if let Err(_) = sum.x().to_big_endian(&mut buf[0..32]) {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        }
        if let Err(_) = sum.y().to_big_endian(&mut buf[32..64]) {
            return Ok(smallvec![
                Value::bool(false),
                Value::vector_u8(Vec::new())
            ])
        }
    }
    Ok(smallvec![
        Value::bool(true),
        Value::vector_u8(buf.to_vec())
    ]) 
}

fn native_bn128_pairing(_context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let input = safely_pop_arg!(args, Vec<u8>);
    // let success =
    const BASE_GAS_COST: u64 = 45_000;
    const GAS_COST_PER_PAIRING: u64 = 34_000;
    let (gas, ret_val) = if input.is_empty() {
        (BASE_GAS_COST, U256::one())
    } else {
        if input.len() % 192 > 0 {
            return Ok(smallvec![
                Value::bool(false),
                Value::u64(0),
                Value::vector_u8(Vec::new())
            ]);
        }

        let elements = input.len() / 192;
        let gas_cost: u64 = BASE_GAS_COST
            + (elements as u64 * GAS_COST_PER_PAIRING);

        let mut vals = Vec::new();
        for idx in 0..elements {
            let a_x = read_fq(&input, idx * 192);
            let a_y = read_fq(&input, idx * 192 + 32);
            let b_a_y = read_fq(&input, idx * 192 + 64);
            let b_a_x = read_fq(&input, idx * 192 + 96);
            let b_b_y = read_fq(&input, idx * 192 + 128);
            let b_b_x = read_fq(&input, idx * 192 + 160);
            if !a_x.is_ok() || !a_y.is_ok() || !b_a_x.is_ok() || !b_a_y.is_ok() || !b_b_x.is_ok() || !b_b_y.is_ok() {
                return Ok(smallvec![
                    Value::bool(false),
                    Value::u64(0),
                    Value::vector_u8(Vec::new())
                ]);
            }
            let a_x = a_x.unwrap();
            let a_y = a_y.unwrap();
            let b_a = Fq2::new(b_a_x.unwrap(), b_a_y.unwrap());
            let b_b = Fq2::new(b_b_x.unwrap(), b_b_y.unwrap());
            let b = if b_a.is_zero() && b_b.is_zero() {
                G2::zero()
            } else {
                let result = AffineG2::new(b_a, b_b);
                if !result.is_ok() {
                    return Ok(smallvec![
                        Value::bool(false),
                        Value::u64(0),
                        Value::vector_u8(Vec::new())
                    ]);
                }
                G2::from(result.unwrap())
            };
            let a = if a_x.is_zero() && a_y.is_zero() {
                G1::zero()
            } else {
                let result = AffineG1::new(a_x, a_y);
                if !result.is_ok() {
                    return Ok(smallvec![
                        Value::bool(false),
                        Value::u64(0),
                        Value::vector_u8(Vec::new())
                    ]);
                }
                G1::from(result.unwrap())
            };
            vals.push((a, b));
        }

        let mul = pairing_batch(&vals);

        if mul == Gt::one() {
            (gas_cost, U256::one())
        } else {
            (gas_cost, U256::zero())
        }
    };

    let mut buf = [0u8; 32];
    ret_val.to_big_endian(&mut buf);
    Ok(smallvec![
        Value::bool(true),
        Value::u64(gas),
        Value::vector_u8(buf.to_vec())
    ])
}

fn calculate_gas_cost(
    base_length: u64,
    mod_length: u64,
    exponent: &BigUint,
    exponent_bytes: &[u8],
    mod_is_even: bool,
) -> u64 {
    const MIN_GAS_COST: u64 = 200;
    fn calculate_multiplication_complexity(base_length: u64, mod_length: u64) -> u64 {
        let max_length = max(base_length, mod_length);
        let mut words = max_length / 8;
        if max_length % 8 > 0 {
            words += 1;
        }

        // Note: can't overflow because we take words to be some u64 value / 8, which is
        // necessarily less than sqrt(u64::MAX).
        // Additionally, both base_length and mod_length are bounded to 1024, so this has
        // an upper bound of roughly (1024 / 8) squared
        words * words
    }

    fn calculate_iteration_count(exponent: &BigUint, exponent_bytes: &[u8]) -> u64 {
        let mut iteration_count: u64 = 0;
        let exp_length = exponent_bytes.len() as u64;

        if exp_length <= 32 && exponent.is_zero() {
            iteration_count = 0;
        } else if exp_length <= 32 {
            iteration_count = exponent.bits() - 1;
        } else if exp_length > 32 {
            // from the EIP spec:
            // (8 * (exp_length - 32)) + ((exponent & (2**256 - 1)).bit_length() - 1)
            //
            // Notes:
            // * exp_length is bounded to 1024 and is > 32
            // * exponent can be zero, so we subtract 1 after adding the other terms (whose sum
            //   must be > 0)
            // * the addition can't overflow because the terms are both capped at roughly
            //   8 * max size of exp_length (1024)
            // * the EIP spec is written in python, in which (exponent & (2**256 - 1)) takes the
            //   FIRST 32 bytes. However this `BigUint` `&` operator takes the LAST 32 bytes.
            //   We thus instead take the bytes manually.
            let exponent_head = BigUint::from_bytes_be(&exponent_bytes[..32]);

            iteration_count = (8 * (exp_length - 32)) + exponent_head.bits() - 1;
        }

        max(iteration_count, 1)
    }

    let multiplication_complexity = calculate_multiplication_complexity(base_length, mod_length);
    let iteration_count = calculate_iteration_count(exponent, exponent_bytes);
    max(
        MIN_GAS_COST,
        multiplication_complexity * iteration_count / 3,
    )
    .saturating_mul(if mod_is_even { 20 } else { 1 })
}

fn native_mod_exp(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    const MIN_GAS_COST: u64 = 200;
    let input = safely_pop_arg!(args, Vec<u8>);
    let mut input_offset = 0;

    let mut base_len_buf = [0u8; 32];
    read_extend_input(&input, &mut base_len_buf, &mut input_offset);
    let mut exp_len_buf = [0u8; 32];
    read_extend_input(&input, &mut exp_len_buf, &mut input_offset);
    let mut mod_len_buf = [0u8; 32];
    read_extend_input(&input, &mut mod_len_buf, &mut input_offset);

    let max_size_big = BigUint::from_u32(1024).expect("can't create BigUint");
    let base_len_big = BigUint::from_bytes_be(&base_len_buf);
    if base_len_big > max_size_big {
        return Ok(smallvec![
            Value::bool(false),
            Value::u64(0),
            Value::vector_u8(Vec::new())
        ])
    };

    let exp_len_big = BigUint::from_bytes_be(&exp_len_buf);
    if exp_len_big > max_size_big {
        return Ok(smallvec![
            Value::bool(false),
            Value::u64(0),
            Value::vector_u8(Vec::new())
        ])
    };

    let mod_len_big = BigUint::from_bytes_be(&mod_len_buf);
    if mod_len_big > max_size_big {
        return Ok(smallvec![
            Value::bool(false),
            Value::u64(0),
            Value::vector_u8(Vec::new())
        ])
    };

    let base_len = base_len_big.to_usize().expect("base_len out of bounds");
    let exp_len = exp_len_big.to_usize().expect("exp_len out of bounds");
    let mod_len = mod_len_big.to_usize().expect("mod_len out of bounds");

    let mut gas_cost = 0;
    let r = if base_len == 0 && mod_len == 0 {
        return Ok(smallvec![
            Value::bool(true),
            Value::u64(MIN_GAS_COST),
            Value::vector_u8(Vec::new())
        ])
    } else {
        // read the numbers themselves.
        let mut base_buf = vec![0u8; base_len];
        read_extend_input(&input, &mut base_buf, &mut input_offset);
        let base = BigUint::from_bytes_be(&base_buf);

        let mut exp_buf = vec![0u8; exp_len];
        read_extend_input(&input, &mut exp_buf, &mut input_offset);
        let exponent = BigUint::from_bytes_be(&exp_buf);

        let mut mod_buf = vec![0u8; mod_len];
        read_extend_input(&input, &mut mod_buf, &mut input_offset);
        let modulus = BigUint::from_bytes_be(&mod_buf);

            // do our gas accounting
        gas_cost = calculate_gas_cost(
            base_len as u64,
            mod_len as u64,
            &exponent,
            &exp_buf,
            modulus.is_even(),
        );

        if modulus.is_zero() || modulus.is_one() {
            BigUint::zero()
        } else {
            base.modpow(&exponent, &modulus)
        }
    };

    let bytes = r.to_bytes_be();

    let result = if bytes.len() == mod_len {
        bytes.to_vec()
    } else if bytes.len() < mod_len {
        let mut ret = Vec::with_capacity(mod_len);
        ret.extend(core::iter::repeat(0).take(mod_len - bytes.len()));
        ret.extend_from_slice(&bytes[..]);
        ret.to_vec()
    } else {
        return Ok(smallvec![
            Value::bool(false),
            Value::u64(0),
            Value::vector_u8(Vec::new())
        ])
    };

    Ok(smallvec![
        Value::bool(true),
        Value::u64(gas_cost),
        Value::vector_u8(result)
    ])
}

/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("ecrecover_internal", native_ecrecover as RawSafeNative),
        ("bn128_add", native_bn128_add as RawSafeNative),
        ("bn128_mul", native_bn128_mul as RawSafeNative),
        ("mod_exp", native_mod_exp as RawSafeNative),
        ("bn128_pairing", native_bn128_pairing as RawSafeNative),
        ("blake_2f", native_blake_2f as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}