use primitive_types::{U256, U512};

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

pub fn sdiv(a: U256, b: U256) -> U256 {
    let (a, sign_a) = get_and_reset_sign(a);
    let (b, sign_b) = get_and_reset_sign(b);
    let min = (U256::one() << 255) - U256::one();

    if b.is_zero() {
        U256::zero()
    } else if a == min && b == !U256::zero() {
        min
    } else {
        let c = a / b;
        set_sign(c, sign_a ^ sign_b)
    }
}

pub fn smod(ua: U256, ub: U256) -> U256 {
    let (a, sign_a) = get_and_reset_sign(ua);
    let b = get_and_reset_sign(ub).0;

    if b.is_zero() {
        U256::zero()
    } else {
        let c = a % b;
        set_sign(c, sign_a)
    }
}

pub fn addmod(a: U256, b: U256, c:U256) -> U256 {
    if c.is_zero() {
        U256::zero()
    } else {
        let a_512 = U512::from(a);
        let b_512 = U512::from(b);
        let c_512 = U512::from(c);
        let res = a_512 + b_512;
        let x = res % c_512;
        U256::try_from(x).expect("U512 % U256 fits U256; qed")
    }
}

pub fn mulmod(a: U256, b: U256, c:U256) -> U256 {
    if c.is_zero() {
        U256::zero()
    } else {
        let a_512 = U512::from(a);
        let b_512 = U512::from(b);
        let c_512 = U512::from(c);
        let res = a_512 * b_512;
        let x = res % c_512;
        U256::try_from(x).expect("U512 % U256 fits U256; qed")
    }
}

pub fn signextend(op1: U256, op2: U256) -> U256 {
	if op1 < U256::from(32) {
		// `low_u32` works since op1 < 32
		let bit_index = (8 * op1.low_u32() + 7) as usize;
		let bit = op2.bit(bit_index);
		let mask = (U256::one() << bit_index) - U256::one();
		if bit {
			op2 | !mask
		} else {
			op2 & mask
		}
	} else {
		op2
	}
}

pub fn slt(a: U256, b: U256) -> U256 {
    let (a, neg_a) = get_and_reset_sign(a);
    let (b, neg_b) = get_and_reset_sign(b);

    let is_positive_lt = a < b && !(neg_a | neg_b);
    let is_negative_lt = a > b && (neg_a & neg_b);
    let has_different_signs = neg_a && !neg_b;

    if is_positive_lt | is_negative_lt | has_different_signs {
        U256::one()
    } else {
        U256::zero()
    }
}

pub fn sgt(a: U256, b: U256) -> U256 {
    let (a, neg_a) = get_and_reset_sign(a);
    let (b, neg_b) = get_and_reset_sign(b);

    let is_positive_gt = a > b && !(neg_a | neg_b);
    let is_negative_gt = a < b && (neg_a & neg_b);
    let has_different_signs = !neg_a && neg_b;

    if is_positive_gt | is_negative_gt | has_different_signs {
        U256::one()
    } else {
        U256::zero()
    }
}

pub fn shl(shift: U256, value: U256) -> U256 {
	if value == U256::zero() || shift >= U256::from(256) {
		U256::zero()
	} else {
		let shift: u64 = shift.as_u64();
		value << shift as usize
	}
}

pub fn shr(shift: U256, value: U256) -> U256 {
	if value == U256::zero() || shift >= U256::from(256) {
		U256::zero()
	} else {
		let shift: u64 = shift.as_u64();
		value >> shift as usize
	}
}

pub fn sar(shift: U256, value: U256) -> U256 {
	const CONST_256: U256 = U256([256, 0, 0, 0]);
    const CONST_HIBIT: U256 = U256([0, 0, 0, 0x8000000000000000]);

    let sign = value & CONST_HIBIT != U256::zero();
    if shift >= CONST_256 {
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
     }
}

pub fn byte(op1: U256, op2: U256) -> U256 {
	let mut ret = U256::zero();

	for i in 0..256 {
		if i < 8 && op1 < 32.into() {
			let o: usize = op1.as_usize();
			let t = 255 - (7 - i + 8 * o);
			let bit_mask = U256::one() << t;
			let value = (op2 & bit_mask) >> t;
			ret = ret.overflowing_add(value << i).0;
		}
	}

	ret
}
