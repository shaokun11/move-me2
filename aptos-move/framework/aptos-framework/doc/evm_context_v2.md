
<a id="0x1_evm_context_v2"></a>

# Module `0x1::evm_context_v2`



-  [Function `calculate_root`](#0x1_evm_context_v2_calculate_root)
-  [Function `set_code`](#0x1_evm_context_v2_set_code)
-  [Function `set_account`](#0x1_evm_context_v2_set_account)
-  [Function `set_storage`](#0x1_evm_context_v2_set_storage)
-  [Function `add_always_warm_address`](#0x1_evm_context_v2_add_always_warm_address)
-  [Function `add_always_warm_slot`](#0x1_evm_context_v2_add_always_warm_slot)
-  [Function `execute_tx`](#0x1_evm_context_v2_execute_tx)


<pre><code><b>use</b> <a href="env_for_test.md#0x1_env_for_test">0x1::env_for_test</a>;
</code></pre>



<a id="0x1_evm_context_v2_calculate_root"></a>

## Function `calculate_root`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_calculate_root">calculate_root</a>(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_calculate_root">calculate_root</a>(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_context_v2_set_code"></a>

## Function `set_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_v2_set_account"></a>

## Function `set_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_account">set_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_account">set_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256);
</code></pre>



</details>

<a id="0x1_evm_context_v2_set_storage"></a>

## Function `set_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_storage">set_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_set_storage">set_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256);
</code></pre>



</details>

<a id="0x1_evm_context_v2_add_always_warm_address"></a>

## Function `add_always_warm_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_address">add_always_warm_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_address">add_always_warm_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_v2_add_always_warm_slot"></a>

## Function `add_always_warm_slot`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_slot">add_always_warm_slot</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_slot">add_always_warm_slot</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256);
</code></pre>



</details>

<a id="0x1_evm_context_v2_execute_tx"></a>

## Function `execute_tx`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_execute_tx">execute_tx</a>(env: <a href="env_for_test.md#0x1_env_for_test_Env">env_for_test::Env</a>, from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit: u256, gas_price: u256, max_fee_per_gas: u256, max_priority_fee_per_gas: u256, access_list_address_len: u64, access_list_slot_len: u64, tx_type: u8): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context_v2.md#0x1_evm_context_v2_execute_tx">execute_tx</a>(env: Env, from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit: u256,
                      gas_price: u256, max_fee_per_gas: u256, max_priority_fee_per_gas: u256, access_list_address_len: u64, access_list_slot_len: u64, tx_type: u8): u64;
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
