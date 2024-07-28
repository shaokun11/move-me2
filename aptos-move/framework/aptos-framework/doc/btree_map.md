
<a id="0x1_btree_map"></a>

# Module `0x1::btree_map`



-  [Struct `Node`](#0x1_btree_map_Node)
-  [Struct `BTreeMap`](#0x1_btree_map_BTreeMap)
-  [Constants](#@Constants_0)
-  [Function `new`](#0x1_btree_map_new)
-  [Function `insert_recursive`](#0x1_btree_map_insert_recursive)
-  [Function `find`](#0x1_btree_map_find)
-  [Function `contains_key`](#0x1_btree_map_contains_key)
-  [Function `add`](#0x1_btree_map_add)
-  [Function `upsert`](#0x1_btree_map_upsert)
-  [Function `borrow`](#0x1_btree_map_borrow)
-  [Function `borrow_mut`](#0x1_btree_map_borrow_mut)
-  [Function `is_empty`](#0x1_btree_map_is_empty)
-  [Function `to_vec_pair`](#0x1_btree_map_to_vec_pair)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="0x1_btree_map_Node"></a>

## Struct `Node`



<pre><code><b>struct</b> <a href="btree_map.md#0x1_btree_map_Node">Node</a>&lt;Value&gt; <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>left: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>right: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>key: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>value: Value</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_btree_map_BTreeMap"></a>

## Struct `BTreeMap`



<pre><code><b>struct</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt; <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>root: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>next_node_index: u64</code>
</dt>
<dd>

</dd>
<dt>
<code>data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="btree_map.md#0x1_btree_map_Node">btree_map::Node</a>&lt;Value&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_btree_map_EKEY_ALREADY_EXISTS"></a>

Map key already exists


<pre><code><b>const</b> <a href="btree_map.md#0x1_btree_map_EKEY_ALREADY_EXISTS">EKEY_ALREADY_EXISTS</a>: u64 = 1;
</code></pre>



<a id="0x1_btree_map_EKEY_NOT_FOUND"></a>

Map key is not found


<pre><code><b>const</b> <a href="btree_map.md#0x1_btree_map_EKEY_NOT_FOUND">EKEY_NOT_FOUND</a>: u64 = 2;
</code></pre>



<a id="0x1_btree_map_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_new">new</a>&lt;Value&gt;(): <a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_new">new</a>&lt;Value&gt;(): <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt; {
    <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a> {
        data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;<a href="btree_map.md#0x1_btree_map_Node">Node</a>&lt;Value&gt;&gt;(),
        root: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>(),
        next_node_index: 0,
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_insert_recursive"></a>

## Function `insert_recursive`



<pre><code><b>fun</b> <a href="btree_map.md#0x1_btree_map_insert_recursive">insert_recursive</a>&lt;Value&gt;(node_index: u64, new_node_index: u64, tree: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="btree_map.md#0x1_btree_map_insert_recursive">insert_recursive</a>&lt;Value&gt;(node_index: u64, new_node_index: u64, tree: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;) {
    <b>let</b> key = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&tree.data, new_node_index).key;
    <b>let</b> node = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> tree.data, node_index);

    <b>if</b>(key &lt; node.key) {
        <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_none">option::is_none</a>(&node.left)) {
            node.left = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_some">option::some</a>(new_node_index);
        } <b>else</b> {
            <b>let</b> left_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&node.left);
            <a href="btree_map.md#0x1_btree_map_insert_recursive">insert_recursive</a>(left_index, new_node_index, tree);
        }
    } <b>else</b> {
        <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_none">option::is_none</a>(&node.right)) {
            node.right = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_some">option::some</a>(new_node_index);
        } <b>else</b> {
            <b>let</b> right_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&node.right);
            <a href="btree_map.md#0x1_btree_map_insert_recursive">insert_recursive</a>(right_index, new_node_index, tree);
        }
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_find"></a>

## Function `find`



<pre><code><b>fun</b> <a href="btree_map.md#0x1_btree_map_find">find</a>&lt;Value&gt;(node_index: u64, key: u256, tree: &<a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="btree_map.md#0x1_btree_map_find">find</a>&lt;Value&gt;(node_index: u64, key: u256, tree: &<a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_Option">option::Option</a>&lt;u64&gt; {
    <b>let</b> node = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&tree.data, node_index);

    <b>if</b>(key == node.key) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_some">option::some</a>(node_index)
    } <b>else</b> <b>if</b>(key &lt; node.key) {
        <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_none">option::is_none</a>(&node.left)) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;()
        } <b>else</b> {
            <b>let</b> left_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&node.left);
            <a href="btree_map.md#0x1_btree_map_find">find</a>(left_index, key, tree)
        }
    } <b>else</b> {
        <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_none">option::is_none</a>(&node.right)) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;()
        } <b>else</b> {
            <b>let</b> right_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&node.right);
            <a href="btree_map.md#0x1_btree_map_find">find</a>(right_index, key, tree)
        }
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_contains_key"></a>

## Function `contains_key`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_contains_key">contains_key</a>&lt;Value&gt;(tree: &<a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;, key: u256): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_contains_key">contains_key</a>&lt;Value&gt;(tree: &<a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;, key: u256): bool {
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&tree.root)) {
        <b>let</b> root_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&tree.root);
        <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&<a href="btree_map.md#0x1_btree_map_find">find</a>(root_index, key, tree))
    } <b>else</b> {
        <b>false</b>
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_add"></a>

## Function `add`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_add">add</a>&lt;Value: <b>copy</b>, drop&gt;(tree: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;, key: u256, value: Value)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_add">add</a>&lt;Value: <b>copy</b> + drop&gt;(tree: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;, key: u256, value: Value) {
    <b>let</b> new_node = <a href="btree_map.md#0x1_btree_map_Node">Node</a> {
        key,
        value,
        left: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;(),
        right: <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;(),
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> tree.data, new_node);
    <b>let</b> new_node_index = tree.next_node_index;
    tree.next_node_index = tree.next_node_index + 1;

    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_none">option::is_none</a>(&tree.root)) {
        tree.root = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_some">option::some</a>(new_node_index);
    } <b>else</b> {
        <b>let</b> root_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&tree.root);
        <a href="btree_map.md#0x1_btree_map_insert_recursive">insert_recursive</a>(root_index, new_node_index, tree);
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_upsert"></a>

## Function `upsert`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_upsert">upsert</a>&lt;Value: <b>copy</b>, drop&gt;(map: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;, key: u256, value: Value)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_upsert">upsert</a>&lt;Value: <b>copy</b> + drop&gt;(map: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;, key: u256, value: Value) {
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&map.root)) {
        <b>let</b> root_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&map.root);
        <b>let</b> node_idx = <a href="btree_map.md#0x1_btree_map_find">find</a>(root_index, key, map);
        <b>if</b>(is_none(&node_idx)) {
            <a href="btree_map.md#0x1_btree_map_add">add</a>(map, key, value);
        } <b>else</b> {
            <b>let</b> node_idx = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> node_idx);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> map.data, node_idx).value = value;
        }
    } <b>else</b> {
        <a href="btree_map.md#0x1_btree_map_add">add</a>(map, key, value);
    }
}
</code></pre>



