// module aptos_std::btree_map {
//     use std::vector;
//     use std::option::{Self, Option};
//
//     struct Node<Value> {
//         keys: vector<u256>,
//         values: vector<Value>,
//         children: vector<u64>,
//     }
//
//     struct BTreeMap<Value> {
//         data: vector<Node<Value>>,
//         root: Option<u64>, // Use index to refer to root node
//         degree: u64,
//         next_node_index: u64, // Track the next available node index
//     }
//
//     public fun new<Value>(degree: u64): BTreeMap<Value> {
//         BTreeMap {
//             data: vector::empty<Node<Value>>(),
//             root: option::none(),
//             degree,
//             next_node_index: 0,
//         }
//     }
//
//     public fun insert<Value>(map: &mut BTreeMap<Value>, key: u256, value: Value) {
//         if (option::is_none(&map.root)) {
//             let root = Node {
//                 keys: vector::empty<u256>(),
//                 values: vector::empty<Value>(),
//                 children: vector::empty<u64>(),
//             };
//             vector::push_back(&mut root.keys, key);
//             vector::push_back(&mut root.values, value);
//             let root_index = map.next_node_index;
//             map.next_node_index = map.next_node_index + 1;
//             vector::push_back(&mut map.data, root);
//             map.root = option::some(root_index);
//         } else {
//             let root_index = option::extract(&mut map.root);
//             let root = vector::borrow(&map.data, root_index);
//             if(vector::length(&root.keys) == 2 * map.degree - 1) {
//                 // Root is full, need to split
//                 let new_root = Node {
//                     keys: vector::empty<u256>(),
//                     values: vector::empty<Value>(),
//                     children: vector::empty<u64>(),
//                 };
//                 let new_root_index = map.next_node_index;
//                 map.next_node_index = map.next_node_index + 1;
//                 vector::push_back(&mut map.data, new_root);
//                 vector::push_back(&mut new_root.children, root_index);
//                 split_child(&mut new_root, 0, root_index, map);
//                 map.root = option::some(new_root_index);
//                 insert_non_full(new_root_index, key, value, map);
//             }
//         }
//     }
//
//     fun split_child<Value>(parent: &mut Node<Value>, i: u64, full_child_index: u64, map: &mut BTreeMap<Value>) {
//         let degree = map.degree;
//         let full_child = vector::borrow(&map.data, full_child_index);
//         let new_child = Node {
//             keys: vector::empty<u256>(),
//             values: vector::empty<Value>(),
//             children: vector::empty<u64>(),
//         };
//
//         let new_child_index = map.next_node_index;
//         map.next_node_index = map.next_node_index + 1;
//
//         vector::
//
//         let j = 0;
//         while(j < degree) {
//             vector::push_back(&mut new_child.keys, *vector::borrow(&full_child.keys, degree + j));
//             vector::push_back(&mut new_child.values, *vector::borrow(&full_child.values, degree + j));
//         };
//
//         if (vector::length(&full_child.children) > 0) {
//             j = 0;
//             while (j <)
//         for j in 0..degree {
//         vector::push_back(&mut new_child.children, *vector::borrow(&full_child.children, degree + j));
//         }
//         }
//
//         storage::store(new_child_index, new_child);
//
//         vector::push_back(&mut parent.children, new_child_index);
//         for j in (i+1..vector::length(&parent.children)).rev() {
//         *vector::borrow_mut(&mut parent.children, j) = *vector::borrow(&parent.children, j - 1);
//         }
//         *vector::borrow_mut(&mut parent.children, i + 1) = new_child_index;
//
//         vector::push_back(&mut parent.keys, *vector::borrow(&full_child.keys, degree - 1));
//         vector::push_back(&mut parent.values, *vector::borrow(&full_child.values, degree - 1));
//         for j in (i..vector::length(&parent.keys)).rev() {
//         *vector::borrow_mut(&mut parent.keys, j) = *vector::borrow(&parent.keys, j - 1);
//         *vector::borrow_mut(&mut parent.values, j) = *vector::borrow(&parent.values, j - 1);
//         }
//         *vector::borrow_mut(&mut parent.keys, i) = *vector::borrow(&full_child.keys, degree - 1);
//         *vector::borrow_mut(&mut parent.values, i) = *vector::borrow(&full_child.values, degree - 1);
//
//         vector::truncate(&mut full_child.keys, degree - 1);
//         vector::truncate(&mut full_child.values, degree - 1);
//         if (vector::length(&full_child.children) > 0) {
//         vector::truncate(&mut full_child.children, degree);
//         }
//     }
// }