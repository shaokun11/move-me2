use crate::natives::evm_natives::{
    helpers::{move_u256_to_evm_u256, evm_u256_to_move_u256}
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
    ];

    builder.make_named_natives(natives)
}