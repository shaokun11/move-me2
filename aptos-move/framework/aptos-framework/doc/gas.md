
<a id="0x1_evm_gas"></a>

# Module `0x1::evm_gas`



-  [Constants](#@Constants_0)
-  [Function `access_address`](#0x1_evm_gas_access_address)
-  [Function `calc_memory_expand`](#0x1_evm_gas_calc_memory_expand)
-  [Function `calc_memory_expand_internal`](#0x1_evm_gas_calc_memory_expand_internal)
-  [Function `calc_mcopy_gas`](#0x1_evm_gas_calc_mcopy_gas)
-  [Function `calc_mstore_gas`](#0x1_evm_gas_calc_mstore_gas)
-  [Function `calc_mstore8_gas`](#0x1_evm_gas_calc_mstore8_gas)
-  [Function `calc_sload_gas`](#0x1_evm_gas_calc_sload_gas)
-  [Function `calc_sstore_gas`](#0x1_evm_gas_calc_sstore_gas)
-  [Function `calc_exp_gas`](#0x1_evm_gas_calc_exp_gas)
-  [Function `calc_call_gas`](#0x1_evm_gas_calc_call_gas)
-  [Function `calc_return_data_copy_gas`](#0x1_evm_gas_calc_return_data_copy_gas)
-  [Function `calc_code_copy_gas`](#0x1_evm_gas_calc_code_copy_gas)
-  [Function `calc_address_access_gas`](#0x1_evm_gas_calc_address_access_gas)
-  [Function `calc_ext_code_copy_gas`](#0x1_evm_gas_calc_ext_code_copy_gas)
-  [Function `calc_keccak256_gas`](#0x1_evm_gas_calc_keccak256_gas)
-  [Function `calc_log_gas`](#0x1_evm_gas_calc_log_gas)
-  [Function `calc_create_gas`](#0x1_evm_gas_calc_create_gas)
-  [Function `calc_create2_gas`](#0x1_evm_gas_calc_create2_gas)
-  [Function `calc_self_destruct_gas`](#0x1_evm_gas_calc_self_destruct_gas)
-  [Function `max_call_gas`](#0x1_evm_gas_max_call_gas)
-  [Function `calc_base_gas`](#0x1_evm_gas_calc_base_gas)
-  [Function `calc_exec_gas`](#0x1_evm_gas_calc_exec_gas)


<pre><code><b>use</b> <a href="arithmetic.md#0x1_evm_arithmetic">0x1::evm_arithmetic</a>;
<b>use</b> <a href="global_state.md#0x1_evm_global_state">0x1::evm_global_state</a>;
<b>use</b> <a href="trie.md#0x1_evm_trie">0x1::evm_trie</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_gas_CallNewAccount"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_CallNewAccount">CallNewAccount</a>: u256 = 25000;
</code></pre>



<a id="0x1_evm_gas_CallStipend"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_CallStipend">CallStipend</a>: u256 = 2300;
</code></pre>



<a id="0x1_evm_gas_CallValueTransfer"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_CallValueTransfer">CallValueTransfer</a>: u256 = 9000;
</code></pre>



<a id="0x1_evm_gas_ColdAccountAccess"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_ColdAccountAccess">ColdAccountAccess</a>: u256 = 2600;
</code></pre>



<a id="0x1_evm_gas_Coldsload"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_Coldsload">Coldsload</a>: u256 = 2100;
</code></pre>



<a id="0x1_evm_gas_Copy"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_Copy">Copy</a>: u256 = 3;
</code></pre>



<a id="0x1_evm_gas_ExpByte"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_ExpByte">ExpByte</a>: u256 = 50;
</code></pre>



<a id="0x1_evm_gas_INVALID_OPCODE"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_INVALID_OPCODE">INVALID_OPCODE</a>: u64 = 13;
</code></pre>



<a id="0x1_evm_gas_InitCodeWordCost"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_InitCodeWordCost">InitCodeWordCost</a>: u256 = 2;
</code></pre>



<a id="0x1_evm_gas_Keccak256Word"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_Keccak256Word">Keccak256Word</a>: u256 = 6;
</code></pre>



<a id="0x1_evm_gas_LogData"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_LogData">LogData</a>: u256 = 8;
</code></pre>



<a id="0x1_evm_gas_LogTopic"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_LogTopic">LogTopic</a>: u256 = 375;
</code></pre>



<a id="0x1_evm_gas_OUT_OF_GAS"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>: u64 = 11;
</code></pre>



<a id="0x1_evm_gas_STACK_UNDERFLOW"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>: u64 = 12;
</code></pre>



<a id="0x1_evm_gas_SstoreCleanGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreCleanGasEIP2200">SstoreCleanGasEIP2200</a>: u256 = 2900;
</code></pre>



<a id="0x1_evm_gas_SstoreCleanRefundEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreCleanRefundEIP2200">SstoreCleanRefundEIP2200</a>: u256 = 2800;
</code></pre>



<a id="0x1_evm_gas_SstoreClearRefundEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreClearRefundEIP2200">SstoreClearRefundEIP2200</a>: u256 = 4800;
</code></pre>



<a id="0x1_evm_gas_SstoreDirtyGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreDirtyGasEIP2200">SstoreDirtyGasEIP2200</a>: u256 = 100;
</code></pre>



<a id="0x1_evm_gas_SstoreInitGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreInitGasEIP2200">SstoreInitGasEIP2200</a>: u256 = 20000;
</code></pre>



<a id="0x1_evm_gas_SstoreInitRefundEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreInitRefundEIP2200">SstoreInitRefundEIP2200</a>: u256 = 19900;
</code></pre>



<a id="0x1_evm_gas_SstoreNoopGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreNoopGasEIP2200">SstoreNoopGasEIP2200</a>: u256 = 100;
</code></pre>



<a id="0x1_evm_gas_SstoreSentryGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreSentryGasEIP2200">SstoreSentryGasEIP2200</a>: u256 = 2300;
</code></pre>



<a id="0x1_evm_gas_Warmstorageread"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_Warmstorageread">Warmstorageread</a>: u256 = 100;
</code></pre>



<a id="0x1_evm_gas_access_address"></a>

## Function `access_address`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, trie: &<b>mut</b> Trie): u256 {
    <b>if</b>(is_cold_address(<b>address</b>, trie)) <a href="gas.md#0x1_evm_gas_ColdAccountAccess">ColdAccountAccess</a> <b>else</b> <a href="gas.md#0x1_evm_gas_Warmstorageread">Warmstorageread</a>
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_memory_expand"></a>

## Function `calc_memory_expand`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, pos: u64, size: u64, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, pos: u64, size: u64, run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; pos || len &lt; size) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> out_offset = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - pos);
    <b>let</b> out_size = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - size);

    <b>if</b>(out_size == 0) {
        <b>return</b> 0
    };
    <b>let</b> (new_size, overflow) = add(out_offset, out_size);
    <b>if</b>(overflow) {
        *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
        <b>return</b> 0
    };
    <a href="gas.md#0x1_evm_gas_calc_memory_expand_internal">calc_memory_expand_internal</a>(new_size, run_state, gas_limit, error_code)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_memory_expand_internal"></a>

## Function `calc_memory_expand_internal`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand_internal">calc_memory_expand_internal</a>(new_memory_size: u256, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand_internal">calc_memory_expand_internal</a>(new_memory_size: u256, run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>if</b>(new_memory_size == 0) {
        <b>return</b> 0
    };
    <b>let</b> old_memory_word_size = get_memory_word_size(run_state);
    <b>let</b> new_memory_word_size = get_word_count(new_memory_size);

    <b>if</b>(new_memory_word_size &lt;= old_memory_word_size) {
        <b>return</b> 0
    };
    // To prevent overflow
    <b>if</b>(gas_limit / 3 &lt; new_memory_word_size) {
        *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
        <b>return</b> 0
    };

    <b>let</b> old_memory_cost = get_memory_cost(run_state);
    <b>let</b> new_memory_cost = (new_memory_word_size * new_memory_word_size / 512) + 3 * new_memory_word_size;
    <b>if</b>(new_memory_cost &gt; old_memory_cost) {
        set_memory_cost(run_state, new_memory_cost);
        new_memory_cost = new_memory_cost - old_memory_cost;
    };
    set_memory_word_size(run_state, new_memory_word_size);
    new_memory_cost
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_mcopy_gas"></a>

## Function `calc_mcopy_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mcopy_gas">calc_mcopy_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mcopy_gas">calc_mcopy_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                    run_state: &<b>mut</b> RunState,
                    gas_limit: u256,
                   error_code: &<b>mut</b> u64): u256 {
    <b>let</b> gas = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 3) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>let</b> word_size = get_word_count(length);
    gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 1, 3, run_state, gas_limit, error_code);
    gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 2, 3, run_state, gas_limit, error_code);
    gas = gas +  word_size * 3;

    gas + 3
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_mstore_gas"></a>

## Function `calc_mstore_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mstore_gas">calc_mstore_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mstore_gas">calc_mstore_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                    run_state: &<b>mut</b> RunState,
                    gas_limit: u256,
                    error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 1) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> offset = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1);
    <a href="gas.md#0x1_evm_gas_calc_memory_expand_internal">calc_memory_expand_internal</a>(offset + 32, run_state, gas_limit, error_code)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_mstore8_gas"></a>

## Function `calc_mstore8_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mstore8_gas">calc_mstore8_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_mstore8_gas">calc_mstore8_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                     run_state: &<b>mut</b> RunState,
                     gas_limit: u256,
                     error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>let</b> offset = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1);
    <a href="gas.md#0x1_evm_gas_calc_memory_expand_internal">calc_memory_expand_internal</a>(offset + 1, run_state, gas_limit, error_code)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_sload_gas"></a>

## Function `calc_sload_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sload_gas">calc_sload_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sload_gas">calc_sload_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                   stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                   trie: &<b>mut</b> Trie,
                   error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 1) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1);
    <b>let</b> (is_cold_slot, _) = get_cache(<b>address</b>, key, trie);
    <b>if</b>(is_cold_slot) <a href="gas.md#0x1_evm_gas_Coldsload">Coldsload</a> <b>else</b> <a href="gas.md#0x1_evm_gas_Warmstorageread">Warmstorageread</a>
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_sstore_gas"></a>

## Function `calc_sstore_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                    stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                    trie: &<b>mut</b> Trie,
                    run_state: &<b>mut</b> RunState,
                    error_code: &<b>mut</b> u64): u256 {
    <b>if</b>(get_gas_left(run_state) &lt;= <a href="gas.md#0x1_evm_gas_SstoreSentryGasEIP2200">SstoreSentryGasEIP2200</a>) {
        *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
        <b>return</b> 0
    };

    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 2) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };

    <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1);
    <b>let</b> (is_cold_slot, origin) = get_cache(<b>address</b>, key, trie);
    <b>let</b> current = get_state(<b>address</b>, key, trie);
    <b>let</b> new = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);
    <b>let</b> cold_cost = <b>if</b>(is_cold_slot) <a href="gas.md#0x1_evm_gas_Coldsload">Coldsload</a> <b>else</b> 0;
    // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(get)
    <b>let</b> gas_cost = cold_cost;

    <b>if</b>(current == new) {
        //sstoreNoopGasEIP2200
        gas_cost = gas_cost + <a href="gas.md#0x1_evm_gas_SstoreNoopGasEIP2200">SstoreNoopGasEIP2200</a>
    } <b>else</b> {
        <b>if</b>(origin == current) {
            <b>if</b>(origin == 0) {
                //sstoreInitGasEIP2200
                gas_cost = gas_cost + <a href="gas.md#0x1_evm_gas_SstoreInitGasEIP2200">SstoreInitGasEIP2200</a>
            } <b>else</b> {
                <b>if</b>(new == 0) {
                    add_gas_refund(run_state, <a href="gas.md#0x1_evm_gas_SstoreClearRefundEIP2200">SstoreClearRefundEIP2200</a>)
                };
                gas_cost = gas_cost + <a href="gas.md#0x1_evm_gas_SstoreCleanGasEIP2200">SstoreCleanGasEIP2200</a>
            }
        } <b>else</b> {
            gas_cost = gas_cost + <a href="gas.md#0x1_evm_gas_SstoreDirtyGasEIP2200">SstoreDirtyGasEIP2200</a>;
            <b>if</b>(origin != 0) {
                <b>if</b>(current == 0) {
                    sub_gas_refund(run_state, <a href="gas.md#0x1_evm_gas_SstoreClearRefundEIP2200">SstoreClearRefundEIP2200</a>)
                } <b>else</b> <b>if</b>(new == 0) {
                    add_gas_refund(run_state, <a href="gas.md#0x1_evm_gas_SstoreClearRefundEIP2200">SstoreClearRefundEIP2200</a>)
                }
            };
            <b>if</b>(new == origin) {
                <b>if</b>(origin == 0) {
                    add_gas_refund(run_state, <a href="gas.md#0x1_evm_gas_SstoreInitRefundEIP2200">SstoreInitRefundEIP2200</a>)
                } <b>else</b> {
                    add_gas_refund(run_state, <a href="gas.md#0x1_evm_gas_SstoreCleanRefundEIP2200">SstoreCleanRefundEIP2200</a>)
                }
            }
        }
    };

    gas_cost
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_exp_gas"></a>

## Function `calc_exp_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exp_gas">calc_exp_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exp_gas">calc_exp_gas</a>(stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 2) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> exponent = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);
    <b>if</b>(exponent == 0) {
        <b>return</b> 0
    };

    <b>let</b> byte_length = u256_bytes_length(exponent);
    <a href="gas.md#0x1_evm_gas_ExpByte">ExpByte</a> * byte_length
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_call_gas"></a>

## Function `calc_call_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, opcode: u8, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                  opcode: u8,
                  trie: &<b>mut</b> Trie, run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> gas = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>let</b> size = <b>if</b>(opcode == 0xf1 || opcode == 0xf2) 7 <b>else</b> 6;
    <b>if</b>(len &lt; size) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> <b>address</b> = get_valid_ethereum_address(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2));
    <b>if</b>(opcode == 0xf1 || opcode == 0xf2) {
        <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);

        <b>if</b>(opcode == 0xf1 && value &gt; 0 && !exist_account(<b>address</b>, trie)) {
            gas = gas + <a href="gas.md#0x1_evm_gas_CallNewAccount">CallNewAccount</a>;
        };
        <b>if</b>(value &gt; 0) {
            gas = gas + <a href="gas.md#0x1_evm_gas_CallValueTransfer">CallValueTransfer</a>;
        };
        gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 4, 5, run_state, gas_limit, error_code);
        gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 6, 7, run_state, gas_limit, error_code);
    } <b>else</b> {
        gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 3, 4, run_state, gas_limit, error_code);
        gas = gas +  <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 5, 6, run_state, gas_limit, error_code);
    };

    gas = gas + <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, trie);

    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_return_data_copy_gas"></a>

## Function `calc_return_data_copy_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_return_data_copy_gas">calc_return_data_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_return_data_copy_gas">calc_return_data_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                       run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 3) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> data_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>let</b> data_pos = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);
    <b>let</b> (data_size, overflow) = add(data_length, data_pos);
    <b>if</b>(overflow || data_size &gt; get_ret_size(run_state)) {
        *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
        <b>return</b> 0
    };

    <a href="gas.md#0x1_evm_gas_calc_code_copy_gas">calc_code_copy_gas</a>(stack, run_state, gas_limit, error_code)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_code_copy_gas"></a>

## Function `calc_code_copy_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_code_copy_gas">calc_code_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_code_copy_gas">calc_code_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                       run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 3) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> gas = 0;
    <b>let</b> data_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>if</b>(data_length &gt; 0) {
        <b>let</b> word_count = get_word_count(data_length);
        gas = gas + word_count * <a href="gas.md#0x1_evm_gas_Copy">Copy</a>;
        // Prevent overflow here; <b>if</b> the result is greater than gasLimit, <b>return</b> gasLimit directly
        <b>if</b>(gas &gt; gas_limit) {
            *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
            <b>return</b> 0
        };
        gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 1, 3, run_state, gas_limit, error_code);
    };
    gas + 3
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_address_access_gas"></a>

## Function `calc_address_access_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_address_access_gas">calc_address_access_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_address_access_gas">calc_address_access_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                            trie: &<b>mut</b> Trie,
                            error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len == 0) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> <b>address</b> = get_valid_ethereum_address(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1));
    <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, trie)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_ext_code_copy_gas"></a>

