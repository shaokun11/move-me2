
<a id="0x1_evm_global_state"></a>

# Module `0x1::evm_global_state`



-  [Struct `Env`](#0x1_evm_global_state_Env)
-  [Struct `RunState`](#0x1_evm_global_state_RunState)
-  [Struct `CallState`](#0x1_evm_global_state_CallState)
-  [Constants](#@Constants_0)
-  [Function `new_run_state`](#0x1_evm_global_state_new_run_state)
-  [Function `add_call_state`](#0x1_evm_global_state_add_call_state)
-  [Function `get_lastest_state_mut`](#0x1_evm_global_state_get_lastest_state_mut)
-  [Function `get_lastest_state`](#0x1_evm_global_state_get_lastest_state)
-  [Function `commit_call_state`](#0x1_evm_global_state_commit_call_state)
-  [Function `revert_call_state`](#0x1_evm_global_state_revert_call_state)
-  [Function `get_memory_cost`](#0x1_evm_global_state_get_memory_cost)
-  [Function `set_memory_cost`](#0x1_evm_global_state_set_memory_cost)
-  [Function `get_memory_word_size`](#0x1_evm_global_state_get_memory_word_size)
-  [Function `set_ret_bytes`](#0x1_evm_global_state_set_ret_bytes)
-  [Function `get_ret_bytes`](#0x1_evm_global_state_get_ret_bytes)
-  [Function `get_ret_size`](#0x1_evm_global_state_get_ret_size)
-  [Function `set_memory_word_size`](#0x1_evm_global_state_set_memory_word_size)
-  [Function `add_gas_usage`](#0x1_evm_global_state_add_gas_usage)
-  [Function `add_gas_left`](#0x1_evm_global_state_add_gas_left)
-  [Function `add_gas_refund`](#0x1_evm_global_state_add_gas_refund)
-  [Function `sub_gas_refund`](#0x1_evm_global_state_sub_gas_refund)
-  [Function `clear_gas_refund`](#0x1_evm_global_state_clear_gas_refund)
-  [Function `get_is_static`](#0x1_evm_global_state_get_is_static)
-  [Function `get_gas_left`](#0x1_evm_global_state_get_gas_left)
-  [Function `get_gas_refund`](#0x1_evm_global_state_get_gas_refund)
-  [Function `get_coinbase`](#0x1_evm_global_state_get_coinbase)
-  [Function `get_basefee`](#0x1_evm_global_state_get_basefee)
-  [Function `get_gas_price`](#0x1_evm_global_state_get_gas_price)
-  [Function `get_block_gas_limit`](#0x1_evm_global_state_get_block_gas_limit)
-  [Function `get_timestamp`](#0x1_evm_global_state_get_timestamp)
-  [Function `get_block_number`](#0x1_evm_global_state_get_block_number)
-  [Function `get_block_difficulty`](#0x1_evm_global_state_get_block_difficulty)
-  [Function `get_random`](#0x1_evm_global_state_get_random)
-  [Function `get_origin`](#0x1_evm_global_state_get_origin)
-  [Function `get_max_fee_per_gas`](#0x1_evm_global_state_get_max_fee_per_gas)
-  [Function `get_max_priority_fee_per_gas`](#0x1_evm_global_state_get_max_priority_fee_per_gas)
-  [Function `is_eip_1559`](#0x1_evm_global_state_is_eip_1559)
-  [Function `parse_env`](#0x1_evm_global_state_parse_env)


<pre><code><b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
</code></pre>



<a id="0x1_evm_global_state_Env"></a>

## Struct `Env`



<pre><code><b>struct</b> <a href="global_state.md#0x1_evm_global_state_Env">Env</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>base_fee: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>coinbase: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>difficulty: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>excess_blob_gas: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_gas_limit: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>gas_price: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>max_priority_fee_per_gas: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>max_fee_per_gas: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>number: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>random: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="timestamp.md#0x1_timestamp">timestamp</a>: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>tx_type: u8</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_global_state_RunState"></a>

## Struct `RunState`



<pre><code><b>struct</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>call_state: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="global_state.md#0x1_evm_global_state_CallState">evm_global_state::CallState</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>env: <a href="global_state.md#0x1_evm_global_state_Env">evm_global_state::Env</a></code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_global_state_CallState"></a>

## Struct `CallState`



<pre><code><b>struct</b> <a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>highest_memory_cost: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>highest_memory_word_size: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>gas_refund: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>gas_left: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>gas_limit: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>is_static: bool</code>
</dt>
<dd>

</dd>
<dt>
<code>ret_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_global_state_TX_TYPE_1559"></a>



<pre><code><b>const</b> <a href="global_state.md#0x1_evm_global_state_TX_TYPE_1559">TX_TYPE_1559</a>: u8 = 1;
</code></pre>



<a id="0x1_evm_global_state_TX_TYPE_NORMAL"></a>



<pre><code><b>const</b> <a href="global_state.md#0x1_evm_global_state_TX_TYPE_NORMAL">TX_TYPE_NORMAL</a>: u8 = 0;
</code></pre>



<a id="0x1_evm_global_state_new_run_state"></a>

## Function `new_run_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, gas_limit: u256, env_data: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8): <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, gas_limit: u256, env_data: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8): <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a> {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a> {
        call_state: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
        env: <a href="global_state.md#0x1_evm_global_state_parse_env">parse_env</a>(env_data, sender, gas_price_data, tx_type)
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> state.call_state, <a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> {
        highest_memory_cost: 0,
        highest_memory_word_size: 0,
        gas_refund: 0,
        gas_left: gas_limit,
        gas_limit,
        is_static: <b>false</b>,
        ret_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>()
    });
    state
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_call_state"></a>

## Function `add_call_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_call_state">add_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, is_static: bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_call_state">add_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, gas_limit: u256, is_static: bool) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    <b>let</b> static = state.is_static || is_static;
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> run_state.call_state, <a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> {
        highest_memory_cost: 0,
        highest_memory_word_size: 0,
        gas_refund: 0,
        gas_left: gas_limit,
        gas_limit,
        is_static: static,
        ret_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>()
    });
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_lastest_state_mut"></a>

## Function `get_lastest_state_mut`



<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_CallState">evm_global_state::CallState</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&run_state.call_state);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(&<b>mut</b> run_state.call_state, len - 1)
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_lastest_state"></a>

## Function `get_lastest_state`



<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): &<a href="global_state.md#0x1_evm_global_state_CallState">evm_global_state::CallState</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): &<a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&run_state.call_state);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&run_state.call_state, len - 1)
}
</code></pre>



</details>

<a id="0x1_evm_global_state_commit_call_state"></a>

## Function `commit_call_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_commit_call_state">commit_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_commit_call_state">commit_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) {
    <b>let</b> new_state = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> run_state.call_state);
    <b>let</b> old_state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    old_state.gas_refund = old_state.gas_refund + new_state.gas_refund;
    old_state.gas_left = old_state.gas_left - (new_state.gas_limit - new_state.gas_left);
}
</code></pre>



</details>

<a id="0x1_evm_global_state_revert_call_state"></a>

## Function `revert_call_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_revert_call_state">revert_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_revert_call_state">revert_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) {
    <b>let</b> new_state = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(&<b>mut</b> run_state.call_state);
    <b>let</b> old_state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    old_state.gas_left = old_state.gas_left - new_state.gas_limit;
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_memory_cost"></a>

## Function `get_memory_cost`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_cost">get_memory_cost</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_cost">get_memory_cost</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) : u256 {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.highest_memory_cost
}
</code></pre>



</details>

<a id="0x1_evm_global_state_set_memory_cost"></a>

## Function `set_memory_cost`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_cost">set_memory_cost</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, cost: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_cost">set_memory_cost</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, cost: u256) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.highest_memory_cost = cost
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_memory_word_size"></a>

## Function `get_memory_word_size`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_word_size">get_memory_word_size</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_word_size">get_memory_word_size</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) : u256 {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.highest_memory_word_size
}
</code></pre>



</details>

<a id="0x1_evm_global_state_set_ret_bytes"></a>

## Function `set_ret_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_ret_bytes">set_ret_bytes</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_ret_bytes">set_ret_bytes</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.ret_bytes = bytes
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_ret_bytes"></a>

## Function `get_ret_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_ret_bytes">get_ret_bytes</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_ret_bytes">get_ret_bytes</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) : <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.ret_bytes
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_ret_size"></a>

## Function `get_ret_size`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_ret_size">get_ret_size</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_ret_size">get_ret_size</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&state.ret_bytes) <b>as</b> u256)
}
</code></pre>



</details>

<a id="0x1_evm_global_state_set_memory_word_size"></a>

## Function `set_memory_word_size`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_word_size">set_memory_word_size</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, count: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_word_size">set_memory_word_size</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, count: u256) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.highest_memory_word_size = count
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_gas_usage"></a>

## Function `add_gas_usage`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_usage">add_gas_usage</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, cost: u256): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_usage">add_gas_usage</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, cost: u256): bool {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    <b>if</b>(state.gas_left &lt; cost) {
        state.gas_left = 0;
        <b>return</b> <b>true</b>
    };
    state.gas_left = state.gas_left - cost;
    <b>return</b> <b>false</b>
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_gas_left"></a>

## Function `add_gas_left`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_left">add_gas_left</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, amount: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_left">add_gas_left</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, amount: u256) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.gas_left = <b>if</b>(state.gas_left &gt; amount) state.gas_left + amount <b>else</b> 0;
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_gas_refund"></a>

## Function `add_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_refund">add_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, refund: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_refund">add_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, refund: u256) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.gas_refund = state.gas_refund + refund;
}
</code></pre>



</details>

<a id="0x1_evm_global_state_sub_gas_refund"></a>

## Function `sub_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_sub_gas_refund">sub_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, refund: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_sub_gas_refund">sub_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, refund: u256) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.gas_refund = state.gas_refund - refund;
}
</code></pre>



</details>

<a id="0x1_evm_global_state_clear_gas_refund"></a>

## Function `clear_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_clear_gas_refund">clear_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_clear_gas_refund">clear_gas_refund</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>) {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state_mut">get_lastest_state_mut</a>(run_state);
    state.gas_refund = 0;
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_is_static"></a>

## Function `get_is_static`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_is_static">get_is_static</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_is_static">get_is_static</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): bool {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.is_static
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_gas_left"></a>

## Function `get_gas_left`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_left">get_gas_left</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_left">get_gas_left</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.gas_left
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_gas_refund"></a>

## Function `get_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_refund">get_gas_refund</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_refund">get_gas_refund</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_get_lastest_state">get_lastest_state</a>(run_state);
    state.gas_refund
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_coinbase"></a>

## Function `get_coinbase`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_coinbase">get_coinbase</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_coinbase">get_coinbase</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    run_state.env.coinbase
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_basefee"></a>

## Function `get_basefee`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_basefee">get_basefee</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_basefee">get_basefee</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.base_fee
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_gas_price"></a>

## Function `get_gas_price`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_price">get_gas_price</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_price">get_gas_price</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.gas_price
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_block_gas_limit"></a>

## Function `get_block_gas_limit`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_gas_limit">get_block_gas_limit</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_gas_limit">get_block_gas_limit</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.block_gas_limit
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_timestamp"></a>

## Function `get_timestamp`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_timestamp">get_timestamp</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_timestamp">get_timestamp</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.<a href="timestamp.md#0x1_timestamp">timestamp</a>
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_block_number"></a>

## Function `get_block_number`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_number">get_block_number</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_number">get_block_number</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.number
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_block_difficulty"></a>

## Function `get_block_difficulty`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_difficulty">get_block_difficulty</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_block_difficulty">get_block_difficulty</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.difficulty
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_random"></a>

## Function `get_random`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_random">get_random</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_random">get_random</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    run_state.env.random
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_origin"></a>

## Function `get_origin`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_origin">get_origin</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_origin">get_origin</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    run_state.env.sender
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_max_fee_per_gas"></a>

## Function `get_max_fee_per_gas`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_max_fee_per_gas">get_max_fee_per_gas</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_max_fee_per_gas">get_max_fee_per_gas</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.max_fee_per_gas
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_max_priority_fee_per_gas"></a>

## Function `get_max_priority_fee_per_gas`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_max_priority_fee_per_gas">get_max_priority_fee_per_gas</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_max_priority_fee_per_gas">get_max_priority_fee_per_gas</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): u256 {
    run_state.env.max_priority_fee_per_gas
}
</code></pre>



</details>

<a id="0x1_evm_global_state_is_eip_1559"></a>

## Function `is_eip_1559`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_is_eip_1559">is_eip_1559</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_is_eip_1559">is_eip_1559</a>(run_state: &<a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>): bool {
    run_state.env.tx_type == <a href="global_state.md#0x1_evm_global_state_TX_TYPE_1559">TX_TYPE_1559</a>
}
</code></pre>



</details>

<a id="0x1_evm_global_state_parse_env"></a>

## Function `parse_env`



<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_parse_env">parse_env</a>(env: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8): <a href="global_state.md#0x1_evm_global_state_Env">evm_global_state::Env</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="global_state.md#0x1_evm_global_state_parse_env">parse_env</a>(env: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8): <a href="global_state.md#0x1_evm_global_state_Env">Env</a> {
    <b>let</b> base_fee = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 0));
    <b>let</b> coinbase = to_32bit(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 1));
    <b>let</b> difficulty = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 2));
    <b>let</b> excess_blob_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 3));
    <b>let</b> block_gas_limit = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 4));
    <b>let</b> number = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 5));
    <b>let</b> random = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 6);
    <b>let</b> <a href="timestamp.md#0x1_timestamp">timestamp</a> = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 7));
    <b>let</b> gas_price;
    <b>let</b> max_fee_per_gas = 0;
    <b>let</b> max_priority_fee_per_gas = 0;
    <b>if</b>(tx_type == <a href="global_state.md#0x1_evm_global_state_TX_TYPE_NORMAL">TX_TYPE_NORMAL</a>) {
        gas_price = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 0))
    } <b>else</b> {
        gas_price = base_fee + to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 1));
        max_fee_per_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 0));
        max_priority_fee_per_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 1));
        gas_price = <b>if</b>(gas_price &gt; max_fee_per_gas) max_fee_per_gas <b>else</b> gas_price
    };
    <a href="global_state.md#0x1_evm_global_state_Env">Env</a> {
        tx_type,
        sender,
        max_fee_per_gas,
        max_priority_fee_per_gas,
        base_fee,
        coinbase,
        difficulty,
        excess_blob_gas,
        block_gas_limit,
        gas_price,
        number,
        random,
        <a href="timestamp.md#0x1_timestamp">timestamp</a>,
    }
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
