
<a id="0x1_evm_for_test"></a>

# Module `0x1::evm_for_test`



-  [Resource `ExecResource`](#0x1_evm_for_test_ExecResource)
-  [Struct `ExecResultEvent`](#0x1_evm_for_test_ExecResultEvent)
-  [Struct `Log0Event`](#0x1_evm_for_test_Log0Event)
-  [Struct `Log1Event`](#0x1_evm_for_test_Log1Event)
-  [Struct `Log2Event`](#0x1_evm_for_test_Log2Event)
-  [Struct `Log3Event`](#0x1_evm_for_test_Log3Event)
-  [Struct `Log4Event`](#0x1_evm_for_test_Log4Event)
-  [Resource `ContractEvent`](#0x1_evm_for_test_ContractEvent)
-  [Constants](#@Constants_0)
-  [Function `revert`](#0x1_evm_for_test_revert)
-  [Function `initialize`](#0x1_evm_for_test_initialize)
-  [Function `emit_event`](#0x1_evm_for_test_emit_event)
-  [Function `handle_tx_failed`](#0x1_evm_for_test_handle_tx_failed)
-  [Function `run_test`](#0x1_evm_for_test_run_test)
-  [Function `handle_normal_revert`](#0x1_evm_for_test_handle_normal_revert)
-  [Function `handle_unexpect_revert`](#0x1_evm_for_test_handle_unexpect_revert)
-  [Function `handle_commit`](#0x1_evm_for_test_handle_commit)
-  [Function `create_internal`](#0x1_evm_for_test_create_internal)
-  [Function `create`](#0x1_evm_for_test_create)
-  [Function `create2`](#0x1_evm_for_test_create2)
-  [Function `run`](#0x1_evm_for_test_run)
-  [Function `get_call_info`](#0x1_evm_for_test_get_call_info)
-  [Function `precompile`](#0x1_evm_for_test_precompile)
-  [Function `pop_stack_u64`](#0x1_evm_for_test_pop_stack_u64)
-  [Function `pop_stack`](#0x1_evm_for_test_pop_stack)


<pre><code><b>use</b> <a href="account.md#0x1_account">0x1::account</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_aptos_hash">0x1::aptos_hash</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/debug.md#0x1_debug">0x1::debug</a>;
<b>use</b> <a href="event.md#0x1_event">0x1::event</a>;
<b>use</b> <a href="arithmetic.md#0x1_evm_arithmetic">0x1::evm_arithmetic</a>;
<b>use</b> <a href="evm_context.md#0x1_evm_context">0x1::evm_context</a>;
<b>use</b> <a href="gas_for_test.md#0x1_evm_gas_for_test">0x1::evm_gas_for_test</a>;
<b>use</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test">0x1::evm_global_state_for_test</a>;
<b>use</b> <a href="precompile.md#0x1_evm_precompile">0x1::evm_precompile</a>;
<b>use</b> <a href="trie_for_test.md#0x1_evm_trie_for_test">0x1::evm_trie_for_test</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string">0x1::string</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="0x1_evm_for_test_ExecResource"></a>

## Resource `ExecResource`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>exec_event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_ExecResultEvent">evm_for_test::ExecResultEvent</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_ExecResultEvent"></a>

## Struct `ExecResultEvent`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_ExecResultEvent">ExecResultEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>gas_usage: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>gas_refund: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_Log0Event"></a>

## Struct `Log0Event`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_Log0Event">Log0Event</a> <b>has</b> drop, store
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
</dl>


</details>

<a id="0x1_evm_for_test_Log1Event"></a>

## Struct `Log1Event`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_Log1Event">Log1Event</a> <b>has</b> drop, store
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
<code>topic0: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_Log2Event"></a>

## Struct `Log2Event`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_Log2Event">Log2Event</a> <b>has</b> drop, store
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
<code>topic0: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic1: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_Log3Event"></a>

## Struct `Log3Event`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_Log3Event">Log3Event</a> <b>has</b> drop, store
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
<code>topic0: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic1: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic2: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_Log4Event"></a>

## Struct `Log4Event`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_Log4Event">Log4Event</a> <b>has</b> drop, store
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
<code>topic0: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic1: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic2: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>topic3: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_evm_for_test_ContractEvent"></a>

## Resource `ContractEvent`



<pre><code><b>struct</b> <a href="evm_for_test.md#0x1_evm_for_test_ContractEvent">ContractEvent</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>log0Event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_Log0Event">evm_for_test::Log0Event</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>log1Event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_Log1Event">evm_for_test::Log1Event</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>log2Event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_Log2Event">evm_for_test::Log2Event</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>log3Event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_Log3Event">evm_for_test::Log3Event</a>&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>log4Event: <a href="event.md#0x1_event_EventHandle">event::EventHandle</a>&lt;<a href="evm_for_test.md#0x1_evm_for_test_Log4Event">evm_for_test::Log4Event</a>&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_for_test_U256_MAX"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_U256_MAX">U256_MAX</a>: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
</code></pre>



<a id="0x1_evm_for_test_U64_MAX"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_U64_MAX">U64_MAX</a>: u256 = 18446744073709551615;
</code></pre>



<a id="0x1_evm_for_test_CONVERT_BASE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CONVERT_BASE">CONVERT_BASE</a>: u256 = 10000000000;
</code></pre>



<a id="0x1_evm_for_test_CALL_RESULT_OUT_OF_GAS"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_OUT_OF_GAS">CALL_RESULT_OUT_OF_GAS</a>: u8 = 2;
</code></pre>



<a id="0x1_evm_for_test_CALL_RESULT_REVERT"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_REVERT">CALL_RESULT_REVERT</a>: u8 = 1;
</code></pre>



<a id="0x1_evm_for_test_CALL_RESULT_SUCCESS"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>: u8 = 0;
</code></pre>



<a id="0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>: u8 = 3;
</code></pre>



<a id="0x1_evm_for_test_CHAIN_ID"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CHAIN_ID">CHAIN_ID</a>: u64 = 336;
</code></pre>



<a id="0x1_evm_for_test_EMPTY_ADDR"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_EMPTY_ADDR">EMPTY_ADDR</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [];
</code></pre>



<a id="0x1_evm_for_test_ERROR_CREATE_CONTRACT_COLLISION"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_CREATE_CONTRACT_COLLISION">ERROR_CREATE_CONTRACT_COLLISION</a>: u64 = 57;
</code></pre>



<a id="0x1_evm_for_test_ERROR_EXCEED_INITCODE_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_EXCEED_INITCODE_SIZE">ERROR_EXCEED_INITCODE_SIZE</a>: u64 = 55;
</code></pre>



<a id="0x1_evm_for_test_ERROR_INVALID_CHAINID"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_CHAINID">ERROR_INVALID_CHAINID</a>: u64 = 60;
</code></pre>



<a id="0x1_evm_for_test_ERROR_INVALID_OPCODE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_OPCODE">ERROR_INVALID_OPCODE</a>: u64 = 53;
</code></pre>



<a id="0x1_evm_for_test_ERROR_INVALID_PC"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_PC">ERROR_INVALID_PC</a>: u64 = 58;
</code></pre>



<a id="0x1_evm_for_test_ERROR_INVALID_RETURN_DATA_COPY_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_RETURN_DATA_COPY_SIZE">ERROR_INVALID_RETURN_DATA_COPY_SIZE</a>: u64 = 56;
</code></pre>



<a id="0x1_evm_for_test_ERROR_POP_STACK"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_POP_STACK">ERROR_POP_STACK</a>: u64 = 59;
</code></pre>



<a id="0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE">ERROR_STATIC_STATE_CHANGE</a>: u64 = 51;
</code></pre>



<a id="0x1_evm_for_test_MAX_CODE_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_MAX_CODE_SIZE">MAX_CODE_SIZE</a>: u256 = 24576;
</code></pre>



<a id="0x1_evm_for_test_MAX_DEPTH_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_MAX_DEPTH_SIZE">MAX_DEPTH_SIZE</a>: u64 = 1024;
</code></pre>



<a id="0x1_evm_for_test_MAX_INIT_CODE_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_MAX_INIT_CODE_SIZE">MAX_INIT_CODE_SIZE</a>: u256 = 49152;
</code></pre>



<a id="0x1_evm_for_test_MAX_STACK_SIZE"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_MAX_STACK_SIZE">MAX_STACK_SIZE</a>: u64 = 1024;
</code></pre>



<a id="0x1_evm_for_test_CHAIN_ID_BYTES"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_CHAIN_ID_BYTES">CHAIN_ID_BYTES</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [1, 80];
</code></pre>



<a id="0x1_evm_for_test_ONE_ADDR"></a>



<pre><code><b>const</b> <a href="evm_for_test.md#0x1_evm_for_test_ONE_ADDR">ONE_ADDR</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
</code></pre>



<a id="0x1_evm_for_test_revert"></a>

## Function `revert`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_revert">revert</a>(message: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>native</b> <b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_revert">revert</a>(
    message: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
);
</code></pre>



</details>

<a id="0x1_evm_for_test_initialize"></a>

## Function `initialize`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_initialize">initialize</a>(aptos_framework: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_initialize">initialize</a>(aptos_framework: &<a href="../../aptos-stdlib/../move-stdlib/doc/signer.md#0x1_signer">signer</a>) {
    <b>move_to</b>&lt;<a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a>&gt;(aptos_framework, <a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a> {
        exec_event: new_event_handle&lt;<a href="evm_for_test.md#0x1_evm_for_test_ExecResultEvent">ExecResultEvent</a>&gt;(aptos_framework)
    });
}
</code></pre>



</details>

<a id="0x1_evm_for_test_emit_event"></a>

## Function `emit_event`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_emit_event">emit_event</a>(state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_usage: u256, gas_refund: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_emit_event">emit_event</a>(state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_usage: u256, gas_refund: u256) <b>acquires</b> <a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a> {
    <b>let</b> exec_resource = <b>borrow_global_mut</b>&lt;<a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a>&gt;(@aptos_framework);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&state_root);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas_usage);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas_refund);
    <a href="event.md#0x1_event_emit_event">event::emit_event</a>(&<b>mut</b> exec_resource.exec_event, <a href="evm_for_test.md#0x1_evm_for_test_ExecResultEvent">ExecResultEvent</a> {
        state_root,
        gas_usage,
        gas_refund
    });
}
</code></pre>



</details>

<a id="0x1_evm_for_test_handle_tx_failed"></a>

## Function `handle_tx_failed`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>() <b>acquires</b> <a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a> {
    <b>let</b> state_root = <a href="evm_context.md#0x1_evm_context_calculate_root">evm_context::calculate_root</a>();
    <a href="evm_for_test.md#0x1_evm_for_test_emit_event">emit_event</a>(state_root, 0, 0);
}
</code></pre>



</details>

<a id="0x1_evm_for_test_run_test"></a>

## Function `run_test`



<pre><code><b>public</b> entry <b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_run_test">run_test</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, value_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, env_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_run_test">run_test</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                          storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                          access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                          from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                          <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                          data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                          gas_limit_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                          gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          value_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                          env_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                          tx_type: u8) <b>acquires</b> <a href="evm_for_test.md#0x1_evm_for_test_ExecResource">ExecResource</a> {
    <b>let</b> value = to_u256(value_bytes);
    <b>let</b> (access_address_count, access_slot_count) = pre_init(addresses, codes, nonces, balances, storage_keys, storage_values, access_addresses, access_keys);
    <b>let</b> gas_limit = to_u256(gas_limit_bytes);
    from = to_32bit(from);

    <b>let</b> run_state = &<b>mut</b> new_run_state(from, gas_price_data, gas_limit, &env_data, tx_type);
    <b>let</b> gas_price = get_gas_price(run_state);
    add_warm_address(from);
    add_warm_address(get_coinbase(run_state));
    <b>let</b> data_size = (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data) <b>as</b> u256);
    <b>let</b> base_cost = calc_base_gas(&data, access_address_count, access_slot_count) + 21000;
    <b>let</b> up_cost;
    <b>let</b> overflow;
    <b>if</b>(is_eip_1559(run_state)) {
        <b>if</b>(get_basefee(run_state) &gt; get_max_fee_per_gas(run_state) || get_max_priority_fee_per_gas(run_state) &gt; get_max_fee_per_gas(run_state)) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
            <b>return</b>
        };
        (up_cost, overflow) = mul(get_max_fee_per_gas(run_state), gas_limit);
        <b>if</b>(!overflow) {
            (up_cost, overflow) = add(up_cost, value);
        };
    } <b>else</b> {
        (up_cost, overflow) = mul(gas_limit, gas_price);
        <b>if</b>(!overflow) {
            (up_cost, overflow) = add(up_cost, value);
        };
    };
    <b>if</b>(overflow || gas_limit &gt; get_block_gas_limit(run_state) || gas_price &lt; get_basefee(run_state)) {
        <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
        <b>return</b>
    };

    <b>if</b>(<b>to</b> == <a href="evm_for_test.md#0x1_evm_for_test_EMPTY_ADDR">EMPTY_ADDR</a>) {
        <b>if</b>(data_size &gt; <a href="evm_for_test.md#0x1_evm_for_test_MAX_INIT_CODE_SIZE">MAX_INIT_CODE_SIZE</a>) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
            <b>return</b>
        };
        base_cost = base_cost + 2 * get_word_count(data_size) + 32000;
    };
    <b>if</b>(get_balance(from) &lt; up_cost || get_code_length(from) &gt; 0 || gas_limit &lt; base_cost) {
        <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
        <b>return</b>
    } <b>else</b> <b>if</b>(get_nonce(from) &gt;= <a href="evm_for_test.md#0x1_evm_for_test_U64_MAX">U64_MAX</a>) {
        <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
        <b>return</b>
    } <b>else</b> {
        sub_balance(from, gas_limit * gas_price);
        <b>let</b> out_of_gas = add_gas_usage(run_state, base_cost);
        <b>if</b>(out_of_gas) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_tx_failed">handle_tx_failed</a>();
            <b>return</b>
        };

        <b>if</b>(<b>to</b> == <a href="evm_for_test.md#0x1_evm_for_test_EMPTY_ADDR">EMPTY_ADDR</a>) {
            <b>let</b> evm_contract = get_contract_address(from, (get_nonce(from) <b>as</b> u64));
            <b>if</b>(is_contract_or_created_account(evm_contract)) {
                add_gas_usage(run_state, gas_limit);
            } <b>else</b> {
                add_checkpoint();
                <b>let</b> gas_left = get_gas_left(run_state);
                add_call_state(run_state, gas_left, <b>false</b>);
                <b>let</b> (result, bytes) = <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(from, evm_contract, data, x"", value, gas_left, run_state, <b>true</b>, <b>true</b>, 0);
                <b>if</b>(result == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>) {
                    set_code(evm_contract, bytes);
                }
            };
        } <b>else</b> {
            add_checkpoint();
            <b>to</b> = to_32bit(<b>to</b>);
            <b>if</b>(is_precompile_address(<b>to</b>)) {
                <a href="evm_for_test.md#0x1_evm_for_test_precompile">precompile</a>(<b>to</b>, data, gas_limit, run_state);
            } <b>else</b> {
                add_call_state(run_state, gas_limit - base_cost, <b>false</b>);
                <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(from, <b>to</b>, get_code(<b>to</b>), data, value, gas_limit - base_cost, run_state, <b>true</b>, <b>false</b>, 0);
            };
        };
        <b>let</b> gas_refund = get_gas_refund(run_state);
        <b>let</b> gas_left = get_gas_left(run_state);
        <b>let</b> gas_usage = gas_limit - gas_left;
        <b>if</b>(gas_refund &gt; gas_usage / 5) {
            gas_refund = gas_usage / 5
        };
        gas_usage = gas_usage - gas_refund;
        add_nonce(from);
        <b>let</b> basefee = get_basefee(run_state);
        <b>if</b>(basefee &lt; gas_price) {
            <b>let</b> miner_value = (gas_price - basefee) * gas_usage;
            add_balance(get_coinbase(run_state), miner_value);
        };
        add_balance(from, (gas_left + gas_refund) * gas_price);
        <b>let</b> state_root = <a href="evm_context.md#0x1_evm_context_calculate_root">evm_context::calculate_root</a>();
        <b>let</b> exec_cost = gas_usage - base_cost;
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&exec_cost);
        <a href="evm_for_test.md#0x1_evm_for_test_emit_event">emit_event</a>(state_root, gas_usage, gas_refund);

    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_handle_normal_revert"></a>

## Function `handle_normal_revert`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_normal_revert">handle_normal_revert</a>(run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_normal_revert">handle_normal_revert</a>(run_state: &<b>mut</b> RunState) {
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"normal revert"));
    revert_checkpoint();
    clear_gas_refund(run_state);
    commit_call_state(run_state);
}
</code></pre>



</details>

<a id="0x1_evm_for_test_handle_unexpect_revert"></a>

## Function `handle_unexpect_revert`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_unexpect_revert">handle_unexpect_revert</a>(run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>, error_code: &u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_unexpect_revert">handle_unexpect_revert</a>(run_state: &<b>mut</b> RunState, error_code: &u64) {
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"unexcept revert"));
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(error_code);
    revert_checkpoint();
    revert_call_state(run_state);
}
</code></pre>



</details>

<a id="0x1_evm_for_test_handle_commit"></a>

## Function `handle_commit`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_commit">handle_commit</a>(run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_handle_commit">handle_commit</a>(run_state: &<b>mut</b> RunState) {
    commit_latest_checkpoint();
    commit_call_state(run_state);
}
</code></pre>



</details>

<a id="0x1_evm_for_test_create_internal"></a>

## Function `create_internal`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create_internal">create_internal</a>(init_len: u256, current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, created_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, depth: u64, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, msg_value: u256, run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>, error_code: &<b>mut</b> u64): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create_internal">create_internal</a>(init_len: u256,
                    current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                    created_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                    depth: u64,
                    codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                    msg_value: u256,
                    run_state: &<b>mut</b> RunState,
                    error_code: &<b>mut</b> u64): u8 {
    set_ret_bytes(run_state, x"");
    <b>if</b>(init_len &gt; <a href="evm_for_test.md#0x1_evm_for_test_MAX_INIT_CODE_SIZE">MAX_INIT_CODE_SIZE</a> ) {
        *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_EXCEED_INITCODE_SIZE">ERROR_EXCEED_INITCODE_SIZE</a>;
        <b>return</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>
    } <b>else</b> <b>if</b>(get_is_static(run_state)) {
        *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE">ERROR_STATIC_STATE_CHANGE</a>;
        <b>return</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>
    } <b>else</b> {
        <b>let</b> gas_left = get_gas_left(run_state);
        <b>let</b> (call_gas_limit, _) = max_call_gas(gas_left, gas_left, msg_value, <b>false</b>);
        <b>if</b>(depth &gt;= <a href="evm_for_test.md#0x1_evm_for_test_MAX_DEPTH_SIZE">MAX_DEPTH_SIZE</a> ||
            get_balance(current_address) &lt; msg_value ||
            get_nonce(current_address) &gt;= <a href="evm_for_test.md#0x1_evm_for_test_U64_MAX">U64_MAX</a>) {
            <b>return</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>
        } <b>else</b> {
            add_nonce(current_address);
            add_warm_address(created_address);
            <b>if</b>(is_contract_or_created_account(created_address)) {
                add_gas_usage(run_state, call_gas_limit);
                <b>return</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>
            } <b>else</b> {
                add_call_state(run_state, call_gas_limit, <b>false</b>);
                add_checkpoint();
                <b>let</b> (create_res, bytes) = <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(current_address, created_address, codes, x"", msg_value, call_gas_limit, run_state, <b>true</b>, <b>true</b>, depth + 1);
                <b>if</b>(create_res == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>) {
                    set_code(created_address, bytes);
                } <b>else</b> <b>if</b>(create_res == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_REVERT">CALL_RESULT_REVERT</a>) {
                    set_ret_bytes(run_state, bytes);
                };

                <b>return</b> create_res
            }
        }
    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_create"></a>

## Function `create`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create">create</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, depth: u64, current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>, error_code: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create">create</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
            stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
            depth: u64,
            current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
            run_state: &<b>mut</b> RunState,
            error_code: &<b>mut</b> u64) {
    <b>let</b> msg_value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> codes = vector_slice_u256(*memory, pos, len);
    <b>let</b> new_evm_contract_addr = get_contract_address(current_address, (get_nonce(current_address) <b>as</b> u64));
    <b>let</b> result = <a href="evm_for_test.md#0x1_evm_for_test_create_internal">create_internal</a>(len, current_address, new_evm_contract_addr, depth, codes, msg_value, run_state, error_code);
    <b>if</b>(result == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, to_u256(new_evm_contract_addr));
    } <b>else</b> {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_create2"></a>

## Function `create2`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create2">create2</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, depth: u64, current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>, error_code: &<b>mut</b> u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_create2">create2</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
            stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
            depth: u64,
            current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
            run_state: &<b>mut</b> RunState,
            error_code: &<b>mut</b> u64) {
    <b>let</b> msg_value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
    <b>let</b> salt = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
    <b>let</b> codes = vector_slice_u256(*memory, pos, len);
    <b>let</b> p = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> p, x"ff");
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> p, vector_slice(current_address, 12, 20));
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> p, salt);
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> p, keccak256(codes));
    <b>let</b> new_evm_contract_addr = to_32bit(vector_slice(keccak256(p), 12, 20));
    <b>let</b> result = <a href="evm_for_test.md#0x1_evm_for_test_create_internal">create_internal</a>(len, current_address, new_evm_contract_addr, depth, codes, msg_value, run_state, error_code);
    <b>if</b>(result == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, to_u256(new_evm_contract_addr));
    } <b>else</b> {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_run"></a>

## Function `run`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256, gas_limit: u256, run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>, transfer_eth: bool, is_create: bool, depth: u64): (u8, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(
        sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
        <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
        <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
        data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
        value: u256,
        gas_limit: u256,
        run_state: &<b>mut</b> RunState,
        transfer_eth: bool,
        is_create: bool,
        depth: u64
    ): (u8, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {

    add_warm_address(<b>to</b>);

    <b>if</b>(is_create) {
        new_account(<b>to</b>, x"", 0, 1);
    };

    <b>if</b>(transfer_eth) {
        <b>if</b>(!transfer(sender, <b>to</b>, value)) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_normal_revert">handle_normal_revert</a>(run_state);
            <b>return</b> (<a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>, x"")
        };
    };

    // <b>let</b> to_account = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow_mut">simple_map::borrow_mut</a>(&<b>mut</b> trie, &<b>to</b>);

    <b>let</b> stack = &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u256&gt;();
    <b>let</b> memory = &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> len = (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="code.md#0x1_code">code</a>) <b>as</b> u256);
    <b>let</b> i: u256 = 0;
    <b>let</b> error_code = &<b>mut</b> 0;
    <b>let</b> valid_jumps = get_valid_jumps(&<a href="code.md#0x1_code">code</a>);
    <b>let</b> ret_value = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();

    <b>let</b> _events = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u256, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;();
    // <b>let</b> gas = 21000;
    <b>while</b> (i &lt; len) {
        // Fetch the current opcode from the bytecode.
        <b>let</b> opcode: u8 = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&<a href="code.md#0x1_code">code</a>, (i <b>as</b> u64));
        <b>let</b> gas = calc_exec_gas(opcode, <b>to</b>, stack, run_state, gas_limit, error_code);
        <b>let</b> out_of_gas = add_gas_usage(run_state, gas);
        <b>if</b>(*error_code &gt; 0 || out_of_gas) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_unexpect_revert">handle_unexpect_revert</a>(run_state, error_code);
            <b>return</b> (<b>if</b>(out_of_gas) <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_OUT_OF_GAS">CALL_RESULT_OUT_OF_GAS</a> <b>else</b> <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>, ret_value)
        };
        // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&i);
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&get_gas_left(run_state));

        // Handle each opcode according <b>to</b> the EVM specification.
        // The following is a simplified <a href="version.md#0x1_version">version</a> of the EVM execution engine,
        // handling only a subset of all possible opcodes.
        // Each branch in this <b>if</b>-<b>else</b> chain corresponds <b>to</b> a specific opcode,
        // and contains the logic for executing that opcode.
        // For example, the `add` opcode pops two elements from the stack,
        // adds them together, and pushes the result back onto the stack.
        // The `mul` opcode does the same but <b>with</b> multiplication, and so on.
        // Some opcodes, like `sstore`, have side effects, such <b>as</b> modifying contract storage.
        // The `jump` and `jumpi` opcodes alter the control flow of the execution.
        // The `call`, `create`, and `create2` opcodes are used for contract interactions.
        // The `log` opcodes are used for emitting events.
        // The function returns the output data of the execution when it encounters the `stop` or `<b>return</b>` opcode.

        // stop
        <b>if</b>(opcode == 0x00) {
            <b>break</b>
        }
        // <b>return</b>
        <b>else</b> <b>if</b>(opcode == 0xf3) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            ret_value = vector_slice_u256(*memory, pos, len);
            <b>break</b>
        }
            //add
        <b>else</b> <b>if</b>(opcode == 0x01) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> (c, _) = add(a, b);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, c);
            i = i + 1;
        }
            //mul
        <b>else</b> <b>if</b>(opcode == 0x02) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> (c, _) = mul(a, b);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, c);
            i = i + 1;
        }
            //sub
        <b>else</b> <b>if</b>(opcode == 0x03) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, sub(a, b));
            i = i + 1;
        }
            //div
        <b>else</b> <b>if</b>(opcode == 0x04) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, div(a, b));
            i = i + 1;
        }
            //sdiv
        <b>else</b> <b>if</b>(opcode == 0x05) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, sdiv(a, b));
            i = i + 1;
        }
            //mod
        <b>else</b> <b>if</b>(opcode == 0x06) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, mod(a, b));
            i = i + 1;
        }
            //smod
        <b>else</b> <b>if</b>(opcode == 0x07) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, smod(a, b));
            i = i + 1;
        }
            //addmod
        <b>else</b> <b>if</b>(opcode == 0x08) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> n = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, add_mod(a, b, n));
            i = i + 1;
        }
            //mulmod
        <b>else</b> <b>if</b>(opcode == 0x09) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> n = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, mul_mod(a, b, n));
            i = i + 1;
        }
            //exp
        <b>else</b> <b>if</b>(opcode == 0x0a) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, exp(a, b));
            i = i + 1;
        }
            //signextend
        <b>else</b> <b>if</b>(opcode == 0x0b) {
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(b &gt; 31) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            } <b>else</b> {
                <b>let</b> index = ((8 * b + 7) <b>as</b> u8);
                <b>let</b> mask = (1 &lt;&lt; index) - 1;
                <b>if</b>(((value &gt;&gt; index) & 1) == 0) {
                    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value & mask);
                } <b>else</b> {
                    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value | (<a href="evm_for_test.md#0x1_evm_for_test_U256_MAX">U256_MAX</a> - mask));
                };
            };
            i = i + 1;
        }
            //lt
        <b>else</b> <b>if</b>(opcode == 0x10) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(a &lt; b) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1)
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0)
            };
            i = i + 1;
        }
            //gt
        <b>else</b> <b>if</b>(opcode == 0x11) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(a &gt; b) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1)
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0)
            };
            i = i + 1;
        }
            //slt
        <b>else</b> <b>if</b>(opcode == 0x12) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, <b>if</b>(slt(a, b)) 1 <b>else</b> 0);
            i = i + 1;
        }
            //sgt
        <b>else</b> <b>if</b>(opcode == 0x13) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, <b>if</b>(sgt(a, b)) 1 <b>else</b> 0);
            i = i + 1;
        }
            //eq
        <b>else</b> <b>if</b>(opcode == 0x14) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(a == b) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1);
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            };
            i = i + 1;
        }
            //and
        <b>else</b> <b>if</b>(opcode == 0x16) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, a & b);
            i = i + 1;
        }
            //or
        <b>else</b> <b>if</b>(opcode == 0x17) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, a | b);
            i = i + 1;
        }
            //xor
        <b>else</b> <b>if</b>(opcode == 0x18) {
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, a ^ b);
            i = i + 1;
        }
            //not
        <b>else</b> <b>if</b>(opcode == 0x19) {
            // 10 1010
            // 6 0101
            <b>let</b> n = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, <a href="evm_for_test.md#0x1_evm_for_test_U256_MAX">U256_MAX</a> - n);
            i = i + 1;
        }
            //byte
        <b>else</b> <b>if</b>(opcode == 0x1a) {
            <b>let</b> ith = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> x = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(ith &gt;= 32) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, (x &gt;&gt; ((248 - ith * 8) <b>as</b> u8)) & 0xFF);
            };

            i = i + 1;
        }
            //shl
        <b>else</b> <b>if</b>(opcode == 0x1b) {
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(b &gt;= 256) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, a &lt;&lt; (b <b>as</b> u8));
            };
            i = i + 1;
        }
            //shr
        <b>else</b> <b>if</b>(opcode == 0x1c) {
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, shr(a, b));

            i = i + 1;
        }
            //sar
        <b>else</b> <b>if</b>(opcode == 0x1d) {
            <b>let</b> b = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> a = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, sar(a, b));
            i = i + 1;
        }
            //push0
        <b>else</b> <b>if</b>(opcode == 0x5f) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            i = i + 1;
        }
            // push1 -&gt; push32
        <b>else</b> <b>if</b>(opcode &gt;= 0x60 && opcode &lt;= 0x7f)  {
            <b>let</b> n = ((opcode - 0x60) <b>as</b> u256);
            <b>let</b> number = data_to_u256(<a href="code.md#0x1_code">code</a>, i + 1, n + 1);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, number);
            i = i + n + 2;
        }
            // pop
        <b>else</b> <b>if</b>(opcode == 0x50) {
            <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            i = i + 1
        }
            //<b>address</b>
        <b>else</b> <b>if</b>(opcode == 0x30) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, data_to_u256(<b>to</b>, 0, 32));
            i = i + 1;
        }
            //balance
        <b>else</b> <b>if</b>(opcode == 0x31) {
            <b>let</b> target = get_valid_ethereum_address(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_balance(target));
            i = i + 1;
        }
            //origin
        <b>else</b> <b>if</b>(opcode == 0x32) {
            <b>let</b> value = data_to_u256(get_origin(run_state), 0, 32);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            i = i + 1;
        }
            //caller
        <b>else</b> <b>if</b>(opcode == 0x33) {
            <b>let</b> value = data_to_u256(sender, 0, 32);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            i = i + 1;
        }
            // callvalue
        <b>else</b> <b>if</b>(opcode == 0x34) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            i = i + 1;
        }
            //calldataload
        <b>else</b> <b>if</b>(opcode == 0x35) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, data_to_u256(data, pos, 32));
            i = i + 1;
        }
            //calldatasize
        <b>else</b> <b>if</b>(opcode == 0x36) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data) <b>as</b> u256));
            i = i + 1;
        }
            //calldatacopy
        <b>else</b> <b>if</b>(opcode == 0x37) {
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> d_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            copy_to_memory(memory, m_pos, d_pos, len, data);
            i = i + 1
        }
            //codesizeF
        <b>else</b> <b>if</b>(opcode == 0x38) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="code.md#0x1_code">code</a>) <b>as</b> u256));
            i = i + 1
        }
            //codecopy
        <b>else</b> <b>if</b>(opcode == 0x39) {
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> d_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            copy_to_memory(memory, m_pos, d_pos, len, <a href="code.md#0x1_code">code</a>);

            i = i + 1
        }
            //gasprice
        <b>else</b> <b>if</b>(opcode == 0x3a) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_gas_price(run_state));
            i = i + 1
        }
            //extcodesize
        <b>else</b> <b>if</b>(opcode == 0x3b) {
            <b>let</b> target = get_valid_ethereum_address(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> <a href="code.md#0x1_code">code</a> = get_code(target);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&<a href="code.md#0x1_code">code</a>) <b>as</b> u256));
            i = i + 1;
        }
            //extcodecopy
        <b>else</b> <b>if</b>(opcode == 0x3c) {
            <b>let</b> target = get_valid_ethereum_address(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> <a href="code.md#0x1_code">code</a> = get_code(target);
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> d_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            copy_to_memory(memory, m_pos, d_pos, len, <a href="code.md#0x1_code">code</a>);
            i = i + 1;
        }
            //returndatasize
        <b>else</b> <b>if</b>(opcode == 0x3d) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_ret_size(run_state));
            i = i + 1;
        }
            //returndatacopy
        <b>else</b> <b>if</b>(opcode == 0x3e) {
            // mstore()
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> d_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> bytes = vector_slice_u256(get_ret_bytes(run_state), d_pos, len);
            mstore(memory, m_pos, bytes);

            i = i + 1;
        }
            //extcodehash
        <b>else</b> <b>if</b>(opcode == 0x3f) {
            <b>let</b> target = get_valid_ethereum_address(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>if</b>(exist_account(target)) {
                <b>let</b> <a href="code.md#0x1_code">code</a> = get_code(target);
                <b>let</b> <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_hash">hash</a> = keccak256(<a href="code.md#0x1_code">code</a>);
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, to_u256(<a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_hash">hash</a>));
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            };
            i = i + 1;
        }
            //blockhash
        <b>else</b> <b>if</b>(opcode == 0x40) {
            <b>let</b> _num = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            i = i + 1;
        }
            //coinbase
        <b>else</b> <b>if</b>(opcode == 0x41) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, to_u256(get_coinbase(run_state)));
            i = i + 1;
        }
            //<a href="timestamp.md#0x1_timestamp">timestamp</a>
        <b>else</b> <b>if</b>(opcode == 0x42) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_timestamp(run_state));
            i = i + 1;
        }
            //number
        <b>else</b> <b>if</b>(opcode == 0x43) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_block_number(run_state));
            i = i + 1;
        }
            //difficulty
        <b>else</b> <b>if</b>(opcode == 0x44) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, to_u256(get_random(run_state)));
            i = i + 1;
        }
            //gaslimit
        <b>else</b> <b>if</b>(opcode == 0x45) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_block_gas_limit(run_state));
            i = i + 1;
        }
            //chainid
        <b>else</b> <b>if</b>(opcode == 0x46) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1);
            i = i + 1
        }
            //self balance
        <b>else</b> <b>if</b>(opcode == 0x47) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_balance(<b>to</b>));
            i = i + 1;
        }
            //self balance
        <b>else</b> <b>if</b>(opcode == 0x48) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_basefee(run_state));
            i = i + 1;
        }
            // mload
        <b>else</b> <b>if</b>(opcode == 0x51) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, data_to_u256(vector_slice(*memory, pos, 32), 0, 32));
            i = i + 1;
        }
            // mstore
        <b>else</b> <b>if</b>(opcode == 0x52) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            mstore(memory, pos, u256_to_data(value));
            i = i + 1;

        }
            //mstore8
        <b>else</b> <b>if</b>(opcode == 0x53) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            expand_to_pos(memory, pos + 1);
            *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(memory, pos) = ((value & 0xff) <b>as</b> u8);
            // mstore(memory, pos, u256_to_data(value & 0xff));
            i = i + 1;

        }
            // sload
        <b>else</b> <b>if</b>(opcode == 0x54) {
            <b>let</b> key = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_state(<b>to</b>, key));
            i = i + 1;
        }
            // sstore
        <b>else</b> <b>if</b>(opcode == 0x55) {
            <b>let</b> key = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(get_is_static(run_state)) {
                *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE">ERROR_STATIC_STATE_CHANGE</a>;
            } <b>else</b> {
                set_state(<b>to</b>, key, value);
            };

            i = i + 1;
        }
            // pc
        <b>else</b> <b>if</b>(opcode == 0x58) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, i);
            i = i + 1;
        }

            // MSIZE
        <b>else</b> <b>if</b>(opcode == 0x59) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, (((<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(memory) + 31) / 32 * 32) <b>as</b> u256));
            i = i + 1;
        }
            //dup1 -&gt; dup16
        <b>else</b> <b>if</b>(opcode &gt;= 0x80 && opcode &lt;= 0x8f) {
            <b>let</b> size = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
            <b>let</b> pos = ((opcode - 0x80 + 1) <b>as</b> u64);
            <b>if</b>(size &lt; pos) {
                *error_code = 1;
            } <b>else</b> {
                <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack, size - pos);
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            };
            i = i + 1;
        }
            //swap1 -&gt; swap16
        <b>else</b> <b>if</b>(opcode &gt;= 0x90 && opcode &lt;= 0x9f) {
            <b>let</b> size = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
            <b>let</b> pos = ((opcode - 0x90 + 2) <b>as</b> u64);
            <b>if</b>(size &lt; pos) {
                *error_code = 1;
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_swap">vector::swap</a>(stack, size - 1, size - pos);
            };
            i = i + 1;
        }
            //iszero
        <b>else</b> <b>if</b>(opcode == 0x15) {
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(value == 0) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1)
            } <b>else</b> {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0)
            };
            i = i + 1;
        }
            //jump
        <b>else</b> <b>if</b>(opcode == 0x56) {
            i = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(i &gt;= len || !*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&valid_jumps, (i <b>as</b> u64))) {
                *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_PC">ERROR_INVALID_PC</a>;
            }
        }
            //jumpi
        <b>else</b> <b>if</b>(opcode == 0x57) {
            <b>let</b> dest = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> condition = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(condition &gt; 0) {
                i = dest;
                <b>if</b>(i &gt;= len || !*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&valid_jumps, (i <b>as</b> u64))) {
                    *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_PC">ERROR_INVALID_PC</a>;
                }
            } <b>else</b> {
                i = i + 1
            };
        }
            //gas
        <b>else</b> <b>if</b>(opcode == 0x5a) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_gas_left(run_state));
            i = i + 1
        }
            //jump dest (no action, <b>continue</b> execution)
        <b>else</b> <b>if</b>(opcode == 0x5b) {
            i = i + 1
        }
            //TLOAD
        <b>else</b> <b>if</b>(opcode == 0x5c) {
            <b>let</b> key = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, get_transient_storage(<b>to</b>, key));

            i = i + 1
        }
            //TSTORE
        <b>else</b> <b>if</b>(opcode == 0x5d) {
            <b>let</b> key = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> value = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>if</b>(get_is_static(run_state)) {
                *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE">ERROR_STATIC_STATE_CHANGE</a>
            } <b>else</b> {
                put_transient_storage(<b>to</b>, key, value);
            };

            i = i + 1
        }
            //MCOPY
        <b>else</b> <b>if</b>(opcode == 0x5e) {
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> d_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> bytes = vector_slice_u256(*memory, d_pos, len);
            <b>if</b>(len &gt; 0) {
                <b>let</b> new_size = <b>if</b>(d_pos &gt; m_pos) d_pos + len <b>else</b> m_pos + len;
                expand_to_pos(memory, (new_size <b>as</b> u64));
                mstore(memory, (m_pos <b>as</b> u64), bytes);
            };
            i = i + 1;
        }
            //sha3
        <b>else</b> <b>if</b>(opcode == 0x20) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> bytes = vector_slice_u256(*memory, pos, len);
            // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&value);
            <b>let</b> value = data_to_u256(keccak256(bytes), 0, 32);
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, value);
            i = i + 1
        }
            //call 0xf1 callcode 0xf2 static call 0xfa delegate call 0xf4
        <b>else</b> <b>if</b>(opcode == 0xf1 || opcode == 0xf2 || opcode == 0xfa || opcode == 0xf4) {
            <b>let</b> is_static = <b>if</b> (opcode == 0xfa) <b>true</b> <b>else</b> <b>false</b>;
            <b>let</b> gas_left = get_gas_left(run_state);
            <b>let</b> gas = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> evm_dest_addr = get_valid_ethereum_address(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> need_stipend = <b>if</b> (opcode == 0xf1 || opcode == 0xf2) <b>true</b> <b>else</b> <b>false</b>;
            <b>let</b> msg_value = <b>if</b> (opcode == 0xf1 || opcode == 0xf2) <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code) <b>else</b> <b>if</b>(opcode == 0xf4) value <b>else</b> 0;
            <b>let</b> (call_gas_limit, gas_stipend) = max_call_gas(gas_left, gas, msg_value, need_stipend);
            <b>if</b>(gas_stipend &gt; 0) {
                add_gas_left(run_state, gas_stipend);
            };
            <b>let</b> m_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> m_len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> ret_pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> ret_len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> params = read_memory(memory, m_pos, m_len);
            <b>let</b> (call_from, call_to, code_address) = <a href="evm_for_test.md#0x1_evm_for_test_get_call_info">get_call_info</a>(sender, <b>to</b>, evm_dest_addr, opcode);
            <b>let</b> is_precompile = is_precompile_address(evm_dest_addr);
            <b>let</b> transfer_eth = <b>if</b>((opcode == 0xf1 || opcode == 0xf2) && msg_value &gt; 0) <b>true</b> <b>else</b> <b>false</b>;
            set_ret_bytes(run_state, x"");
            <b>if</b>(get_is_static(run_state) && transfer_eth && call_from != call_to) {
                *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_STATIC_STATE_CHANGE">ERROR_STATIC_STATE_CHANGE</a>;
            } <b>else</b> <b>if</b>(depth &gt;= <a href="evm_for_test.md#0x1_evm_for_test_MAX_DEPTH_SIZE">MAX_DEPTH_SIZE</a>){
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
            } <b>else</b> {
                <b>if</b>(is_precompile) {
                    <b>let</b> (success, bytes) = <a href="evm_for_test.md#0x1_evm_for_test_precompile">precompile</a>(code_address, params, call_gas_limit, run_state);
                    <b>if</b>(success) {
                        <b>if</b>(transfer_eth) {
                            transfer(call_from, call_to, msg_value);
                        };
                        set_ret_bytes(run_state, bytes);
                        write_call_output(memory, ret_pos, ret_len, bytes);
                    };
                    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, <b>if</b>(success) 1 <b>else</b> 0);
                } <b>else</b> <b>if</b> (exist_contract(code_address)) {
                    <b>let</b> dest_code = get_code(code_address);
                    add_call_state(run_state, call_gas_limit, is_static);
                    add_checkpoint();
                    <b>let</b> (call_res, bytes) = <a href="evm_for_test.md#0x1_evm_for_test_run">run</a>(call_from, call_to, dest_code, params, msg_value, call_gas_limit, run_state, transfer_eth, <b>false</b>, depth + 1);
                    <b>if</b>(call_res == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a> || call_res == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_REVERT">CALL_RESULT_REVERT</a>) {
                        set_ret_bytes(run_state, bytes);
                        // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>()
                        write_call_output(memory, ret_pos, ret_len, bytes);
                    };
                    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack,  <b>if</b>(call_res == <a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>) 1 <b>else</b> 0);
                } <b>else</b> {
                    <b>if</b>(msg_value &gt; 0 && transfer_eth && !transfer(call_from, call_to, msg_value)) {
                        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
                    } <b>else</b> {
                        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 1);
                    }
                };
            };
            // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&opcode);
            i = i + 1
        }
            //create
        <b>else</b> <b>if</b>(opcode == 0xf0) {
            <a href="evm_for_test.md#0x1_evm_for_test_create">create</a>(memory, stack, depth, <b>to</b>, run_state, error_code);
            i = i + 1
        }
            //create2
        <b>else</b> <b>if</b>(opcode == 0xf5) {
            <a href="evm_for_test.md#0x1_evm_for_test_create2">create2</a>(memory, stack, depth, <b>to</b>, run_state, error_code);
            i = i + 1
        }
            //revert
        <b>else</b> <b>if</b>(opcode == 0xfd) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code);
            <a href="evm_for_test.md#0x1_evm_for_test_handle_normal_revert">handle_normal_revert</a>(run_state);
            ret_value = vector_slice_u256(*memory, pos, len);

            <b>return</b> (<a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_REVERT">CALL_RESULT_REVERT</a>, ret_value)
        }
            //log0
        <b>else</b> <b>if</b>(opcode == 0xa0) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> data = vector_slice(*memory, pos, len);
            add_log(<b>to</b>, data, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[]);
            i = i + 1
        }
            //log1
        <b>else</b> <b>if</b>(opcode == 0xa1) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> data = vector_slice(*memory, pos, len);
            <b>let</b> topic0 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            add_log(<b>to</b>, data, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[topic0]);
            i = i + 1
        }
            //log2
        <b>else</b> <b>if</b>(opcode == 0xa2) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> data = vector_slice(*memory, pos, len);
            <b>let</b> topic0 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic1 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            add_log(<b>to</b>, data, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[topic0, topic1]);
            i = i + 1
        }
            //log3
        <b>else</b> <b>if</b>(opcode == 0xa3) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> data = vector_slice(*memory, pos, len);
            <b>let</b> topic0 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic1 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic2 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            add_log(<b>to</b>, data, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[topic0, topic1, topic2]);
            i = i + 1
        }
            //log4
        <b>else</b> <b>if</b>(opcode == 0xa4) {
            <b>let</b> pos = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> len = <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack, error_code);
            <b>let</b> data = vector_slice(*memory, pos, len);
            <b>let</b> topic0 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic1 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic2 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            <b>let</b> topic3 = u256_to_data(<a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack, error_code));
            add_log(<b>to</b>, data, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[topic0, topic1, topic2, topic3]);
            i = i + 1
        }
            //invalid opcode
        <b>else</b> <b>if</b>(opcode == 0xfe){
            *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_INVALID_OPCODE">ERROR_INVALID_OPCODE</a>;
            i = i + 1
        }
        //     //blob blob <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_hash">hash</a>
        // <b>else</b> <b>if</b>(opcode == 0x49 || opcode == 0x4a || opcode == 0xff) {
        //     <b>assert</b>!(<b>false</b>, OPCODE_UNIMPLEMENT);
        //     // <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(stack, 0);
        //     i = i + 1;
        // }
        <b>else</b> {
            <b>assert</b>!(<b>false</b>, (opcode <b>as</b> u64));
        };
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(stack);
        // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack));

        <b>if</b>(*error_code &gt; 0 || <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack) &gt; <a href="evm_for_test.md#0x1_evm_for_test_MAX_STACK_SIZE">MAX_STACK_SIZE</a>) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_unexpect_revert">handle_unexpect_revert</a>(run_state, error_code);
            <b>return</b> (<a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>, ret_value)
        }
    };

    <b>if</b>(is_create) {
        <b>let</b> code_size = (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&ret_value) <b>as</b> u256);
        <b>let</b> out_of_gas = add_gas_usage(run_state, 200 * code_size);
        <b>if</b>(code_size &gt; <a href="evm_for_test.md#0x1_evm_for_test_MAX_CODE_SIZE">MAX_CODE_SIZE</a> || (code_size &gt; 0 && (*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&ret_value, 0)) == 0xef) || out_of_gas) {
            <a href="evm_for_test.md#0x1_evm_for_test_handle_unexpect_revert">handle_unexpect_revert</a>(run_state, error_code);
            <b>return</b> (<a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_UNEXPECT_ERROR">CALL_RESULT_UNEXPECT_ERROR</a>, x"")
        };
    };
    <a href="evm_for_test.md#0x1_evm_for_test_handle_commit">handle_commit</a>(run_state);

    (<a href="evm_for_test.md#0x1_evm_for_test_CALL_RESULT_SUCCESS">CALL_RESULT_SUCCESS</a>, ret_value)
}
</code></pre>



