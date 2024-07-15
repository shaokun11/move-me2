
<a id="0x1_evm_hash_map"></a>

# Module `0x1::evm_hash_map`



-  [Struct `HashMap`](#0x1_evm_hash_map_HashMap)
-  [Resource `Box`](#0x1_evm_hash_map_Box)
-  [Function `new`](#0x1_evm_hash_map_new)
-  [Function `new_map_handle`](#0x1_evm_hash_map_new_map_handle)
-  [Function `update`](#0x1_evm_hash_map_update)
-  [Function `keys`](#0x1_evm_hash_map_keys)
-  [Function `is_empty`](#0x1_evm_hash_map_is_empty)
-  [Function `contains`](#0x1_evm_hash_map_contains)
-  [Function `remove`](#0x1_evm_hash_map_remove)
-  [Function `borrow`](#0x1_evm_hash_map_borrow)


<pre><code></code></pre>



<a id="0x1_evm_hash_map_HashMap"></a>

## Struct `HashMap`

Type of HashMap


<pre><code><b>struct</b> <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K: <b>copy</b>, drop, V&gt; <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>handle: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_hash_map_Box"></a>

## Resource `Box`



<pre><code><b>struct</b> <a href="evm_hash_map.md#0x1_evm_hash_map_Box">Box</a>&lt;V&gt; <b>has</b> drop, store, key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>val: V</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_hash_map_new"></a>

## Function `new`

Create a new HashMap.


<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_new">new</a>&lt;K: <b>copy</b>, drop, V: store&gt;(): <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_new">new</a>&lt;K: <b>copy</b> + drop, V: store&gt;(): <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt; {
    <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a> {
        handle: <a href="evm_hash_map.md#0x1_evm_hash_map_new_map_handle">new_map_handle</a>&lt;K, V&gt;(),
    }
}
</code></pre>



</details>

<a id="0x1_evm_hash_map_new_map_handle"></a>

## Function `new_map_handle`



<pre><code><b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_new_map_handle">new_map_handle</a>&lt;K, V&gt;(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_new_map_handle">new_map_handle</a>&lt;K, V&gt;(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_hash_map_update"></a>

## Function `update`



<pre><code><b>public</b> <b>fun</b> <b>update</b>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<b>mut</b> <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;, key: K, val: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <b>update</b>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<b>mut</b> <a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;, key: K, val: V);
</code></pre>



</details>

<a id="0x1_evm_hash_map_keys"></a>

## Function `keys`



<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_keys">keys</a>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_keys">keys</a>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;K&gt;;
</code></pre>



</details>

<a id="0x1_evm_hash_map_is_empty"></a>

## Function `is_empty`



<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_is_empty">is_empty</a>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_is_empty">is_empty</a>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;): bool;
</code></pre>



</details>

<a id="0x1_evm_hash_map_contains"></a>

## Function `contains`



<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_contains">contains</a>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;, key: K): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_contains">contains</a>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;, key: K): bool;
</code></pre>



</details>

<a id="0x1_evm_hash_map_remove"></a>

## Function `remove`



<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_remove">remove</a>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;, key: K)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_remove">remove</a>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;, key: K);
</code></pre>



</details>

<a id="0x1_evm_hash_map_borrow"></a>

## Function `borrow`



<pre><code><b>public</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_borrow">borrow</a>&lt;K: <b>copy</b>, drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">evm_hash_map::HashMap</a>&lt;K, V&gt;, key: K): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="evm_hash_map.md#0x1_evm_hash_map_borrow">borrow</a>&lt;K: <b>copy</b> + drop, V: drop&gt;(map: &<a href="evm_hash_map.md#0x1_evm_hash_map_HashMap">HashMap</a>&lt;K, V&gt;, key: K): V;
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
