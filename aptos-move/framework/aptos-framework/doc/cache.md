
<a id="0x1_evm_cache"></a>

# Module `0x1::evm_cache`



-  [Function `new_cache`](#0x1_evm_cache_new_cache)
-  [Function `is_cold_address`](#0x1_evm_cache_is_cold_address)
-  [Function `get_cache`](#0x1_evm_cache_get_cache)
-  [Function `put`](#0x1_evm_cache_put)


<pre><code><b>use</b> <a href="storage.md#0x1_evm_storage">0x1::evm_storage</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
</code></pre>



<a id="0x1_evm_cache_new_cache"></a>

## Function `new_cache`



<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_new_cache">new_cache</a>(): <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_new_cache">new_cache</a>(): SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt; {
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;()
}
</code></pre>



</details>

<a id="0x1_evm_cache_is_cold_address"></a>

## Function `is_cold_address`



<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;): bool {
    <b>let</b> is_cold = !<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(cache, &<b>address</b>);
    <b>if</b>(is_cold) {
        <b>let</b> map = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;();
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(cache, <b>address</b>, map);
    };

    is_cold
}
</code></pre>



</details>

<a id="0x1_evm_cache_get_cache"></a>

## Function `get_cache`



<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): (bool, bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="cache.md#0x1_evm_cache_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, TestAccount&gt;): (bool, bool, u256) {
    <b>let</b> is_cold_address = <b>false</b>;
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(cache, &<b>address</b>)) {
        <b>let</b> storage = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(cache, &<b>address</b>);
        <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(storage, &key)) {
            <b>return</b> (<b>false</b>, <b>false</b>, *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(storage, &key))
        }
    } <b>else</b> {
        is_cold_address = <b>true</b>;
    };

    <b>let</b> value = get_storage(<b>address</b>, key, trie);
    <a href="cache.md#0x1_evm_cache_put">put</a>(<b>address</b>, key, value, cache);

    (is_cold_address, <b>true</b>, value)
}
</code></pre>



</details>

<a id="0x1_evm_cache_put"></a>

## Function `put`



<pre><code><b>fun</b> <a href="cache.md#0x1_evm_cache_put">put</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="cache.md#0x1_evm_cache_put">put</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;) {
    <b>let</b> map;
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(cache, &<b>address</b>)) {
        map = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;();
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(cache, <b>address</b>, map);
    } <b>else</b> {
        map = *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(cache, &<b>address</b>);
    };

    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(&<b>mut</b> map, key, value);
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