## Function `calc_ext_code_copy_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_ext_code_copy_gas">calc_ext_code_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_ext_code_copy_gas">calc_ext_code_copy_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                           run_state: &<b>mut</b> RunState,
                           trie: &<b>mut</b> Trie,
                           gas_limit: u256,
                           error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 4) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> gas = 0;
    <b>let</b> data_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 4);
    <b>if</b>(data_length &gt; 0) {
        <b>let</b> word_count = get_word_count(data_length);
        gas = gas + word_count * <a href="gas.md#0x1_evm_gas_Copy">Copy</a>;
        // Prevent overflow here; <b>if</b> the result is greater than gasLimit, <b>return</b> gasLimit directly
        <b>if</b>(gas &gt; gas_limit) {
            *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
            <b>return</b> 0
        };
        gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 2, 4, run_state, gas_limit, error_code);
    };
    <b>let</b> <b>address</b> = get_valid_ethereum_address(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1));
    gas = gas + <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, trie);
    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_keccak256_gas"></a>

## Function `calc_keccak256_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_keccak256_gas">calc_keccak256_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_keccak256_gas">calc_keccak256_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                 run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 2) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> gas = 0;
    <b>let</b> data_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);

    <b>if</b>(data_length &gt; 0) {
        <b>let</b> word_count = get_word_count(data_length);
        gas = gas + word_count * <a href="gas.md#0x1_evm_gas_Keccak256Word">Keccak256Word</a>;
        gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 1, 2, run_state, gas_limit, error_code);
    };

    gas + 30
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_log_gas"></a>

