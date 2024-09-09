
<a id="0x1_evm_trie_v2"></a>

# Module `0x1::evm_trie_v2`



-  [Function `add_checkpoint`](#0x1_evm_trie_v2_add_checkpoint)
-  [Function `init_new_trie`](#0x1_evm_trie_v2_init_new_trie)
-  [Function `get_transient_storage`](#0x1_evm_trie_v2_get_transient_storage)
-  [Function `put_transient_storage`](#0x1_evm_trie_v2_put_transient_storage)
-  [Function `set_code`](#0x1_evm_trie_v2_set_code)
-  [Function `set_state`](#0x1_evm_trie_v2_set_state)
-  [Function `add_nonce`](#0x1_evm_trie_v2_add_nonce)
-  [Function `add_balance`](#0x1_evm_trie_v2_add_balance)
-  [Function `sub_balance`](#0x1_evm_trie_v2_sub_balance)
-  [Function `set_balance`](#0x1_evm_trie_v2_set_balance)
-  [Function `transfer`](#0x1_evm_trie_v2_transfer)
-  [Function `commit_latest_checkpoint`](#0x1_evm_trie_v2_commit_latest_checkpoint)
-  [Function `revert_checkpoint`](#0x1_evm_trie_v2_revert_checkpoint)
-  [Function `new_account`](#0x1_evm_trie_v2_new_account)
-  [Function `is_contract_or_created_account`](#0x1_evm_trie_v2_is_contract_or_created_account)
-  [Function `exist_contract`](#0x1_evm_trie_v2_exist_contract)
-  [Function `exist_account`](#0x1_evm_trie_v2_exist_account)
-  [Function `get_nonce`](#0x1_evm_trie_v2_get_nonce)
-  [Function `get_code`](#0x1_evm_trie_v2_get_code)
-  [Function `get_code_length`](#0x1_evm_trie_v2_get_code_length)
-  [Function `get_balance`](#0x1_evm_trie_v2_get_balance)
-  [Function `get_state`](#0x1_evm_trie_v2_get_state)
-  [Function `pre_init`](#0x1_evm_trie_v2_pre_init)
-  [Function `save`](#0x1_evm_trie_v2_save)
-  [Function `add_warm_address`](#0x1_evm_trie_v2_add_warm_address)
-  [Function `is_cold_address`](#0x1_evm_trie_v2_is_cold_address)
-  [Function `get_cache`](#0x1_evm_trie_v2_get_cache)


<pre><code><b>use</b> <a href="evm_context.md#0x1_evm_context">0x1::evm_context</a>;
<b>use</b> <a href="storage.md#0x1_evm_storage">0x1::evm_storage</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
</code></pre>



<a id="0x1_evm_trie_v2_add_checkpoint"></a>

## Function `add_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_checkpoint">add_checkpoint</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_checkpoint">add_checkpoint</a>() {
    <a href="evm_context.md#0x1_evm_context_push_substate">evm_context::push_substate</a>();
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_init_new_trie"></a>

## Function `init_new_trie`



<pre><code><b>public</b> <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_init_new_trie">init_new_trie</a>(access_list_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (u256, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_init_new_trie">init_new_trie</a>(access_list_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (u256, u256) {
    <b>let</b> iter = 0;
    <b>let</b> access_address_count = to_u256(vector_slice(access_list_bytes, iter, 8));
    <b>let</b> i = 0;
    iter = iter + 8;
    <b>let</b> access_slot_count = 0;
    <b>while</b> (i &lt; access_address_count) {
        <b>let</b> <b>address</b> = vector_slice(access_list_bytes, iter, 20);
        iter = iter + 20;
        <b>let</b> key_size = to_u256(vector_slice(access_list_bytes, iter, 8));
        iter = iter + 8;

        <b>let</b> j = 0;
        <b>while</b>(j &lt; key_size) {
            <b>let</b> key = to_u256(vector_slice(access_list_bytes, iter, 32));
            iter = iter + 32;
            <a href="evm_context.md#0x1_evm_context_add_always_hot_slot">evm_context::add_always_hot_slot</a>(<b>address</b>, key);
            j = j + 1;
            access_slot_count = access_slot_count + 1;
        };
        <a href="evm_context.md#0x1_evm_context_add_always_hot_address">evm_context::add_always_hot_address</a>(<b>address</b>);
        i = i + 1;
    };

    (access_address_count, access_slot_count)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_transient_storage"></a>

## Function `get_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_transient_storage">get_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_transient_storage">get_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256 {
    <a href="evm_context.md#0x1_evm_context_get_transient_storage">evm_context::get_transient_storage</a>(contract, key)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_put_transient_storage"></a>

## Function `put_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_put_transient_storage">put_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_put_transient_storage">put_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256) {
    <a href="evm_context.md#0x1_evm_context_set_transient_storage">evm_context::set_transient_storage</a>(contract, key, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_set_code"></a>

## Function `set_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <a href="evm_context.md#0x1_evm_context_set_code">evm_context::set_code</a>(contract, <a href="code.md#0x1_code">code</a>);
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_set_state"></a>

## Function `set_state`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_state">set_state</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_state">set_state</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256) {
    <a href="evm_context.md#0x1_evm_context_set_storage">evm_context::set_storage</a>(contract, key, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_add_nonce"></a>

## Function `add_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_nonce">add_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_nonce">add_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <a href="trie_v2.md#0x1_evm_trie_v2_get_nonce">get_nonce</a>(contract);
    <a href="evm_context.md#0x1_evm_context_inc_nonce">evm_context::inc_nonce</a>(contract)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_add_balance"></a>

## Function `add_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_balance">add_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_balance">add_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256) {
    <a href="trie_v2.md#0x1_evm_trie_v2_get_balance">get_balance</a>(contract);
    <a href="evm_context.md#0x1_evm_context_add_balance">evm_context::add_balance</a>(contract, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_sub_balance"></a>

## Function `sub_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_sub_balance">sub_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_sub_balance">sub_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256): bool {
    <a href="trie_v2.md#0x1_evm_trie_v2_get_balance">get_balance</a>(contract);
    <a href="evm_context.md#0x1_evm_context_sub_balance">evm_context::sub_balance</a>(contract, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_set_balance"></a>

## Function `set_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_balance">set_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_set_balance">set_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256) {
    <a href="trie_v2.md#0x1_evm_trie_v2_get_balance">get_balance</a>(contract);
    <a href="evm_context.md#0x1_evm_context_set_balance">evm_context::set_balance</a>(contract, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_transfer"></a>

## Function `transfer`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256): bool {
    <b>if</b>(amount &gt; 0) {
        <b>let</b> success = <a href="trie_v2.md#0x1_evm_trie_v2_sub_balance">sub_balance</a>(from, amount);
        <b>if</b>(success) {
            <a href="trie_v2.md#0x1_evm_trie_v2_add_balance">add_balance</a>(<b>to</b>, amount);
        };
        success
    } <b>else</b> {
        <b>true</b>
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_commit_latest_checkpoint"></a>

## Function `commit_latest_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_commit_latest_checkpoint">commit_latest_checkpoint</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_commit_latest_checkpoint">commit_latest_checkpoint</a>() {
    <a href="evm_context.md#0x1_evm_context_commit_substate">evm_context::commit_substate</a>()
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_revert_checkpoint"></a>

## Function `revert_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_revert_checkpoint">revert_checkpoint</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_revert_checkpoint">revert_checkpoint</a>() {
    <a href="evm_context.md#0x1_evm_context_revert_substate">evm_context::revert_substate</a>()
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_new_account"></a>

## Function `new_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_new_account">new_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_new_account">new_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, nonce: u256) {
    <b>if</b>(!<a href="trie_v2.md#0x1_evm_trie_v2_exist_account">exist_account</a>(contract)) {
        <a href="evm_context.md#0x1_evm_context_set_account">evm_context::set_account</a>(contract, balance, <a href="code.md#0x1_code">code</a>, nonce);
    } <b>else</b> {
        <a href="evm_context.md#0x1_evm_context_set_nonce">evm_context::set_nonce</a>(contract, 1);
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_is_contract_or_created_account"></a>

## Function `is_contract_or_created_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_is_contract_or_created_account">is_contract_or_created_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_is_contract_or_created_account">is_contract_or_created_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <b>if</b>(!<a href="trie_v2.md#0x1_evm_trie_v2_exist_account">exist_account</a>(contract)) {
        <b>false</b>
    } <b>else</b> {
        <a href="trie_v2.md#0x1_evm_trie_v2_get_code_length">get_code_length</a>(contract) &gt; 0 || <a href="trie_v2.md#0x1_evm_trie_v2_get_nonce">get_nonce</a>(contract) &gt; 0 || !<a href="evm_context.md#0x1_evm_context_storage_empty">evm_context::storage_empty</a>(contract)
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_exist_contract"></a>

## Function `exist_contract`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_exist_contract">exist_contract</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_exist_contract">exist_contract</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <b>if</b>(!<a href="trie_v2.md#0x1_evm_trie_v2_exist_account">exist_account</a>(contract)) {
        <b>false</b>
    } <b>else</b> {
        <a href="trie_v2.md#0x1_evm_trie_v2_get_code_length">get_code_length</a>(contract) &gt; 0
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_exist_account"></a>

## Function `exist_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <b>let</b> (exist_in_context, exist) = <a href="evm_context.md#0x1_evm_context_exist">evm_context::exist</a>(<b>address</b>);
    <b>if</b>(!exist_in_context) {
        <b>return</b> <a href="storage.md#0x1_evm_storage_exist_account_storage">evm_storage::exist_account_storage</a>(<b>address</b>)
    };
    exist
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_nonce"></a>

## Function `get_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_nonce">get_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_nonce">get_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> (exist, nonce) = <a href="evm_context.md#0x1_evm_context_get_nonce">evm_context::get_nonce</a>(contract);
    <b>if</b>(!exist) {
        nonce = <a href="storage.md#0x1_evm_storage_get_nonce_storage">evm_storage::get_nonce_storage</a>(contract);
        <a href="evm_context.md#0x1_evm_context_set_nonce">evm_context::set_nonce</a>(contract, nonce);
    };
    nonce
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_code"></a>

## Function `get_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_code">get_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_code">get_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> (exist, <a href="code.md#0x1_code">code</a>) = <a href="evm_context.md#0x1_evm_context_get_code">evm_context::get_code</a>(contract);
    <b>if</b>(!exist) {
        <a href="code.md#0x1_code">code</a> = <a href="storage.md#0x1_evm_storage_get_code_storage">evm_storage::get_code_storage</a>(contract);
    };
    <a href="code.md#0x1_code">code</a>
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_code_length"></a>

## Function `get_code_length`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_code_length">get_code_length</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_code_length">get_code_length</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="trie_v2.md#0x1_evm_trie_v2_get_code">get_code</a>(contract)) <b>as</b> u256)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_balance"></a>

## Function `get_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_balance">get_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_balance">get_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> (exist, balance) = <a href="evm_context.md#0x1_evm_context_get_balance">evm_context::get_balance</a>(contract);
    <b>if</b>(!exist) {
        balance = <a href="storage.md#0x1_evm_storage_get_balance_storage">evm_storage::get_balance_storage</a>(contract);
        <a href="evm_context.md#0x1_evm_context_set_balance">evm_context::set_balance</a>(contract, balance);
    };
    balance
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_state"></a>

## Function `get_state`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_state">get_state</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_state">get_state</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256 {
    <b>let</b> (exist, value) = <a href="evm_context.md#0x1_evm_context_get_storage">evm_context::get_storage</a>(contract, key);
    <b>if</b>(!exist) {
        value = <a href="storage.md#0x1_evm_storage_get_state_storage">evm_storage::get_state_storage</a>(contract, key);
        <a href="evm_context.md#0x1_evm_context_set_storage">evm_context::set_storage</a>(contract, key, value)
    };
    value
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_pre_init"></a>

## Function `pre_init`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;): (u256, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                            codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                            nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                            balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                            storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                            storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                            access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                            access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;): (u256, u256) {

    <b>let</b> pre_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&addresses);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&codes), 3);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&storage_keys), 3);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&storage_values), 3);
    <b>let</b> i = 0;
    <b>while</b>(i &lt; pre_len) {
        <b>let</b> key_datas = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&storage_keys, i);
        <b>let</b> value_datas = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&storage_values, i);
        <b>let</b> data_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&key_datas);
        <b>assert</b>!(data_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&value_datas), 4);
        <b>let</b> <b>address</b> = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&addresses, i);

        <b>let</b> j = 0;
        <b>while</b> (j &lt; data_len) {
            <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&key_datas, j);
            <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&value_datas, j);
            <a href="evm_context.md#0x1_evm_context_set_storage">evm_context::set_storage</a>(<b>address</b>, to_u256(key), to_u256(value));
            j = j + 1;
        };
        <a href="evm_context.md#0x1_evm_context_set_account">evm_context::set_account</a>(<b>address</b>, to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&balances, i)), *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&codes, i), to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&nonces, i)));
        i = i + 1;
    };

    i = 0;
    <b>let</b> access_slot_count = 0;
    <b>let</b> access_list_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_addresses);
    <b>assert</b>!(access_list_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_keys), 3);
    <b>while</b> (i &lt; access_list_len) {
        <b>let</b> access_data = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_keys, i);
        <b>let</b> contract = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_addresses, i);
        <b>let</b> j = 0;
        <b>let</b> data_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_data);
        <b>while</b> (j &lt; data_len) {
            <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_data, j);
            <a href="evm_context.md#0x1_evm_context_add_always_hot_slot">evm_context::add_always_hot_slot</a>(contract, to_u256(key));
            j = j + 1;
            access_slot_count = access_slot_count + 1;
        };

        <a href="evm_context.md#0x1_evm_context_add_always_hot_address">evm_context::add_always_hot_address</a>(contract);

        i = i + 1;
    };

    ((access_list_len <b>as</b> u256), access_slot_count)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_save"></a>

## Function `save`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_save">save</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_save">save</a>() {
    <b>let</b> (len, address_list, balances) = <a href="evm_context.md#0x1_evm_context_get_balance_change_set">evm_context::get_balance_change_set</a>();
    <b>let</b> i = 0;
    <b>while</b>(i &lt; len) {
        <b>let</b> <b>address</b> = vector_slice(address_list, 32 * i, 32);
        <b>let</b> balance = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&balances, i);
        <a href="storage.md#0x1_evm_storage_save_account_balance">evm_storage::save_account_balance</a>(<b>address</b>, balance);
        i = i + 1;
    };

    <b>let</b> (len, address_list, nonces) = <a href="evm_context.md#0x1_evm_context_get_nonce_change_set">evm_context::get_nonce_change_set</a>();
    <b>let</b> i = 0;
    <b>while</b>(i &lt; len) {
        <b>let</b> <b>address</b> = vector_slice(address_list, 32 * i, 32);
        <b>let</b> nonce = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&nonces, i);
        <a href="storage.md#0x1_evm_storage_save_account_nonce">evm_storage::save_account_nonce</a>(<b>address</b>, nonce);
        i = i + 1;
    };

    <b>let</b> (len, address_list, code_lengths, code_list) = <a href="evm_context.md#0x1_evm_context_get_code_change_set">evm_context::get_code_change_set</a>();
    <b>let</b> i = 0;
    <b>let</b> code_index = 0;
    <b>while</b>(i &lt; len) {
        <b>let</b> <b>address</b> = vector_slice(address_list, 32 * i, 32);

        <b>let</b> code_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&code_lengths, i);
        <b>let</b> <a href="code.md#0x1_code">code</a> = vector_slice(code_list, code_index, code_length);
        code_index = code_index + code_length;
        <a href="storage.md#0x1_evm_storage_save_account_code">evm_storage::save_account_code</a>(<b>address</b>, <a href="code.md#0x1_code">code</a>);

        i = i + 1;
    };

    <b>let</b> (len, address_list) = <a href="evm_context.md#0x1_evm_context_get_address_change_set">evm_context::get_address_change_set</a>();
    <b>let</b> i = 0;
    <b>while</b>(i &lt; len) {
        <b>let</b> <b>address</b> = vector_slice(address_list, 32 * i, 32);
        <b>let</b> (keys, values) = <a href="evm_context.md#0x1_evm_context_get_storage_change_set">evm_context::get_storage_change_set</a>(<b>address</b>);
        <a href="storage.md#0x1_evm_storage_save_account_state">evm_storage::save_account_state</a>(<b>address</b>, keys, values);
        i = i + 1;
    };
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_add_warm_address"></a>

## Function `add_warm_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_warm_address">add_warm_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_add_warm_address">add_warm_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <a href="evm_context.md#0x1_evm_context_add_hot_address">evm_context::add_hot_address</a>(<b>address</b>)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_is_cold_address"></a>

## Function `is_cold_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <a href="evm_context.md#0x1_evm_context_is_cold_address">evm_context::is_cold_address</a>(<b>address</b>)
}
</code></pre>



</details>

<a id="0x1_evm_trie_v2_get_cache"></a>

## Function `get_cache`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie_v2.md#0x1_evm_trie_v2_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                             key: u256): (bool, u256) {
    <a href="trie_v2.md#0x1_evm_trie_v2_get_state">get_state</a>(<b>address</b>, key);
    <a href="evm_context.md#0x1_evm_context_get_origin">evm_context::get_origin</a>(<b>address</b>, key)
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
