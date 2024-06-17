use move_binary_format::errors::PartialVMError;
use aptos_types::{vm_status::StatusCode};
use aptos_native_interface::{
    safely_pop_arg, SafeNativeContext, SafeNativeError, SafeNativeBuilder, RawSafeNative, SafeNativeResult
};
use move_vm_types::{
    loaded_data::runtime_types::Type,
    values::{Value, StructRef, Struct}
};
use move_core_types::{u256::U256 as move_u256};
use move_vm_runtime::native_functions::NativeFunction;
use std::collections::{VecDeque, HashMap};
use smallvec::{smallvec, SmallVec};
use ethers::types::{Transaction};
use ethers::utils::keccak256;
use ethers::utils::rlp::{encode, RlpStream, Decodable, Encodable};
use ethers::types::{U256, U512, H160, H256, Address};
use hex;
use trie;
use ethers::abi::AbiEncode;

#[derive(Debug, Clone)]
struct Account {
    nonce: U256,
    balance: U256,
    storage_root: H256,
    code: Vec<u8>,
}

impl Account {
    fn rlp_encode(&self) -> Vec<u8> {
        let mut stream = RlpStream::new_list(4);
        let code_hash = keccak256(&self.code).to_vec();
        stream.append(&self.nonce);
        stream.append(&self.balance);
        stream.append(&self.storage_root);
        stream.append(&code_hash);
        stream.out().to_vec()
    }
}

fn convert_u256(value: &move_u256) -> U256 {
    U256::from_little_endian(&value.to_le_bytes())
}

fn calculate_storage_root(storage: Struct) -> H256 {
    let mut datas: Vec<Value> = unpack_simple_map(storage);
    println!("datas: {:?}", datas);
    let mut m = HashMap::new();
    for data in datas {
        let mut content = data.value_as::<Struct>().unwrap().unpack().unwrap().collect::<Vec<_>>();
        let value = content.pop().map(|v| {
            v.value_as::<move_u256>().unwrap()
        }).unwrap();
        let key = content.pop().map(|v| {
            v.value_as::<move_u256>().unwrap()
        }).unwrap();

        let key_u256 = convert_u256(&key);
        let value_u256 = convert_u256(&value);
        let value_rlp_bytes = value_u256.rlp_bytes().to_vec();

        m.insert(keccak256(key_u256.encode()).to_vec(), value_rlp_bytes);
    }

    H256::from_slice(&trie::build(&m).0)
}

fn unpack_simple_map(simple_map: Struct) -> Vec<Value> {
    let mut datas: Vec<Value> = simple_map.unpack().unwrap().collect();
    datas.pop().map(|v| {
            v.value_as::<Vec<Value>>().unwrap()
        }).unwrap()
}

fn unpack_account(account_data: Struct) -> Account  {
    let mut fields: Vec<Value> = account_data.unpack().unwrap().collect();

    let storage = fields.pop().map(|v| {
            v.value_as::<Struct>().unwrap()
        }).unwrap();
    let storage_root = calculate_storage_root(storage);
    let nonce = fields.pop().map(|v| {
            v.value_as::<move_u256>().unwrap()
        }).unwrap();
    let code = fields.pop().map(|v| {
            v.value_as::<Vec<u8>>().unwrap()
        }).unwrap();
    let balance = fields.pop().map(|v| {
            v.value_as::<move_u256>().unwrap()
        }).unwrap();

    println!("storage: {:?}", storage_root);
    println!("nonce: {:?}", nonce);
    println!("code: {:?}", code);
    println!("balance: {:?}", balance);

    Account {
        nonce: convert_u256(&nonce),
        code,
        balance: convert_u256(&balance),
        storage_root
    }
}

// fn unpack(v: Value) {
//     let content = v
//         .value_as::<Struct>();
//     println!("content: {:?}", content);
// }

fn native_calculate_root(
    _context: &mut SafeNativeContext,
    _ty_args: Vec<Type>,
    mut args: VecDeque<Value>,
) -> SafeNativeResult<SmallVec<[Value; 1]>> {
    debug_assert!(_ty_args.is_empty());
    let state = safely_pop_arg!(args, Struct);

    let datas = unpack_simple_map(state);
    println!("len: {:?}", datas.len());
    let len = datas.len();

    let mut root_map = HashMap::new();

    for data in datas {
        let mut content = data.value_as::<Struct>().unwrap().unpack().unwrap().collect::<Vec<_>>();
        let account_data = content.pop().map(|v| {
            v.value_as::<Struct>().unwrap()
        }).unwrap();
        let address = content.pop().map(|v| {
            v.value_as::<Vec<u8>>().unwrap()
        }).unwrap();

        let hashed_addr = keccak256(&address[12..]);
        println!("hashed1: {:?}", hashed_addr);

        let account = unpack_account(account_data);
        println!("hashed2: {:?}", hex::encode(hashed_addr));
        println!("account: {:?} {:?}", account, hex::encode(account.rlp_encode()));
        root_map.insert(hashed_addr.to_vec(), account.rlp_encode());
        // println!("account: {:?}", account);

        // let 
        // let account = accounts[i];
        // let content = accounts[i].value_as::<Struct>().unwrap();
        // println!("content: {:?}", content);
        // let key = element.pop().map(|v| {
        //     v.value_as::<Struct>().unwrap()
        // }).unwrap();
        // let value = element.pop().map(|v| {
        //     v.value_as::<Struct>().unwrap()
        // }).unwrap();
        // let t2: Vec<Value> = content.unpack().unwrap().collect();
        
        // println!("t2: {:?}", t2);
    };

    println!("State Root: {:?}", H256::from_slice(&trie::build(&root_map).0));
    // accounts.iter_mut().for_each(|element| {
    //     // println!("data: {:?}", element);
    //     // let content = data.unpack()?.collect();
    //     // let content = element.unpack()?.collect();
    //     let key = element.pop().map(|v| {
    //         v.value_as::<Struct>().unwrap()
    //     }).unwrap();
        // let value = element.pop().map(|v| {
        //     v.value_as::<Struct>().unwrap()
        // }).unwrap();
        // println!("key: {:?}", key);
        // println!("value: {:?}", value);

    //     let key_content: Vec<Value> = key.unpack().expect("unpack key error").collect();
    //     let value_content: Vec<Value> = value.unpack().expect("unpack value error").collect();
    //     println!("key_content: {:?}", key_content);
    //     println!("value_content: {:?}", value_content);
    //     // let address = 
    //     // contracts.push(Account {
    //     //     address: 
    //     // })
    // });
    

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
        ("calculate_root", native_calculate_root as RawSafeNative),
    ];

    builder.make_named_natives(natives)
}