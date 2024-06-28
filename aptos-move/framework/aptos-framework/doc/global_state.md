
<a id="0x1_evm_global_state"></a>

# Module `0x1::evm_global_state`



-  [Constants](#@Constants_0)
-  [Function `new_run_state`](#0x1_evm_global_state_new_run_state)
-  [Function `get_memory_cost`](#0x1_evm_global_state_get_memory_cost)
-  [Function `set_memory_cost`](#0x1_evm_global_state_set_memory_cost)
-  [Function `add_gas_usage`](#0x1_evm_global_state_add_gas_usage)
-  [Function `add_gas_refund`](#0x1_evm_global_state_add_gas_refund)
-  [Function `sub_gas_refund`](#0x1_evm_global_state_sub_gas_refund)
-  [Function `get_gas_usage`](#0x1_evm_global_state_get_gas_usage)
-  [Function `get_gas_refund`](#0x1_evm_global_state_get_gas_refund)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map">0x1::simple_map</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_global_state_GasRefund"></a>



<pre><code><b>const</b> <a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>: u64 = 2;
</code></pre>



<a id="0x1_evm_global_state_GasUsage"></a>



<pre><code><b>const</b> <a href="global_state.md#0x1_evm_global_state_GasUsage">GasUsage</a>: u64 = 0;
</code></pre>



<a id="0x1_evm_global_state_HighestMemoryCost"></a>



<pre><code><b>const</b> <a href="global_state.md#0x1_evm_global_state_HighestMemoryCost">HighestMemoryCost</a>: u64 = 1;
</code></pre>



<a id="0x1_evm_global_state_new_run_state"></a>

## Function `new_run_state`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(): <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_new_run_state">new_run_state</a>(): SimpleMap&lt;u64, u256&gt; {
    <b>let</b> state = <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_new">simple_map::new</a>&lt;u64, u256&gt;();
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> state, <a href="global_state.md#0x1_evm_global_state_GasUsage">GasUsage</a>, 0);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_add">simple_map::add</a>(&<b>mut</b> state, <a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>, 0);
    <a href="global_state.md#0x1_evm_global_state_set_memory_cost">set_memory_cost</a>(&<b>mut</b> state, 0);
    state
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_memory_cost"></a>

## Function `get_memory_cost`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_cost">get_memory_cost</a>(run_state: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_memory_cost">get_memory_cost</a>(run_state: &SimpleMap&lt;u64, u256&gt;) : u256 {
    *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_HighestMemoryCost">HighestMemoryCost</a>)
}
</code></pre>



</details>

<a id="0x1_evm_global_state_set_memory_cost"></a>

## Function `set_memory_cost`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_cost">set_memory_cost</a>(run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;, cost: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_set_memory_cost">set_memory_cost</a>(run_state: &<b>mut</b> SimpleMap&lt;u64, u256&gt;, cost: u256) {
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(run_state, <a href="global_state.md#0x1_evm_global_state_HighestMemoryCost">HighestMemoryCost</a>, cost);
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_gas_usage"></a>

## Function `add_gas_usage`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_usage">add_gas_usage</a>(run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;, cost: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_usage">add_gas_usage</a>(run_state: &<b>mut</b> SimpleMap&lt;u64, u256&gt;, cost: u256) {
    <b>let</b> current_gas_usage = *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_GasUsage">GasUsage</a>);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(run_state, <a href="global_state.md#0x1_evm_global_state_GasUsage">GasUsage</a>, current_gas_usage + cost);
}
</code></pre>



</details>

<a id="0x1_evm_global_state_add_gas_refund"></a>

## Function `add_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_refund">add_gas_refund</a>(run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;, cost: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_add_gas_refund">add_gas_refund</a>(run_state: &<b>mut</b> SimpleMap&lt;u64, u256&gt;, cost: u256) {
    <b>let</b> current_gas_refund = *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(run_state, <a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>, current_gas_refund + cost);
}
</code></pre>



</details>

<a id="0x1_evm_global_state_sub_gas_refund"></a>

## Function `sub_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_sub_gas_refund">sub_gas_refund</a>(run_state: &<b>mut</b> <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;, cost: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_sub_gas_refund">sub_gas_refund</a>(run_state: &<b>mut</b> SimpleMap&lt;u64, u256&gt;, cost: u256) {
    <b>let</b> current_gas_refund = *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>);
    <a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_upsert">simple_map::upsert</a>(run_state, <a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>, current_gas_refund - cost);
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_gas_usage"></a>

## Function `get_gas_usage`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_usage">get_gas_usage</a>(run_state: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_usage">get_gas_usage</a>(run_state: &SimpleMap&lt;u64, u256&gt;): u256 {
    *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_GasUsage">GasUsage</a>)
}
</code></pre>



</details>

<a id="0x1_evm_global_state_get_gas_refund"></a>

## Function `get_gas_refund`



<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_refund">get_gas_refund</a>(run_state: &<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_SimpleMap">simple_map::SimpleMap</a>&lt;u64, u256&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="global_state.md#0x1_evm_global_state_get_gas_refund">get_gas_refund</a>(run_state: &SimpleMap&lt;u64, u256&gt;): u256 {
    *<a href="../../aptos-stdlib/doc/simple_map.md#0x1_simple_map_borrow">simple_map::borrow</a>(run_state, &<a href="global_state.md#0x1_evm_global_state_GasRefund">GasRefund</a>)
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
