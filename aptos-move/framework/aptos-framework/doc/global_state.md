
<a id="0x1_evm_global_state"></a>

# Module `0x1::evm_global_state`



-  [Struct `RunState`](#0x1_evm_global_state_RunState)
-  [Struct `CallState`](#0x1_evm_global_state_CallState)
-  [Function `new_run_state`](#0x1_evm_global_state_new_run_state)
-  [Function `add_call_state`](#0x1_evm_global_state_add_call_state)
-  [Function `get_lastest_state_mut`](#0x1_evm_global_state_get_lastest_state_mut)
-  [Function `get_lastest_state`](#0x1_evm_global_state_get_lastest_state)
-  [Function `commit_call_state`](#0x1_evm_global_state_commit_call_state)
-  [Function `revert_call_state`](#0x1_evm_global_state_revert_call_state)
-  [Function `get_memory_cost`](#0x1_evm_global_state_get_memory_cost)
-  [Function `set_memory_cost`](#0x1_evm_global_state_set_memory_cost)
-  [Function `get_memory_word_size`](#0x1_evm_global_state_get_memory_word_size)
-  [Function `set_memory_word_size`](#0x1_evm_global_state_set_memory_word_size)
-  [Function `add_gas_usage`](#0x1_evm_global_state_add_gas_usage)
-  [Function `add_gas_left`](#0x1_evm_global_state_add_gas_left)
-  [Function `add_gas_refund`](#0x1_evm_global_state_add_gas_refund)
-  [Function `sub_gas_refund`](#0x1_evm_global_state_sub_gas_refund)
-  [Function `clear_gas_refund`](#0x1_evm_global_state_clear_gas_refund)
-  [Function `get_gas_left`](#0x1_evm_global_state_get_gas_left)
-  [Function `get_gas_refund`](#0x1_evm_global_state_get_gas_refund)


<pre><code></code></pre>



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
</dl>


</details>

<a id="0x1_evm_global_state_new_run_state"></a>

## Function `new_run_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(gas_limit: u256): <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(gas_limit: u256): <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a> {
    <b>let</b> state = <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a> {
        call_state: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>(),
    };
    <a href="global_state.md#0x1_evm_global_state_add_call_state">add_call_state</a>(&<b>mut</b> state, gas_limit);
    state
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_call_state"></a>

## Function `add_call_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_call_state">add_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_call_state">add_call_state</a>(run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">RunState</a>, gas_limit: u256) {
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> run_state.call_state, <a href="global_state.md#0x1_evm_global_state_CallState">CallState</a> {
        highest_memory_cost: 0,
        highest_memory_word_size: 0,
        gas_refund: 0,
        gas_left: gas_limit,
        gas_limit
    })
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


[move-book]: https://aptos.dev/move/book/SUMMARY
