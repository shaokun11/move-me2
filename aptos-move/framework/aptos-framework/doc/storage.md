
<a id="0x1_evm_storage"></a>

# Module `0x1::evm_storage`



-  [Struct `TestAccount`](#0x1_evm_storage_TestAccount)
-  [Function `new_account`](#0x1_evm_storage_new_account)
-  [Function `exist_account`](#0x1_evm_storage_exist_account)
-  [Function `get_code`](#0x1_evm_storage_get_code)
-  [Function `get_nonce`](#0x1_evm_storage_get_nonce)
-  [Function `get_balance`](#0x1_evm_storage_get_balance)
-  [Function `get_storage`](#0x1_evm_storage_get_storage)
-  [Function `add_nonce`](#0x1_evm_storage_add_nonce)
-  [Function `set_storage`](#0x1_evm_storage_set_storage)
-  [Function `exist_contract`](#0x1_evm_storage_exist_contract)
-  [Function `sub_balance`](#0x1_evm_storage_sub_balance)
-  [Function `add_balance`](#0x1_evm_storage_add_balance)
-  [Function `transfer`](#0x1_evm_storage_transfer)
-  [Function `pre_init`](#0x1_evm_storage_pre_init)


<pre><code><b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
</code></pre>



<a id="0x1_evm_storage_TestAccount"></a>

## Struct `TestAccount`



<pre><code><b>struct</b> <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>balance: u256</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>nonce: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>storage: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_storage_new_account"></a>

## Function `new_account`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_new_account">new_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_new_account">new_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(trie, contract_addr, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a> {
        balance,
        <a href="code.md#0x1_code">code</a>,
        nonce,
        storage: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;(),
    })
}
</code></pre>



</details>

<a id="0x1_evm_storage_exist_account"></a>

## Function `exist_account`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): bool {
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(trie, &<b>address</b>)
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_code"></a>

## Function `get_code`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_code">get_code</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_code">get_code</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(trie, &contract_addr)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(trie, &contract_addr).<a href="code.md#0x1_code">code</a>
    } <b>else</b> {
        x""
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_nonce"></a>

## Function `get_nonce`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_nonce">get_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_nonce">get_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): u256 {
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(trie, &contract_addr)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(trie, &contract_addr).nonce
    } <b>else</b> {
        0
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_balance"></a>

## Function `get_balance`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_balance">get_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_balance">get_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): u256 {
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(trie, &contract_addr)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(trie, &contract_addr).balance
    } <b>else</b> {
        0
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_get_storage"></a>

## Function `get_storage`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_storage">get_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_get_storage">get_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): u256 {
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(trie, &contract_addr)) {
        <b>return</b> 0
    };
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(trie, &contract_addr);
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&<a href="account.md#0x1_account">account</a>.storage, &key)) {
        *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>( &<a href="account.md#0x1_account">account</a>.storage, &key)
    } <b>else</b> {
        0
    }
}
</code></pre>



</details>

<a id="0x1_evm_storage_add_nonce"></a>

## Function `add_nonce`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_add_nonce">add_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_add_nonce">add_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <b>let</b> <a href="account.md#0x1_account">account</a> =  <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.nonce = <a href="account.md#0x1_account">account</a>.nonce + 1;
}
</code></pre>



</details>

<a id="0x1_evm_storage_set_storage"></a>

## Function `set_storage`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_set_storage">set_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_set_storage">set_storage</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <b>let</b> <a href="account.md#0x1_account">account</a> =  <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(trie, &contract_addr);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(&<b>mut</b> <a href="account.md#0x1_account">account</a>.storage, key, value);
    // <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(trie, contract_addr, *<a href="account.md#0x1_account">account</a>);
    // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&<a href="account.md#0x1_account">account</a>.storage);
}
</code></pre>



</details>

<a id="0x1_evm_storage_exist_contract"></a>

## Function `exist_contract`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_contract">exist_contract</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_exist_contract">exist_contract</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;): bool {
    <b>if</b>(<a href="storage.md#0x1_evm_storage_exist_account">exist_account</a>(contract_addr, trie)) {
        <b>let</b> <a href="account.md#0x1_account">account</a> =  <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(trie, &contract_addr);
        <b>return</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>) &gt; 0
    };

    <b>false</b>
}
</code></pre>



</details>

<a id="0x1_evm_storage_sub_balance"></a>

## Function `sub_balance`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_sub_balance">sub_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_sub_balance">sub_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(trie, &contract_addr);
    <b>assert</b>!(<a href="account.md#0x1_account">account</a>.balance &gt;= amount, 2);
    <a href="account.md#0x1_account">account</a>.balance = <a href="account.md#0x1_account">account</a>.balance - amount;
}
</code></pre>



</details>

<a id="0x1_evm_storage_add_balance"></a>

## Function `add_balance`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_add_balance">add_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_add_balance">add_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.balance = <a href="account.md#0x1_account">account</a>.balance + amount;
}
</code></pre>



</details>

<a id="0x1_evm_storage_transfer"></a>

## Function `transfer`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;) {
    <a href="storage.md#0x1_evm_storage_sub_balance">sub_balance</a>(from, amount, trie);
    <b>if</b>(!<a href="storage.md#0x1_evm_storage_exist_account">exist_account</a>(<b>to</b>, trie)) {
        <a href="storage.md#0x1_evm_storage_new_account">new_account</a>(<b>to</b>, 0, x"", 0, trie);
    };
    <a href="storage.md#0x1_evm_storage_add_balance">add_balance</a>(<b>to</b>, amount, trie);
}
</code></pre>



</details>

<a id="0x1_evm_storage_pre_init"></a>

## Function `pre_init`



<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u64&gt;, balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="storage.md#0x1_evm_storage_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
             codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
             nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u64&gt;,
             balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt; {
    <b>let</b> trie = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a>&gt;();
    <b>let</b> pre_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&addresses);
    <b>let</b> i = 0;
    <b>while</b>(i &lt; pre_len) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> trie, to_32bit(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&addresses, i)), <a href="storage.md#0x1_evm_storage_TestAccount">TestAccount</a> {
            balance: to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&balances, i)),
            <a href="code.md#0x1_code">code</a>: *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&codes, i),
            nonce: (*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&nonces, i) <b>as</b> u256),
            storage: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;(),
        });
        i = i + 1;
    };
    trie
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
