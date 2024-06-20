
<a id="0x1_evm_gas"></a>

# Module `0x1::evm_gas`



-  [Constants](#@Constants_0)
-  [Function `access_address`](#0x1_evm_gas_access_address)
-  [Function `calc_memory_expand`](#0x1_evm_gas_calc_memory_expand)
-  [Function `calc_sstore_gas`](#0x1_evm_gas_calc_sstore_gas)
-  [Function `calc_call_gas`](#0x1_evm_gas_calc_call_gas)
-  [Function `calc_base_gas`](#0x1_evm_gas_calc_base_gas)
-  [Function `calc_exec_gas`](#0x1_evm_gas_calc_exec_gas)


<pre><code><b>use</b> <a href="../../aptos-stdlib/doc/debug.md#0x1_debug">0x1::debug</a>;
<b>use</b> <a href="cache.md#0x1_evm_cache">0x1::evm_cache</a>;
<b>use</b> <a href="global_state.md#0x1_evm_global_state">0x1::evm_global_state</a>;
<b>use</b> <a href="storage.md#0x1_evm_storage">0x1::evm_storage</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_gas_CallNewAccount"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_CallNewAccount">CallNewAccount</a>: u64 = 25000;
</code></pre>



<a id="0x1_evm_gas_CallValueTransfer"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_CallValueTransfer">CallValueTransfer</a>: u64 = 9000;
</code></pre>



<a id="0x1_evm_gas_ColdAccountAccess"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_ColdAccountAccess">ColdAccountAccess</a>: u64 = 2600;
</code></pre>



<a id="0x1_evm_gas_Coldsload"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_Coldsload">Coldsload</a>: u64 = 2100;
</code></pre>



<a id="0x1_evm_gas_SstoreCleanGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreCleanGasEIP2200">SstoreCleanGasEIP2200</a>: u64 = 2900;
</code></pre>



<a id="0x1_evm_gas_SstoreDirtyGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreDirtyGasEIP2200">SstoreDirtyGasEIP2200</a>: u64 = 100;
</code></pre>



<a id="0x1_evm_gas_SstoreInitGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreInitGasEIP2200">SstoreInitGasEIP2200</a>: u64 = 20000;
</code></pre>



<a id="0x1_evm_gas_SstoreNoopGasEIP2200"></a>



<pre><code><b>const</b> <a href="gas.md#0x1_evm_gas_SstoreNoopGasEIP2200">SstoreNoopGasEIP2200</a>: u64 = 100;
</code></pre>



<a id="0x1_evm_gas_access_address"></a>

## Function `access_address`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;): u64 {
    <b>if</b>(is_cold_address(<b>address</b>, cache)) <a href="gas.md#0x1_evm_gas_ColdAccountAccess">ColdAccountAccess</a> <b>else</b> 0
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_memory_expand"></a>

## Function `calc_memory_expand`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(new_memory_size: u64, run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u64&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(new_memory_size: u64, run_state: &<b>mut</b> SimpleMap&lt;u64, u64&gt;): u64 {
    <b>let</b> old_memory_cost = get_memory_cost(run_state);
    <b>let</b> new_memory_size_word = (new_memory_size + 31) / 32;
    <b>let</b> new_memory_cost = (new_memory_size_word * new_memory_size_word / 512) + 3 * new_memory_size_word;
    <b>if</b>(new_memory_cost &gt; old_memory_cost) {
        set_memory_cost(run_state, new_memory_cost);
        <b>return</b> new_memory_cost - old_memory_cost
    };

    0
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_sstore_gas"></a>

## Function `calc_sstore_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, TestAccount&gt;): u64 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 1);
    <b>let</b> (_, is_cold_slot, origin) = get_cache(<b>address</b>, key, cache, trie);
    <b>let</b> current = get_storage(<b>address</b>, key, trie);
    <b>let</b> new = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&origin);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&current);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&new);
    <b>let</b> cold_cost = <b>if</b>(is_cold_slot) <a href="gas.md#0x1_evm_gas_Coldsload">Coldsload</a> <b>else</b> 0;

    <b>if</b>(current == new) {
        //sstoreNoopGasEIP2200
        <b>return</b> <a href="gas.md#0x1_evm_gas_SstoreNoopGasEIP2200">SstoreNoopGasEIP2200</a> + cold_cost
    } <b>else</b> <b>if</b>(origin == current) {
        <b>if</b>(origin == 0) {
            //sstoreInitGasEIP2200
            <b>return</b> <a href="gas.md#0x1_evm_gas_SstoreInitGasEIP2200">SstoreInitGasEIP2200</a> + cold_cost
        } <b>else</b> {
            <b>return</b> <a href="gas.md#0x1_evm_gas_SstoreCleanGasEIP2200">SstoreCleanGasEIP2200</a> + cold_cost
        }
    };

    <a href="gas.md#0x1_evm_gas_SstoreDirtyGasEIP2200">SstoreDirtyGasEIP2200</a> + cold_cost
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_call_gas"></a>

## Function `calc_call_gas`



<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;, run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u64&gt;, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;, run_state: &<b>mut</b> SimpleMap&lt;u64, u64&gt;, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, TestAccount&gt;): u64 {
    <b>let</b> gas = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(stack);
    <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 3);
    <b>let</b> <b>address</b> = u256_to_data(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 2));
    <b>if</b>(value &gt; 0 && !exist_account(<b>address</b>, trie)) {
        gas = gas + <a href="gas.md#0x1_evm_gas_CallNewAccount">CallNewAccount</a>;
    };
    <b>if</b>(value &gt; 0) {
        gas = gas + <a href="gas.md#0x1_evm_gas_CallValueTransfer">CallValueTransfer</a>;
    };

    <b>let</b> out_offset = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 6);
    <b>let</b> out_size = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(stack,len - 7);
    <b>let</b> memory_cost = <a href="gas.md#0x1_evm_gas_calc_memory_expand">calc_memory_expand</a>(((out_offset + out_size) <b>as</b> u64), run_state);

    gas = gas + <a href="gas.md#0x1_evm_gas_access_address">access_address</a>(<b>address</b>, cache);

    gas + memory_cost
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_base_gas"></a>

## Function `calc_base_gas`



<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_base_gas">calc_base_gas</a>(memory: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_base_gas">calc_base_gas</a>(memory: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u64 {
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(memory);
    <b>let</b> gas = 0;

    for_each(*memory, |elem| gas = gas + <b>if</b>(elem == 0) 4 <b>else</b> 16);

    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas);
    gas
}
</code></pre>



</details>

<a id="0x1_evm_gas_calc_exec_gas"></a>

## Function `calc_exec_gas`



<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exec_gas">calc_exec_gas</a>(opcode: u8, <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u64&gt;, cache: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u256, u256&gt;&gt;, trie: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="storage.md#0x1_evm_storage_TestAccount">evm_storage::TestAccount</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="gas.md#0x1_evm_gas_calc_exec_gas">calc_exec_gas</a>(opcode :u8, <b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, stack: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, run_state: &<b>mut</b> SimpleMap&lt;u64, u64&gt;, cache: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, SimpleMap&lt;u256, u256&gt;&gt;, trie: &<b>mut</b> SimpleMap&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, TestAccount&gt;) {
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&opcode);
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
        // Additional gas cost depends on the exponent
        10
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
    } <b>else</b> <b>if</b> (opcode == 0x31) {
        // BALANCE
        700
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
    } <b>else</b> <b>if</b> (opcode == 0x3B) {
        // EXTCODESIZE
        700
    } <b>else</b> <b>if</b> (opcode == 0x3D) {
        // RETURNDATASIZE
        2
    } <b>else</b> <b>if</b> (opcode == 0x3F) {
        // EXTCODEHASH
        700
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
    } <b>else</b> <b>if</b> (opcode == 0x51) {
        // MLOAD
        3
    } <b>else</b> <b>if</b> (opcode == 0x52) {
        // MSTORE
        3
    } <b>else</b> <b>if</b> (opcode == 0x53) {
        // MSTORE8
        3
    } <b>else</b> <b>if</b> (opcode == 0x54) {
        // SLOAD
        2100
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
    } <b>else</b> <b>if</b> (opcode == 0xf1) {
        // CALL
        <a href="gas.md#0x1_evm_gas_calc_call_gas">calc_call_gas</a>(stack, cache, run_state, trie)
    } <b>else</b> <b>if</b> (opcode == 0x55) {
        // SSTORE
        <a href="gas.md#0x1_evm_gas_calc_sstore_gas">calc_sstore_gas</a>(<b>address</b>, stack, cache, trie)
    } <b>else</b> {
        <b>assert</b>!(<b>false</b>, (opcode <b>as</b> u64));
        0
    };
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas);
    add_gas_usage(run_state, gas);

}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
