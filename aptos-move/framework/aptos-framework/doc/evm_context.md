
<a id="0x1_evm_context"></a>

# Module `0x1::evm_context`



-  [Function `exist`](#0x1_evm_context_exist)
-  [Function `calculate_root`](#0x1_evm_context_calculate_root)
-  [Function `storage_empty`](#0x1_evm_context_storage_empty)
-  [Function `is_cold_address`](#0x1_evm_context_is_cold_address)
-  [Function `get_transient_storage`](#0x1_evm_context_get_transient_storage)
-  [Function `get_origin`](#0x1_evm_context_get_origin)
-  [Function `get_code`](#0x1_evm_context_get_code)
-  [Function `get_balance`](#0x1_evm_context_get_balance)
-  [Function `get_nonce`](#0x1_evm_context_get_nonce)
-  [Function `get_storage`](#0x1_evm_context_get_storage)
-  [Function `set_code`](#0x1_evm_context_set_code)
-  [Function `set_account`](#0x1_evm_context_set_account)
-  [Function `set_storage`](#0x1_evm_context_set_storage)
-  [Function `set_transient_storage`](#0x1_evm_context_set_transient_storage)
-  [Function `add_balance`](#0x1_evm_context_add_balance)
-  [Function `sub_balance`](#0x1_evm_context_sub_balance)
-  [Function `set_balance`](#0x1_evm_context_set_balance)
-  [Function `inc_nonce`](#0x1_evm_context_inc_nonce)
-  [Function `set_nonce`](#0x1_evm_context_set_nonce)
-  [Function `add_always_hot_address`](#0x1_evm_context_add_always_hot_address)
-  [Function `add_always_hot_slot`](#0x1_evm_context_add_always_hot_slot)
-  [Function `add_hot_address`](#0x1_evm_context_add_hot_address)
-  [Function `push_substate`](#0x1_evm_context_push_substate)
-  [Function `commit_substate`](#0x1_evm_context_commit_substate)
-  [Function `revert_substate`](#0x1_evm_context_revert_substate)
-  [Function `get_balance_change_set`](#0x1_evm_context_get_balance_change_set)
-  [Function `get_nonce_change_set`](#0x1_evm_context_get_nonce_change_set)
-  [Function `get_code_change_set`](#0x1_evm_context_get_code_change_set)
-  [Function `get_address_change_set`](#0x1_evm_context_get_address_change_set)
-  [Function `get_storage_change_set`](#0x1_evm_context_get_storage_change_set)


<pre><code></code></pre>



<a id="0x1_evm_context_exist"></a>

## Function `exist`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_exist">exist</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_exist">exist</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, bool);
</code></pre>



</details>

<a id="0x1_evm_context_calculate_root"></a>

## Function `calculate_root`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_calculate_root">calculate_root</a>(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_calculate_root">calculate_root</a>(): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_context_storage_empty"></a>

## Function `storage_empty`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_storage_empty">storage_empty</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_storage_empty">storage_empty</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool;
</code></pre>



</details>

<a id="0x1_evm_context_is_cold_address"></a>

## Function `is_cold_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_is_cold_address">is_cold_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_is_cold_address">is_cold_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool;
</code></pre>



</details>

<a id="0x1_evm_context_get_transient_storage"></a>

## Function `get_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_transient_storage">get_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_transient_storage">get_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): u256;
</code></pre>



</details>

<a id="0x1_evm_context_get_origin"></a>

## Function `get_origin`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_origin">get_origin</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_origin">get_origin</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): (bool, u256);
</code></pre>



</details>

<a id="0x1_evm_context_get_code"></a>

## Function `get_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_code">get_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_code">get_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_get_balance"></a>

## Function `get_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_balance">get_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_balance">get_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, u256);
</code></pre>



</details>

<a id="0x1_evm_context_get_nonce"></a>

## Function `get_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_nonce">get_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_nonce">get_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (bool, u256);
</code></pre>



</details>

<a id="0x1_evm_context_get_storage"></a>

## Function `get_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_storage">get_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_storage">get_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256): (bool, u256);
</code></pre>



</details>

<a id="0x1_evm_context_set_code"></a>

## Function `set_code`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_code">set_code</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_set_account"></a>

## Function `set_account`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_account">set_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_account">set_account</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256, <a href="code.md#0x1_code">code</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256);
</code></pre>



</details>

<a id="0x1_evm_context_set_storage"></a>

## Function `set_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_storage">set_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_storage">set_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256);
</code></pre>



</details>

<a id="0x1_evm_context_set_transient_storage"></a>

## Function `set_transient_storage`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_transient_storage">set_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_transient_storage">set_transient_storage</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256, value: u256);
</code></pre>



</details>

<a id="0x1_evm_context_add_balance"></a>

## Function `add_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_balance">add_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_balance">add_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256);
</code></pre>



</details>

<a id="0x1_evm_context_sub_balance"></a>

## Function `sub_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_sub_balance">sub_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_sub_balance">sub_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, value: u256): bool;
</code></pre>



</details>

<a id="0x1_evm_context_set_balance"></a>

## Function `set_balance`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_balance">set_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_balance">set_balance</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, balance: u256);
</code></pre>



</details>

<a id="0x1_evm_context_inc_nonce"></a>

## Function `inc_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_inc_nonce">inc_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_inc_nonce">inc_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_set_nonce"></a>

## Function `set_nonce`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_nonce">set_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_set_nonce">set_nonce</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u256);
</code></pre>



</details>

<a id="0x1_evm_context_add_always_hot_address"></a>

## Function `add_always_hot_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_always_hot_address">add_always_hot_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_always_hot_address">add_always_hot_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_add_always_hot_slot"></a>

## Function `add_always_hot_slot`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_always_hot_slot">add_always_hot_slot</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_always_hot_slot">add_always_hot_slot</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, index: u256);
</code></pre>



</details>

<a id="0x1_evm_context_add_hot_address"></a>

## Function `add_hot_address`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_hot_address">add_hot_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_add_hot_address">add_hot_address</a>(contract: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_push_substate"></a>

## Function `push_substate`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_push_substate">push_substate</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_push_substate">push_substate</a>();
</code></pre>



</details>

<a id="0x1_evm_context_commit_substate"></a>

## Function `commit_substate`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_commit_substate">commit_substate</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_commit_substate">commit_substate</a>();
</code></pre>



</details>

<a id="0x1_evm_context_revert_substate"></a>

## Function `revert_substate`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_revert_substate">revert_substate</a>()
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_revert_substate">revert_substate</a>();
</code></pre>



</details>

<a id="0x1_evm_context_get_balance_change_set"></a>

## Function `get_balance_change_set`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_balance_change_set">get_balance_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_balance_change_set">get_balance_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_get_nonce_change_set"></a>

## Function `get_nonce_change_set`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_nonce_change_set">get_nonce_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_nonce_change_set">get_nonce_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_get_code_change_set"></a>

## Function `get_code_change_set`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_code_change_set">get_code_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u64&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_code_change_set">get_code_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u64&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_get_address_change_set"></a>

## Function `get_address_change_set`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_address_change_set">get_address_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_address_change_set">get_address_change_set</a>(): (u64, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;);
</code></pre>



</details>

<a id="0x1_evm_context_get_storage_change_set"></a>

## Function `get_storage_change_set`



<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_storage_change_set">get_storage_change_set</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="evm_context.md#0x1_evm_context_get_storage_change_set">get_storage_change_set</a>(<b>address</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u256&gt;);
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