</details>

<a id="0x1_evm_for_test_get_call_info"></a>

## Function `get_call_info`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_get_call_info">get_call_info</a>(sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, target_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, opcode: u8): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_get_call_info">get_call_info</a>(sender: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, current_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, target_address: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, opcode: u8): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>if</b>(opcode == 0xf1) {
        (current_address, target_address, target_address)
    } <b>else</b> <b>if</b>(opcode == 0xf2) {
        (current_address, current_address, target_address)
    } <b>else</b> <b>if</b>(opcode == 0xf4) {
        (sender, current_address, target_address)
    } <b>else</b> {
        (current_address, target_address, target_address)
    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_precompile"></a>

## Function `precompile`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_precompile">precompile</a>(<b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit: u256, run_state: &<b>mut</b> <a href="global_state_for_test.md#0x1_evm_global_state_for_test_RunState">evm_global_state_for_test::RunState</a>): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_precompile">precompile</a>(<b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit: u256, run_state: &<b>mut</b> RunState): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)  {
    <b>let</b> (success, res, gas) = run_precompile(<b>to</b>, calldata, gas_limit);
    <b>if</b>(gas &gt; gas_limit) {
        success = <b>false</b>;
        gas = gas_limit;
    };
    add_gas_usage(run_state, gas);
    (success, res)
}
</code></pre>



</details>

<a id="0x1_evm_for_test_pop_stack_u64"></a>

## Function `pop_stack_u64`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_pop_stack_u64">pop_stack_u64</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u64 {
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack) &gt; 0) {
        (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(stack) <b>as</b> u64)
    } <b>else</b> {
        *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_POP_STACK">ERROR_POP_STACK</a>;
        0
    }
}
</code></pre>



</details>

<a id="0x1_evm_for_test_pop_stack"></a>

## Function `pop_stack`



<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test.md#0x1_evm_for_test_pop_stack">pop_stack</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u256 {
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack) &gt; 0) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_pop_back">vector::pop_back</a>(stack)
    } <b>else</b> {
        *error_code = <a href="evm_for_test.md#0x1_evm_for_test_ERROR_POP_STACK">ERROR_POP_STACK</a>;
        0
    }
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