## Function `calc_log_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_log_gas">calc_log_gas</a>(opcode: u8, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_log_gas">calc_log_gas</a>(opcode: u8, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                       run_state: &<b>mut</b> RunState, gas_limit: u256, error_code: &<b>mut</b> u64): u256 {
    <b>let</b> topic_count = ((opcode - 0xa0) <b>as</b> u256);
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 2) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> gas = 0;
    <b>let</b> data_length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);
    gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 1, 2, run_state, gas_limit, error_code);
    <b>if</b>(data_length &gt; gas_limit) {
        *error_code = <a href="gas.md#0x1_evm_gas_OUT_OF_GAS">OUT_OF_GAS</a>;
        <b>return</b> 0
    };
    gas = gas + <a href="gas.md#0x1_evm_gas_LogTopic">LogTopic</a> * topic_count + data_length * <a href="gas.md#0x1_evm_gas_LogData">LogData</a> + <a href="gas.md#0x1_evm_gas_LogTopic">LogTopic</a>;
    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_create_gas"></a>

## Function `calc_create_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_create_gas">calc_create_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_create_gas">calc_create_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                    stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                    trie: &<b>mut</b> Trie,
                    run_state: &<b>mut</b> RunState,
                    gas_limit: u256,
                    error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 3) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>let</b> gas = 0;
    <b>let</b> words = get_word_count(length);
    gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 2, 3, run_state, gas_limit, error_code);
    gas = gas + words * <a href="gas.md#0x1_evm_gas_InitCodeWordCost">InitCodeWordCost</a>;

    <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, trie);

    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_create2_gas"></a>

