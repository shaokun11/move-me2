use aptos_native_interface::{
    RawSafeNative, SafeNativeBuilder, SafeNativeContext, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value, Struct}
};
use move_binary_format::errors::PartialVMError;
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::VecDeque;
use smallvec::{smallvec, SmallVec};
use move_core_types::{
    language_storage::{TypeTag, StructTag},
    account_address::AccountAddress,
    effects::Op,
};

use better_any::{Tid, TidAble};
use std::{
    collections::{BTreeMap},
};

#[derive(Clone)]
pub struct Object {
    struct_tag: StructTag,
    op: Op<Vec<u8>>
}

impl Object {
    pub fn get_tag(self) -> StructTag {
        self.struct_tag
    }

    pub fn get_op(self) -> Op<Vec<u8>> {
        self.op
    }
}

pub struct ObjectChangeSet {
    pub changes: BTreeMap<AccountAddress, Object>,
}

#[derive(Default, Tid)]
pub struct NativeObjectContext {
    objects: BTreeMap<AccountAddress, Object>
}

impl NativeObjectContext {
    pub fn into_change_set(self) -> ObjectChangeSet  {
        ObjectChangeSet { changes: self.objects }
    }
}

pub fn get_object_id(object: Value) -> Result<Value, PartialVMError> {
    get_nested_struct_field(object, &[0, 0, 0])
}

// Extract a field valye that's nested inside value `v`. The offset of each nesting
// is determined by `offsets`.
pub fn get_nested_struct_field(mut v: Value, offsets: &[usize]) -> Result<Value, PartialVMError> {
    for offset in offsets {
        v = get_nth_struct_field(v, *offset)?;
    }
    Ok(v)
}

pub fn get_nth_struct_field(v: Value, n: usize) -> Result<Value, PartialVMError> {
    let mut itr = v.value_as::<Struct>()?.unpack()?;
    Ok(itr.nth(n).unwrap())
}

fn native_share_object_impl(
    context: &mut SafeNativeContext,
    mut ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    // let obj = args.pop_back().unwrap();
    let obj = args.pop_back().unwrap();
    let id: AccountAddress = get_object_id(obj.copy_value()?)?
            .value_as::<AccountAddress>()?
            .into();
    println!("object id: {:?}", id);

    // context.
    let ty = ty_args.pop().unwrap();
    let ty_layout = context.type_to_type_layout(&ty)?;
    let ty_tag = context.type_to_type_tag(&ty)?;


    let (exists, num_bytes) = context.exists_at(id, &ty).unwrap();
    println!("exist {:?} {:?}", exists, num_bytes);

    let blob = obj.simple_serialize(&ty_layout).unwrap();

    if let TypeTag::Struct(struct_tag) = ty_tag {
        println!("object type tag: {:?}", struct_tag);
        let ctx = context.extensions_mut().get_mut::<NativeObjectContext>();
        ctx.objects.insert(id, Object {
            struct_tag: *struct_tag,
            op: Op::New(blob)
        });
    } else {
        println!("not a struct");
    }

    Ok(smallvec![])
}


/***************************************************************************************************
 * module
 *
 **************************************************************************************************/
pub fn make_all(
    builder: &SafeNativeBuilder,
) -> impl Iterator<Item = (String, NativeFunction)> + '_ {
    let natives = [
        ("share_object_impl", native_share_object_impl  as RawSafeNative)
    ];

    builder.make_named_natives(natives)
}