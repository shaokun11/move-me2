
<a id="0x1_evm_trie"></a>

# Module `0x1::evm_trie`



-  [Struct `Trie`](#0x1_evm_trie_Trie)
-  [Struct `Log`](#0x1_evm_trie_Log)
-  [Struct `AccountContext`](#0x1_evm_trie_AccountContext)
-  [Struct `Checkpoint`](#0x1_evm_trie_Checkpoint)
-  [Function `init_new_trie`](#0x1_evm_trie_init_new_trie)
-  [Function `add_checkpoint`](#0x1_evm_trie_add_checkpoint)
-  [Function `get_lastest_checkpoint_mut`](#0x1_evm_trie_get_lastest_checkpoint_mut)
-  [Function `get_lastest_checkpoint`](#0x1_evm_trie_get_lastest_checkpoint)
-  [Function `new_account`](#0x1_evm_trie_new_account)
-  [Function `load_account_checkpoint`](#0x1_evm_trie_load_account_checkpoint)
-  [Function `load_account_checkpoint_mut`](#0x1_evm_trie_load_account_checkpoint_mut)
-  [Function `add_log`](#0x1_evm_trie_add_log)
-  [Function `get_logs`](#0x1_evm_trie_get_logs)
-  [Function `get_transient_storage`](#0x1_evm_trie_get_transient_storage)
-  [Function `put_transient_storage`](#0x1_evm_trie_put_transient_storage)
-  [Function `set_balance`](#0x1_evm_trie_set_balance)
-  [Function `set_code`](#0x1_evm_trie_set_code)
-  [Function `set_nonce`](#0x1_evm_trie_set_nonce)
-  [Function `set_state`](#0x1_evm_trie_set_state)
-  [Function `create_account`](#0x1_evm_trie_create_account)
-  [Function `remove_account`](#0x1_evm_trie_remove_account)
-  [Function `sub_balance`](#0x1_evm_trie_sub_balance)
-  [Function `add_balance`](#0x1_evm_trie_add_balance)
-  [Function `add_nonce`](#0x1_evm_trie_add_nonce)
-  [Function `transfer`](#0x1_evm_trie_transfer)
-  [Function `is_contract_or_created_account`](#0x1_evm_trie_is_contract_or_created_account)
-  [Function `exist_contract`](#0x1_evm_trie_exist_contract)
-  [Function `exist_account`](#0x1_evm_trie_exist_account)
-  [Function `get_nonce`](#0x1_evm_trie_get_nonce)
-  [Function `get_code`](#0x1_evm_trie_get_code)
-  [Function `get_code_length`](#0x1_evm_trie_get_code_length)
-  [Function `get_balance`](#0x1_evm_trie_get_balance)
-  [Function `get_state`](#0x1_evm_trie_get_state)
-  [Function `save`](#0x1_evm_trie_save)
-  [Function `revert_checkpoint`](#0x1_evm_trie_revert_checkpoint)
-  [Function `commit_latest_checkpoint`](#0x1_evm_trie_commit_latest_checkpoint)
-  [Function `add_warm_address`](#0x1_evm_trie_add_warm_address)
-  [Function `is_cold_address`](#0x1_evm_trie_is_cold_address)
-  [Function `get_cache`](#0x1_evm_trie_get_cache)
-  [Function `put`](#0x1_evm_trie_put)
-  [Function `is_access_address`](#0x1_evm_trie_is_access_address)
-  [Function `is_access_slot`](#0x1_evm_trie_is_access_slot)


<pre><code><b>use</b> <a href="precompile.md#0x1_evm_precompile">0x1::evm_precompile</a>;
<b>use</b> <a href="storage.md#0x1_evm_storage">0x1::evm_storage</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
</code></pre>



<a id="0x1_evm_trie_Trie"></a>

## Struct `Trie`



<pre><code><b>struct</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>context: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="trie.md#0x1_evm_trie_Checkpoint">evm_trie::Checkpoint</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>access_list: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, bool&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_trie_Log"></a>

## Struct `Log`



<pre><code><b>struct</b> <a href="trie.md#0x1_evm_trie_Log">Log</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_trie_AccountContext"></a>

## Struct `AccountContext`



<pre><code><b>struct</b> <a href="trie.md#0x1_evm_trie_AccountContext">AccountContext</a> <b>has</b> <b>copy</b>, drop, store
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

<a id="0x1_evm_trie_Checkpoint"></a>

## Struct `Checkpoint`



<pre><code><b>struct</b> <a href="trie.md#0x1_evm_trie_Checkpoint">Checkpoint</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>state: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="trie.md#0x1_evm_trie_AccountContext">evm_trie::AccountContext</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>transient: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>self_destruct: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, bool&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>origin: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>logs: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="trie.md#0x1_evm_trie_Log">evm_trie::Log</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_trie_init_new_trie"></a>

## Function `init_new_trie`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_init_new_trie">init_new_trie</a>(): <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_init_new_trie">init_new_trie</a>(): <a href="trie.md#0x1_evm_trie_Trie">Trie</a> {
    <b>let</b> trie = <a href="trie.md#0x1_evm_trie_Trie">Trie</a> {
        context: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
        access_list: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>()
    };

    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> trie.context, <a href="trie.md#0x1_evm_trie_Checkpoint">Checkpoint</a> {
        state: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>(),
        self_destruct: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>(),
        transient: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>(),
        origin: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>(),
        logs: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>()
    });

    trie
}
</code></pre>



</details>

<a id="0x1_evm_trie_add_checkpoint"></a>

## Function `add_checkpoint`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_add_checkpoint">add_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_add_checkpoint">add_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&trie.context);
    <b>let</b> elem = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<b>mut</b> trie.context, len - 1);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> trie.context, elem);
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_lastest_checkpoint_mut"></a>

## Function `get_lastest_checkpoint_mut`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): &<b>mut</b> <a href="trie.md#0x1_evm_trie_Checkpoint">evm_trie::Checkpoint</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): &<b>mut</b> <a href="trie.md#0x1_evm_trie_Checkpoint">Checkpoint</a> {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&trie.context);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> trie.context, len - 1)
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_lastest_checkpoint"></a>

## Function `get_lastest_checkpoint`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): &<a href="trie.md#0x1_evm_trie_Checkpoint">evm_trie::Checkpoint</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): &<a href="trie.md#0x1_evm_trie_Checkpoint">Checkpoint</a> {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&trie.context);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&trie.context, len - 1)
}
</code></pre>



</details>

<a id="0x1_evm_trie_new_account"></a>

## Function `new_account`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_new_account">new_account</a>(balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256): <a href="trie.md#0x1_evm_trie_AccountContext">evm_trie::AccountContext</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_new_account">new_account</a>(balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256): <a href="trie.md#0x1_evm_trie_AccountContext">AccountContext</a> {
    <a href="trie.md#0x1_evm_trie_AccountContext">AccountContext</a> {
        <a href="code.md#0x1_code">code</a>,
        balance,
        nonce,
        storage: <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>()
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_load_account_checkpoint"></a>

## Function `load_account_checkpoint`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="trie.md#0x1_evm_trie_AccountContext">evm_trie::AccountContext</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="trie.md#0x1_evm_trie_AccountContext">AccountContext</a> {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie);
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.state, contract_addr)) {
        *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(&checkpoint.state, contract_addr)
    } <b>else</b> {
        <b>let</b> (balance, <a href="code.md#0x1_code">code</a>, nonce) = load_account_storage(*contract_addr);
        <a href="trie.md#0x1_evm_trie_new_account">new_account</a>(balance, <a href="code.md#0x1_code">code</a>, nonce)
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_load_account_checkpoint_mut"></a>

## Function `load_account_checkpoint_mut`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): &<b>mut</b> <a href="trie.md#0x1_evm_trie_AccountContext">evm_trie::AccountContext</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): &<b>mut</b> <a href="trie.md#0x1_evm_trie_AccountContext">AccountContext</a> {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&trie.context);
    <b>let</b> checkpoint = &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> trie.context, len - 1).state;
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(checkpoint, contract_addr)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(checkpoint, contract_addr)
    } <b>else</b> {
        <b>if</b>(!exist_account_storage(*contract_addr)) {
            <a href="trie.md#0x1_evm_trie_create_account">create_account</a>(*contract_addr, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>(), 0, 0, trie);
            <b>return</b> <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, contract_addr)
        };
        <b>let</b> (balance, <a href="code.md#0x1_code">code</a>, nonce) = load_account_storage(*contract_addr);
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(checkpoint, *contract_addr, <a href="trie.md#0x1_evm_trie_new_account">new_account</a>(balance, <a href="code.md#0x1_code">code</a>, nonce));
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(checkpoint, contract_addr)
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_add_log"></a>

## Function `add_log`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_log">add_log</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_log">add_log</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, topics: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;) {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> checkpoint.logs, <a href="trie.md#0x1_evm_trie_Log">Log</a> {
        contract,
        data,
        topics
    });
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_logs"></a>

## Function `get_logs`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_logs">get_logs</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="trie.md#0x1_evm_trie_Log">evm_trie::Log</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_logs">get_logs</a>(trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="trie.md#0x1_evm_trie_Log">Log</a>&gt; {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie);
    checkpoint.logs
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_transient_storage"></a>

## Function `get_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_get_transient_storage">get_transient_storage</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_get_transient_storage">get_transient_storage</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256): u256{
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie);
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.transient, &contract_addr)) {
        0
    } <b>else</b> {
        <b>let</b> data = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(&checkpoint.transient, &contract_addr);
        <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(data, &key)) {
            0
        } <b>else</b> {
            *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(data, &key)
        }
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_put_transient_storage"></a>

## Function `put_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_put_transient_storage">put_transient_storage</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_put_transient_storage">put_transient_storage</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256) {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.transient, &contract_addr)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> checkpoint.transient, contract_addr, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>())
    };
    <b>let</b> data = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(&<b>mut</b> checkpoint.transient, &contract_addr);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(data, key, value);
}
</code></pre>



</details>

<a id="0x1_evm_trie_set_balance"></a>

## Function `set_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_balance">set_balance</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_balance">set_balance</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.balance = balance;
}
</code></pre>



</details>

<a id="0x1_evm_trie_set_code"></a>

## Function `set_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_code">set_code</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_code">set_code</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a> = <a href="code.md#0x1_code">code</a>;
}
</code></pre>



</details>

<a id="0x1_evm_trie_set_nonce"></a>

## Function `set_nonce`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_set_nonce">set_nonce</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_set_nonce">set_nonce</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>, contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.nonce = nonce;
}
</code></pre>



</details>

<a id="0x1_evm_trie_set_state"></a>

## Function `set_state`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_state">set_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_set_state">set_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <b>if</b>(value == 0) {
        <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&<b>mut</b> <a href="account.md#0x1_account">account</a>.storage, &key)) {
            <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_remove">simple_map::remove</a>(&<b>mut</b> <a href="account.md#0x1_account">account</a>.storage, &key);
        }
    } <b>else</b> {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(&<b>mut</b> <a href="account.md#0x1_account">account</a>.storage, key, value);
    };
}
</code></pre>



</details>

<a id="0x1_evm_trie_create_account"></a>

## Function `create_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_create_account">create_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, nonce: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_create_account">create_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, nonce: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>if</b>(!<a href="trie.md#0x1_evm_trie_exist_account">exist_account</a>(contract_addr, trie)) {
        <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> checkpoint.state, contract_addr, <a href="trie.md#0x1_evm_trie_new_account">new_account</a>(balance, <a href="code.md#0x1_code">code</a>, nonce));
    } <b>else</b> {
        <a href="trie.md#0x1_evm_trie_set_nonce">set_nonce</a>(trie, contract_addr, 1);
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_remove_account"></a>

## Function `remove_account`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_remove_account">remove_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_remove_account">remove_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_remove">simple_map::remove</a>(&<b>mut</b> checkpoint.state, &contract_addr);
}
</code></pre>



</details>

<a id="0x1_evm_trie_sub_balance"></a>

## Function `sub_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_sub_balance">sub_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_sub_balance">sub_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <b>if</b>(<a href="account.md#0x1_account">account</a>.balance &gt;= amount) {
        <a href="account.md#0x1_account">account</a>.balance = <a href="account.md#0x1_account">account</a>.balance - amount;
        <b>true</b>
    } <b>else</b> {
        <b>false</b>
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_add_balance"></a>

## Function `add_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_balance">add_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_balance">add_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.balance = <a href="account.md#0x1_account">account</a>.balance + amount;
}
</code></pre>



</details>

<a id="0x1_evm_trie_add_nonce"></a>

## Function `add_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_nonce">add_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_nonce">add_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint_mut">load_account_checkpoint_mut</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.nonce = <a href="account.md#0x1_account">account</a>.nonce + 1;
}
</code></pre>



</details>

<a id="0x1_evm_trie_transfer"></a>

## Function `transfer`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_transfer">transfer</a>(from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, amount: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>if</b>(amount &gt; 0) {
        <b>let</b> success = <a href="trie.md#0x1_evm_trie_sub_balance">sub_balance</a>(from, amount, trie);
        <b>if</b>(success) {
            <a href="trie.md#0x1_evm_trie_add_balance">add_balance</a>(<b>to</b>, amount, trie);
        };
        success
    } <b>else</b> {
        <b>true</b>
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_is_contract_or_created_account"></a>

## Function `is_contract_or_created_account`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_is_contract_or_created_account">is_contract_or_created_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_is_contract_or_created_account">is_contract_or_created_account</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>if</b>(!<a href="trie.md#0x1_evm_trie_exist_account">exist_account</a>(contract_addr, trie)) {
        <b>false</b>
    } <b>else</b> {
        <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>) &gt; 0 || <a href="account.md#0x1_account">account</a>.nonce &gt; 0 || <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_length">simple_map::length</a>(&<a href="account.md#0x1_account">account</a>.storage) &gt; 0
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_exist_contract"></a>

## Function `exist_contract`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_exist_contract">exist_contract</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_exist_contract">exist_contract</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>if</b>(!<a href="trie.md#0x1_evm_trie_exist_account">exist_account</a>(contract_addr, trie)) {
        <b>false</b>
    } <b>else</b> {
        <b>let</b> <a href="code.md#0x1_code">code</a> = <a href="trie.md#0x1_evm_trie_get_code">get_code</a>(contract_addr, trie);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="code.md#0x1_code">code</a>) &gt; 0
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_exist_account"></a>

## Function `exist_account`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_exist_account">exist_account</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&trie.context);
    <b>let</b> checkpoint = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&trie.context, len - 1).state;
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint, &<b>address</b>)) {
        <b>return</b> exist_account_storage(<b>address</b>)
    };

    <b>true</b>
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_nonce"></a>

## Function `get_nonce`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_nonce">get_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_nonce">get_nonce</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): u256 {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.nonce
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_code"></a>

## Function `get_code`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_code">get_code</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_code">get_code</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_code_length"></a>

## Function `get_code_length`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_code_length">get_code_length</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_code_length">get_code_length</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): u256 {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
    (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>) <b>as</b> u256)
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_balance"></a>

## Function `get_balance`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_balance">get_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_balance">get_balance</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): u256 {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
    <a href="account.md#0x1_account">account</a>.balance
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_state"></a>

## Function `get_state`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_state">get_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_state">get_state</a>(contract_addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): u256 {
    <b>let</b> <a href="account.md#0x1_account">account</a> = <a href="trie.md#0x1_evm_trie_load_account_checkpoint">load_account_checkpoint</a>(trie, &contract_addr);
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&<a href="account.md#0x1_account">account</a>.storage, &key)) {
        *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(&<a href="account.md#0x1_account">account</a>.storage, &key)
    } <b>else</b> {
        get_state_storage(contract_addr, key)
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_save"></a>

## Function `save`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_save">save</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_save">save</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> checkpoint = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> trie.context).state;
    <b>let</b> (keys, values) = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_to_vec_pair">simple_map::to_vec_pair</a>(checkpoint);
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&keys);
    <b>while</b>(i &lt; len) {
        <b>let</b> <b>address</b> = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&keys, i);
        <b>let</b> <a href="account.md#0x1_account">account</a> = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&values, i);
        save_account_storage(<b>address</b>, <a href="account.md#0x1_account">account</a>.balance, <a href="account.md#0x1_account">account</a>.<a href="code.md#0x1_code">code</a>, <a href="account.md#0x1_account">account</a>.nonce);
        <b>let</b> (keys, values) = to_vec_pair(<a href="account.md#0x1_account">account</a>.storage);
        save_account_state(<b>address</b>, keys, values);
        i = i + 1;
    };
}
</code></pre>



</details>

<a id="0x1_evm_trie_revert_checkpoint"></a>

## Function `revert_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_revert_checkpoint">revert_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_revert_checkpoint">revert_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> trie.context);
}
</code></pre>



</details>

<a id="0x1_evm_trie_commit_latest_checkpoint"></a>

## Function `commit_latest_checkpoint`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_commit_latest_checkpoint">commit_latest_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_commit_latest_checkpoint">commit_latest_checkpoint</a>(trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> new_checkpoint = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> trie.context);
    <b>let</b> old_checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    *old_checkpoint = new_checkpoint;
}
</code></pre>



</details>

<a id="0x1_evm_trie_add_warm_address"></a>

## Function `add_warm_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_warm_address">add_warm_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_add_warm_address">add_warm_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.origin, &<b>address</b>)) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(&<b>mut</b> checkpoint.origin, <b>address</b>, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;());
    }
}
</code></pre>



</details>

<a id="0x1_evm_trie_is_cold_address"></a>

## Function `is_cold_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="trie.md#0x1_evm_trie_is_cold_address">is_cold_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>if</b>(is_precompile_address(<b>address</b>) || <a href="trie.md#0x1_evm_trie_is_access_address">is_access_address</a>(<b>address</b>, trie)) {
        <b>return</b> <b>false</b>
    };
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <b>let</b> is_cold = !<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.origin, &<b>address</b>);
    <b>if</b>(is_cold) {
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> checkpoint.origin, <b>address</b>, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;());
    };

    is_cold
}
</code></pre>