## Function `calc_create2_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_create2_gas">calc_create2_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_create2_gas">calc_create2_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                     stack: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                     trie: &<b>mut</b> Trie,
                     run_state: &<b>mut</b> RunState,
                     gas_limit: u256,
                     error_code: &<b>mut</b> u64): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>let</b> length = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>let</b> gas = 0;
    <b>let</b> words = get_word_count(length);
    gas = gas + <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 2, 3, run_state, gas_limit, error_code);
    gas = gas + words * <a href="gas.md#0x1_evm_gas_InitCodeWordCost">InitCodeWordCost</a>;
    gas = gas + words * <a href="gas.md#0x1_evm_gas_Keccak256Word">Keccak256Word</a>;
    <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, trie);

    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_self_destruct_gas"></a>

## Function `calc_self_destruct_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_self_destruct_gas">calc_self_destruct_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_self_destruct_gas">calc_self_destruct_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                           stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                           trie: &<b>mut</b> Trie,
                           error_code: &<b>mut</b> u64): u256 {
    <b>let</b> balance = get_balance(<b>address</b>, trie);
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>if</b>(len &lt; 1) {
        *error_code = <a href="gas.md#0x1_evm_gas_STACK_UNDERFLOW">STACK_UNDERFLOW</a>;
        <b>return</b> 0
    };
    <b>let</b> <b>to</b> = u256_to_data(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1));
    <b>let</b> gas = 0;
    <b>if</b>(balance &gt; 0) {
        <b>if</b>(balance &gt; 0 && !exist_account(<b>to</b>, trie)) {
            gas = gas + <a href="gas.md#0x1_evm_gas_CallNewAccount">CallNewAccount</a>;
        };
    };
    gas = gas + <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>to</b>, trie);
    gas + 5000
}
</code></pre>



