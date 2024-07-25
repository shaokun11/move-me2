module aptos_framework::btree_map {
    use std::vector;
    use std::option::{Self, Option, is_none};

    /// Map key already exists
    const EKEY_ALREADY_EXISTS: u64 = 1;
    /// Map key is not found
    const EKEY_NOT_FOUND: u64 = 2;

    struct Node<Value> has copy, drop {
        left: option::Option<u64>,
        right: option::Option<u64>,
        key: u256,
        value: Value,
    }

    struct BTreeMap<Value> has copy, drop {
        root: Option<u64>,
        next_node_index: u64,
        data: vector<Node<Value>>
    }

    public fun new<Value>(): BTreeMap<Value> {
        BTreeMap {
            data: vector::empty<Node<Value>>(),
            root: option::none(),
            next_node_index: 0,
        }
    }

    fun insert_recursive<Value>(node_index: u64, new_node_index: u64, tree: &mut BTreeMap<Value>) {
        let key = vector::borrow(&tree.data, new_node_index).key;
        let node = vector::borrow_mut(&mut tree.data, node_index);

        if(key < node.key) {
            if(option::is_none(&node.left)) {
                node.left = option::some(new_node_index);
            } else {
                let left_index = *option::borrow(&node.left);
                insert_recursive(left_index, new_node_index, tree);
            }
        } else {
            if(option::is_none(&node.right)) {
                node.right = option::some(new_node_index);
            } else {
                let right_index = *option::borrow(&node.right);
                insert_recursive(right_index, new_node_index, tree);
            }
        }
    }

    fun find<Value>(node_index: u64, key: u256, tree: &BTreeMap<Value>): option::Option<u64> {
        let node = vector::borrow(&tree.data, node_index);

        if(key == node.key) {
            option::some(node_index)
        } else if(key < node.key) {
            if(option::is_none(&node.left)) {
                option::none<u64>()
            } else {
                let left_index = *option::borrow(&node.left);
                find(left_index, key, tree)
            }
        } else {
            if(option::is_none(&node.right)) {
                option::none<u64>()
            } else {
                let right_index = *option::borrow(&node.right);
                find(right_index, key, tree)
            }
        }
    }

    public fun contains_key<Value>(tree: &BTreeMap<Value>, key: u256): bool {
        if(option::is_some(&tree.root)) {
            let root_index = *option::borrow(&tree.root);
            option::is_some(&find(root_index, key, tree))
        } else {
            false
        }
    }

    public fun add<Value: copy + drop>(tree: &mut BTreeMap<Value>, key: u256, value: Value) {
        let new_node = Node {
            key,
            value,
            left: option::none<u64>(),
            right: option::none<u64>(),
        };
        vector::push_back(&mut tree.data, new_node);
        let new_node_index = tree.next_node_index;
        tree.next_node_index = tree.next_node_index + 1;

        if(option::is_none(&tree.root)) {
            tree.root = option::some(new_node_index);
        } else {
            let root_index = *option::borrow(&tree.root);
            insert_recursive(root_index, new_node_index, tree);
        }
    }

    // public fun remove<Value: copy + drop>()

    fun find_min<Value: copy + drop>(node_index: u64, tree: &mut BTreeMap<Value>): (u64, u256, Value) {
        let current_index = node_index;
        let current = vector::borrow(&tree.data, current_index);
        while(option::is_some(&current.left)) {
            current_index = *option::borrow(&current.left);
            current = vector::borrow(&tree.data, current_index);
        };
        (current_index, current.key, current.value)
    }

    fun remove_recursive<Value: copy + drop>(node_option: Option<u64>, key: u256, tree: &mut BTreeMap<Value>): option::Option<u64> {
        if(option::is_some(&node_option)) {
            let node_index = *option::borrow(&node_option);
            let node = &mut *vector::borrow_mut(&mut tree.data, node_index);
            if(key < node.key) {
                let left = remove_recursive(node.left, key, tree);
                node.left = left;
                option::some(node_index)
            } else if(key > node.key) {
                let right = remove_recursive(node.right, key, tree);
                node.right = right;
                option::some(node_index)
            } else {
                if(option::is_none(&node.left)) {
                    node.right
                } else if(option::is_none(&node.right)) {
                    node.left
                } else {
                    let right_index = *option::borrow(&node.right);
                    let (_, min_key, min_value) = find_min(right_index, tree);
                    node.key = min_key;
                    node.value = min_value;
                    let right = remove_recursive(node.right, min_key, tree);
                    node.right = right;
                    option::some(node_index)
                }
            }
        } else {
            option::none<u64>()
        }

    }

    public fun remove<Value: copy + drop>(tree: &mut BTreeMap<Value>, key: u256) {
        let root = remove_recursive(tree.root, key, tree);
        tree.root = root;
    }

    public fun upsert<Value: copy + drop>(map: &mut BTreeMap<Value>, key: u256, value: Value) {
        if(option::is_some(&map.root)) {
            let root_index = *option::borrow(&map.root);
            let node_idx = find(root_index, key, map);
            if(is_none(&node_idx)) {
                add(map, key, value);
            } else {
                let node_idx = option::extract(&mut node_idx);
                vector::borrow_mut(&mut map.data, node_idx).value = value;
            }
        } else {
            add(map, key, value);
        }
    }

    public fun borrow<Value: copy + drop>(map: &BTreeMap<Value>, key: u256): &Value {
        let node_idx = option::none<u64>();
        if(option::is_some(&map.root)) {
            let root_index = *option::borrow(&map.root);
            node_idx = find(root_index, key, map);
        };
        assert!(option::is_some(&node_idx), EKEY_NOT_FOUND);

        let node_idx = option::extract(&mut node_idx);
        &vector::borrow(&map.data, node_idx).value
    }

    public fun borrow_mut<Value>(map: &mut BTreeMap<Value>, key: u256): &mut Value {
        let node_idx = option::none<u64>();
        if(option::is_some(&map.root)) {
            let root_index = *option::borrow(&map.root);
            node_idx = find(root_index, key, map);
        };
        assert!(option::is_some(&node_idx), EKEY_NOT_FOUND);

        let node_idx = option::extract(&mut node_idx);
        &mut vector::borrow_mut(&mut map.data, node_idx).value
    }

    public fun is_empty<Value>(map: &BTreeMap<Value>): bool {
        option::is_some(&map.root)
    }

    public fun to_vec_pair<Value: copy + drop>(
        map: &BTreeMap<Value>): (vector<u256>, vector<Value>) {
        let keys: vector<u256> = vector::empty();
        let values: vector<Value> = vector::empty();
        vector::for_each(map.data, |e| {
            let node: Node<Value> = e;
            vector::push_back(&mut keys, node.key);
            vector::push_back(&mut values, node.value);
        });
        (keys, values)
    }
}