</details>

<a id="0x1_evm_trie_get_cache"></a>

## Function `get_cache`



<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="trie.md#0x1_evm_trie_get_cache">get_cache</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                     key: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): (bool, u256) {
    <b>let</b> is_access_slot = !<a href="trie.md#0x1_evm_trie_is_access_slot">is_access_slot</a>(<b>address</b>, key, trie);
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint">get_lastest_checkpoint</a>(trie);
    <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.origin, &<b>address</b>)) {
        <b>let</b> storage = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(&checkpoint.origin, &<b>address</b>);
        <b>if</b>(<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(storage, &key)) {
            <b>return</b> (<b>false</b>, *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(storage, &key))
        }
    };

    <b>let</b> value = <a href="trie.md#0x1_evm_trie_get_state">get_state</a>(<b>address</b>, key, trie);
    <a href="trie.md#0x1_evm_trie_put">put</a>(<b>address</b>, key, value, trie);

    (is_access_slot, value)
}
</code></pre>



</details>

<a id="0x1_evm_trie_put"></a>

## Function `put`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_put">put</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_put">put</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, value: u256, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>) {
    <b>let</b> checkpoint = <a href="trie.md#0x1_evm_trie_get_lastest_checkpoint_mut">get_lastest_checkpoint_mut</a>(trie);
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&checkpoint.origin, &<b>address</b>)) {
        <b>let</b> new_table = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, u256&gt;();
        <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> checkpoint.origin, <b>address</b>, new_table);
    };
    <b>let</b> <a href="../../aptos-stdlib/doc/table.md#0x1_table">table</a> = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(&<b>mut</b> checkpoint.origin, &<b>address</b>);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(<a href="../../aptos-stdlib/doc/table.md#0x1_table">table</a>, key, value);
}
</code></pre>



</details>

<a id="0x1_evm_trie_is_access_address"></a>

## Function `is_access_address`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_is_access_address">is_access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_is_access_address">is_access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&trie.access_list, &<b>address</b>)
}
</code></pre>



</details>

<a id="0x1_evm_trie_is_access_slot"></a>

## Function `is_access_slot`



<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_is_access_slot">is_access_slot</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="trie.md#0x1_evm_trie_is_access_slot">is_access_slot</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, key: u256, trie: &<a href="trie.md#0x1_evm_trie_Trie">Trie</a>): bool {
    <b>if</b>(!<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(&trie.access_list, &<b>address</b>)) {
        <b>return</b> <b>false</b>
    };

    <b>let</b> data = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(&trie.access_list, &<b>address</b>);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_contains_key">simple_map::contains_key</a>(data, &key)
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