</details>

<a id="0x1_evm_gas_max_call_gas"></a>

## Function `max_call_gas`



<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_max_call_gas">max_call_gas</a>(gas_left: u256, gas_limit: u256, value: u256, need_stipend: bool): (u256, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_max_call_gas">max_call_gas</a>(gas_left: u256, gas_limit: u256, value: u256, need_stipend: bool): (u256, u256) {
    <b>let</b> gas_allow = gas_left - gas_left / 64;
    gas_limit = <b>if</b>(gas_limit &gt; gas_allow) gas_allow <b>else</b> gas_limit;
    <b>let</b> gas_stipend = 0;
    <b>if</b>(need_stipend && value &gt; 0) {
        gas_stipend = gas_stipend + <a href="gas.md#0x1_evm_gas_CallStipend">CallStipend</a>;
        gas_limit = gas_limit + <a href="gas.md#0x1_evm_gas_CallStipend">CallStipend</a>;
    };
    (gas_limit, gas_stipend)
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_base_gas"></a>

## Function `calc_base_gas`



<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_base_gas">calc_base_gas</a>(memory: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, access_address_count: u256, access_slot_count: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_base_gas">calc_base_gas</a>(memory: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, access_address_count: u256, access_slot_count: u256): u256 {
    <b>let</b> gas = 0;

    for_each(*memory, |elem| gas = gas + <b>if</b>(elem == 0) 4 <b>else</b> 16);
    gas + access_address_count * 2400 + access_slot_count * 1900
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_exec_gas"></a>

## Function `calc_exec_gas`



<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exec_gas">calc_exec_gas</a>(opcode: u8, <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="global_state.md#0x1_evm_global_state_RunState">evm_global_state::RunState</a>, trie: &<b>mut</b> <a href="trie.md#0x1_evm_trie_Trie">evm_trie::Trie</a>, gas_limit: u256, error_code: &<b>mut</b> u64): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exec_gas">calc_exec_gas</a>(opcode :u8,
                         <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;,
                         stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;,
                         run_state: &<b>mut</b> RunState,
                         trie: &<b>mut</b> Trie,
                         gas_limit: u256,
                         error_code: &<b>mut</b> u64
                        ): u256 {
    // print_opcode(opcode);
    <b>let</b> gas = <b>if</b> (opcode == 0x00) {
        // STOP
        0
    } <b>else</b> <b>if</b> (opcode == 0x01) {
        // ADD
        3
    } <b>else</b> <b>if</b> (opcode == 0x02) {
        // MUL
        5
    } <b>else</b> <b>if</b> (opcode == 0x03) {
        // SUB
        3
    } <b>else</b> <b>if</b> (opcode == 0x04) {
        // DIV
        5
    } <b>else</b> <b>if</b> (opcode == 0x05) {
        // SDIV
        5
    } <b>else</b> <b>if</b> (opcode == 0x06) {
        // MOD
        5
    } <b>else</b> <b>if</b> (opcode == 0x07) {
        // SMOD
        5
    } <b>else</b> <b>if</b> (opcode == 0x08) {
        // ADDMOD
        8
    } <b>else</b> <b>if</b> (opcode == 0x09) {
        // MULMOD
        8
    } <b>else</b> <b>if</b> (opcode == 0x0A) {
        // EXP (dynamic gas)
        <a href="gas.md#0x1_evm_gas_calc_exp_gas">calc_exp_gas</a>(stack, error_code) + 10
    } <b>else</b> <b>if</b> (opcode == 0x0B) {
        // SIGNEXTEND
        5
    } <b>else</b> <b>if</b> (opcode == 0x10) {
        // LT
        3
    } <b>else</b> <b>if</b> (opcode == 0x11) {
        // GT
        3
    } <b>else</b> <b>if</b> (opcode == 0x12) {
        // SLT
        3
    } <b>else</b> <b>if</b> (opcode == 0x13) {
        // SGT
        3
    } <b>else</b> <b>if</b> (opcode == 0x14) {
        // EQ
        3
    } <b>else</b> <b>if</b> (opcode == 0x15) {
        // ISZERO
        3
    } <b>else</b> <b>if</b> (opcode == 0x16) {
        // AND
        3
    } <b>else</b> <b>if</b> (opcode == 0x17) {
        // OR
        3
    } <b>else</b> <b>if</b> (opcode == 0x18) {
        // XOR
        3
    } <b>else</b> <b>if</b> (opcode == 0x19) {
        // NOT
        3
    } <b>else</b> <b>if</b> (opcode == 0x1A) {
        // BYTE
        3
    } <b>else</b> <b>if</b> (opcode == 0x1B) {
        // SHL
        3
    } <b>else</b> <b>if</b> (opcode == 0x1C) {
        // SHR
        3
    } <b>else</b> <b>if</b> (opcode == 0x1D) {
        // SAR
        3
    } <b>else</b> <b>if</b> (opcode == 0x30) {
        // ADDRESS
        2
    } <b>else</b> <b>if</b> (opcode == 0x32) {
        // ORIGIN
        2
    } <b>else</b> <b>if</b> (opcode == 0x33) {
        // CALLER
        2
    } <b>else</b> <b>if</b> (opcode == 0x34) {
        // CALLVALUE
        2
    } <b>else</b> <b>if</b> (opcode == 0x35) {
        // CALLDATALOAD
        3
    } <b>else</b> <b>if</b> (opcode == 0x36) {
        // CALLDATASIZE
        2
    } <b>else</b> <b>if</b> (opcode == 0x38) {
        // CODESIZE
        2
    } <b>else</b> <b>if</b> (opcode == 0x3A) {
        // GASPRICE
        2
    } <b>else</b> <b>if</b> (opcode == 0x3D) {
        // RETURNDATASIZE
        2
    } <b>else</b> <b>if</b> (opcode == 0x40) {
        // BLOCKHASH
        20
    } <b>else</b> <b>if</b> (opcode == 0x41) {
        // COINBASE
        2
    } <b>else</b> <b>if</b> (opcode == 0x42) {
        // TIMESTAMP
        2
    } <b>else</b> <b>if</b> (opcode == 0x43) {
        // NUMBER
        2
    } <b>else</b> <b>if</b> (opcode == 0x44) {
        // PREVRANDAO
        2
    } <b>else</b> <b>if</b> (opcode == 0x45) {
        // GASLIMIT
        2
    } <b>else</b> <b>if</b> (opcode == 0x46) {
        // CHAINID
        2
    } <b>else</b> <b>if</b> (opcode == 0x47) {
        // SELFBALANCE
        5
    } <b>else</b> <b>if</b> (opcode == 0x48) {
        // BASEFEE
        2
    } <b>else</b> <b>if</b> (opcode == 0x49) {
        // BLOBHASH
        3
    } <b>else</b> <b>if</b> (opcode == 0x4A) {
        // BLOBBASEFEE
        2
    } <b>else</b> <b>if</b> (opcode == 0x50) {
        // POP
        2
    } <b>else</b> <b>if</b> (opcode == 0x56) {
        // JUMP
        8
    } <b>else</b> <b>if</b> (opcode == 0x57) {
        // JUMPI
        10
    } <b>else</b> <b>if</b> (opcode == 0x58) {
        // PC
        2
    } <b>else</b> <b>if</b> (opcode == 0x59) {
        // MSIZE
        2
    } <b>else</b> <b>if</b> (opcode == 0x5A) {
        // GAS
        2
    } <b>else</b> <b>if</b> (opcode == 0x5B) {
        // JUMPDEST
        1
    } <b>else</b> <b>if</b> (opcode == 0x5C) {
        // TLOAD
        100
    } <b>else</b> <b>if</b> (opcode == 0x5D) {
        // TSTORE
        100
    } <b>else</b> <b>if</b> (opcode == 0x5F) {
        // PUSH0
        2
    } <b>else</b> <b>if</b> (opcode &gt;= 0x60 && opcode &lt;= 0x7F) {
        // PUSH1 <b>to</b> PUSH32
        3
    } <b>else</b> <b>if</b> (opcode &gt;= 0x80 && opcode &lt;= 0x8F) {
        // DUP1 <b>to</b> DUP16
        3
    } <b>else</b> <b>if</b> (opcode &gt;= 0x90 && opcode &lt;= 0x9F) {
        // SWAP1 <b>to</b> SWAP16
        3
    } <b>else</b> <b>if</b> (opcode == 0x20) {
        // KECCAK256
        <a href="gas.md#0x1_evm_gas_calc_keccak256_gas">calc_keccak256_gas</a>(stack, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x31) {
        // BALANCE
        <a href="gas.md#0x1_evm_gas_calc_address_access_gas">calc_address_access_gas</a>(stack, trie, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x3f || opcode == 0x3b) {
        // EXTCODEHASH
        <a href="gas.md#0x1_evm_gas_calc_address_access_gas">calc_address_access_gas</a>(stack, trie, error_code)
    } <b>else</b> <b>if</b> (opcode == 0xf0) {
        // CREATE
        <a href="gas.md#0x1_evm_gas_calc_create_gas">calc_create_gas</a>(<b>address</b>, stack, trie, run_state, gas_limit, error_code) + 32000
    } <b>else</b> <b>if</b> (opcode == 0xf5) {
        // CREATE2
        <a href="gas.md#0x1_evm_gas_calc_create2_gas">calc_create2_gas</a>(<b>address</b>, stack, trie, run_state, gas_limit, error_code) + 32000
    } <b>else</b> <b>if</b>(opcode == 0x53){
        <a href="gas.md#0x1_evm_gas_calc_mstore8_gas">calc_mstore8_gas</a>(stack, run_state, gas_limit, error_code) + 3
    } <b>else</b> <b>if</b> (opcode == 0x51 || opcode == 0x52) {
        // MSTORE & MLOAD
        <a href="gas.md#0x1_evm_gas_calc_mstore_gas">calc_mstore_gas</a>(stack, run_state, gas_limit, error_code) + 3
    } <b>else</b> <b>if</b> (opcode == 0xf1 || opcode == 0xf2 || opcode == 0xf4 || opcode == 0xfa) {
        // CALL
        <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack, opcode, trie, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0xf3 || opcode == 0xfd) {
        // RETURN & REVERT
        <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(stack, 1, 2, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x54) {
        // SLOAD
        <a href="gas.md#0x1_evm_gas_calc_sload_gas">calc_sload_gas</a>(<b>address</b>, stack, trie, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x55) {
        // SSTORE
        <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>, stack, trie, run_state, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x5e) {
        // MCOPY
        <a href="gas.md#0x1_evm_gas_calc_mcopy_gas">calc_mcopy_gas</a>(stack, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b>(opcode == 0x3e){
        //RETURNDATACOPY
        <a href="gas.md#0x1_evm_gas_calc_return_data_copy_gas">calc_return_data_copy_gas</a>(stack, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x37 || opcode == 0x39) {
        // CALLDATACOPY & CODECOPY
        <a href="gas.md#0x1_evm_gas_calc_code_copy_gas">calc_code_copy_gas</a>(stack, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0x3c) {
        // EXTCODECOPY
        <a href="gas.md#0x1_evm_gas_calc_ext_code_copy_gas">calc_ext_code_copy_gas</a>(stack, run_state, trie, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode &gt;= 0xa0 && opcode &lt;= 0xa4) {
        // LOG
        <a href="gas.md#0x1_evm_gas_calc_log_gas">calc_log_gas</a>(opcode, stack, run_state, gas_limit, error_code)
    } <b>else</b> <b>if</b> (opcode == 0xff) {
        // SELF DESTRUCT
        <a href="gas.md#0x1_evm_gas_calc_self_destruct_gas">calc_self_destruct_gas</a>(<b>address</b>, stack, trie, error_code)
    }
    <b>else</b> {
        *error_code = <a href="gas.md#0x1_evm_gas_INVALID_OPCODE">INVALID_OPCODE</a>;
        0
    };
    // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas);
    gas
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