</details>

<a id="0x1_btree_map_borrow"></a>

## Function `borrow`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_borrow">borrow</a>&lt;Value: <b>copy</b>, drop&gt;(map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;, key: u256): &Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_borrow">borrow</a>&lt;Value: <b>copy</b> + drop&gt;(map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;, key: u256): &Value {
    <b>let</b> node_idx = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;();
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&map.root)) {
        <b>let</b> root_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&map.root);
        node_idx = <a href="btree_map.md#0x1_btree_map_find">find</a>(root_index, key, map);
    };
    <b>assert</b>!(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&node_idx), <a href="btree_map.md#0x1_btree_map_EKEY_NOT_FOUND">EKEY_NOT_FOUND</a>);

    <b>let</b> node_idx = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> node_idx);
    &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&map.data, node_idx).value
}
</code></pre>



</details>

<a id="0x1_btree_map_borrow_mut"></a>

## Function `borrow_mut`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_borrow_mut">borrow_mut</a>&lt;Value&gt;(map: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;, key: u256): &<b>mut</b> Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_borrow_mut">borrow_mut</a>&lt;Value&gt;(map: &<b>mut</b> <a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;, key: u256): &<b>mut</b> Value {
    <b>let</b> node_idx = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_none">option::none</a>&lt;u64&gt;();
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&map.root)) {
        <b>let</b> root_index = *<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_borrow">option::borrow</a>(&map.root);
        node_idx = <a href="btree_map.md#0x1_btree_map_find">find</a>(root_index, key, map);
    };
    <b>assert</b>!(<a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&node_idx), <a href="btree_map.md#0x1_btree_map_EKEY_NOT_FOUND">EKEY_NOT_FOUND</a>);

    <b>let</b> node_idx = <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_extract">option::extract</a>(&<b>mut</b> node_idx);
    &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> map.data, node_idx).value
}
</code></pre>



</details>

<a id="0x1_btree_map_is_empty"></a>

## Function `is_empty`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_is_empty">is_empty</a>&lt;Value&gt;(map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_is_empty">is_empty</a>&lt;Value&gt;(map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;): bool {
    <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option_is_some">option::is_some</a>(&map.root)
}
</code></pre>



</details>

<a id="0x1_btree_map_to_vec_pair"></a>

## Function `to_vec_pair`



<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_to_vec_pair">to_vec_pair</a>&lt;Value: <b>copy</b>, drop&gt;(map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">btree_map::BTreeMap</a>&lt;Value&gt;): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;Value&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="btree_map.md#0x1_btree_map_to_vec_pair">to_vec_pair</a>&lt;Value: <b>copy</b> + drop&gt;(
    map: &<a href="btree_map.md#0x1_btree_map_BTreeMap">BTreeMap</a>&lt;Value&gt;): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;Value&gt;) {
    <b>let</b> keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt; = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>();
    <b>let</b> values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;Value&gt; = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>();
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_for_each">vector::for_each</a>(map.data, |e| {
        <b>let</b> node: <a href="btree_map.md#0x1_btree_map_Node">Node</a>&lt;Value&gt; = e;
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> keys, node.key);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> values, node.value);
    });
    (keys, values)
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
