use crate::natives::evm_natives::{
    helpers::{move_u256_to_evm_u256, evm_u256_to_move_u256},
    eip152
};

use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value}
};
use move_core_types::{u256::U256 as move_u256};
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use ethers::types::{U256, U512};
use num::{BigUint, Zero, One};
use bn::{pairing_batch, AffineG1, AffineG2, Fq, Fq2, Group, Gt, G1, G2};

fn get_and_reset_sign(value: U256) -> (U256, bool) {
    let U256(arr) = value;
    let sign = arr[3].leading_zeros() == 0;
    (set_sign(value, sign), sign)
}

fn set_sign(value: U256, sign: bool) -> U256 {
    if sign {
        (!U256::zero() ^ value).overflowing_add(U256::one()).0
    } else {
        value
    }
}

fn native_add(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = a.overflowing_add(b).0;

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_mul(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = a.overflowing_mul(b).0;

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_sub(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = a.overflowing_sub(b).0;

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_div(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = if b.is_zero() {U256::zero()} else {a / b};

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_mod(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = if b.is_zero() {U256::zero()} else {a % b};

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_sdiv(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let (a, sign_a) = get_and_reset_sign(a);
    let (b, sign_b) = get_and_reset_sign(b);
    let min = (U256::one() << 255) - U256::one();
    let n = if b.is_zero() {
        U256::zero()
    } else if a == min && b == !U256::zero() {
        min
    } else {
        let c = a / b;
        set_sign(c, sign_a ^ sign_b)
    };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_smod(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let ub = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let ua = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let (a, sign_a) = get_and_reset_sign(ua);
    let b = get_and_reset_sign(ub).0;

    let n = if b.is_zero() {
        U256::zero()
    } else {
        let c = a % b;
        set_sign(c, sign_a)
    };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}


fn native_exp(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = a.overflowing_pow(b).0;

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_slt(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let (a, neg_a) = get_and_reset_sign(a);
    let (b, neg_b) = get_and_reset_sign(b);

    let is_positive_lt = a < b && !(neg_a | neg_b);
    let is_negative_lt = a > b && (neg_a & neg_b);
    let has_different_signs = neg_a && !neg_b;

    Ok(smallvec![
        Value::bool(is_positive_lt | is_negative_lt | has_different_signs)
    ])
}

fn native_sgt(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let (a, neg_a) = get_and_reset_sign(a);
    let (b, neg_b) = get_and_reset_sign(b);

    let is_positive_gt = a > b && !(neg_a | neg_b);
    let is_negative_gt = a < b && (neg_a & neg_b);
    let has_different_signs = !neg_a && neg_b;

    Ok(smallvec![
        Value::bool(is_positive_gt | is_negative_gt | has_different_signs)
    ])
}

fn native_add_mod(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let c = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    
    let n = if c.is_zero() {
        U256::zero()
    } else {
        let a_512 = U512::from(a);
        let b_512 = U512::from(b);
        let c_512 = U512::from(c);
        let res = a_512 + b_512;
        let x = res % c_512;
        U256::try_from(x).expect("U512 % U256 fits U256; qed")
    };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}


fn native_mul_mod(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let c = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let b = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let a = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    let n = if c.is_zero() {
        U256::zero()
    } else {
        let a_512 = U512::from(a);
        let b_512 = U512::from(b);
        let c_512 = U512::from(c);
        let res = a_512 * b_512;
        let x = res % c_512;
        U256::try_from(x).expect("U512 % U256 fits U256; qed")
    };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&n))
    ])
}

fn native_sar(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let shift = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    const CONST_256: U256 = U256([256, 0, 0, 0]);
    const CONST_HIBIT: U256 = U256([0, 0, 0, 0x8000000000000000]);

    let sign = value & CONST_HIBIT != U256::zero();
    let result = if shift >= CONST_256 {
        if sign {
            U256::max_value()
        } else {
            U256::zero()
        }
    } else {
        let shift = shift.as_u32() as usize;
        let mut shifted = value >> shift;
        if sign {
            shifted = shifted | (U256::max_value() << (256 - shift));
        }
           shifted
     };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&result))
    ])
}

fn native_shr(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let shift = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));
    let value = move_u256_to_evm_u256(&safely_pop_arg!(args, move_u256));

    const CONST_256: U256 = U256([256, 0, 0, 0]);

    let result = if shift >= CONST_256 {
        U256::zero()
    } else {
        value >> (shift.as_u32() as usize)
    };

    Ok(smallvec![
        Value::u256(evm_u256_to_move_u256(&result))
    ])
}

fn native_bit_length(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    let bytes = safely_pop_arg!(args, Vec<u8>);
    let big_int = BigUint::from_bytes_be(&bytes);
    Ok(smallvec![Value::u256(move_u256::from(big_int.bits() as u64))])
}

fn native_mod_exp(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    const BITS_PER_DIGIT: usize = 8;
    let m_bytes = safely_pop_arg!(args, Vec<u8>);
    let e_bytes = safely_pop_arg!(args, Vec<u8>);
    let b_bytes = safely_pop_arg!(args, Vec<u8>);

    let modulus = BigUint::from_bytes_be(&m_bytes);
    let mut base = BigUint::from_bytes_be(&b_bytes);
    if modulus <= BigUint::one() {
        return Ok(smallvec![Value::vector_u8(BigUint::to_bytes_be(&BigUint::zero()))])
    }

    let mut exp = e_bytes.into_iter().skip_while(|d| *d == 0).peekable();
    if exp.peek().is_none() {
        return Ok(smallvec![Value::vector_u8(BigUint::to_bytes_be(&BigUint::one()))])
    }

    if base.is_zero() {
        return Ok(smallvec![Value::vector_u8(BigUint::to_bytes_be(&BigUint::zero()))])
    }

    base %= &modulus;

    if base.is_zero() {
        return Ok(smallvec![Value::vector_u8(BigUint::to_bytes_be(&BigUint::zero()))])
    }

    let mut result = BigUint::one();
    for digit in exp {
        let mut mask = 1 << (BITS_PER_DIGIT - 1);

        for _ in 0..BITS_PER_DIGIT {
            result = &result * &result % &modulus;

            if digit & mask > 0 {
                result = result * &base % &modulus;
            }

            mask >>= 1;
        }
    }

    Ok(smallvec![
        Value::vector_u8(BigUint::to_bytes_be(&result))
    ])
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

/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("add", native_add as RawSafeNative),
        ("mul", native_mul as RawSafeNative),
        ("sub", native_sub as RawSafeNative),
        ("div", native_div as RawSafeNative),
        ("mod", native_mod as RawSafeNative),
        ("sdiv", native_sdiv as RawSafeNative),
        ("smod", native_smod as RawSafeNative),
        ("exp", native_exp as RawSafeNative),
        ("slt", native_slt as RawSafeNative),
        ("sgt", native_sgt as RawSafeNative),
        ("sar", native_sar as RawSafeNative),
        ("shr", native_shr as RawSafeNative),
        ("add_mod", native_add_mod as RawSafeNative),
        ("mul_mod", native_mul_mod as RawSafeNative),
        ("mod_exp", native_mod_exp as RawSafeNative),
        ("bit_length", native_bit_length as RawSafeNative),
        ("bn128_add", native_bn128_add as RawSafeNative),
        ("bn128_mul", native_bn128_mul as RawSafeNative),
        ("bn128_pairing", native_bn128_pairing as RawSafeNative),
        ("blake_2f", native_blake_2f as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}