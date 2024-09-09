
<a id="0x1_util"></a>

# Module `0x1::util`

Utility functions used by the framework modules.


-  [Function `from_bytes`](#0x1_util_from_bytes)
-  [Function `address_from_bytes`](#0x1_util_address_from_bytes)
-  [Specification](#@Specification_0)
    -  [Function `from_bytes`](#@Specification_0_from_bytes)
    -  [High-level Requirements](#high-level-req)
    -  [Module-level Specification](#module-level-spec)
    -  [Function `address_from_bytes`](#@Specification_0_address_from_bytes)


<pre><code></code></pre>



<a id="0x1_util_from_bytes"></a>

## Function `from_bytes`

Native function to deserialize a type T.

Note that this function does not put any constraint on <code>T</code>. If code uses this function to
deserialized a linear value, its their responsibility that the data they deserialize is
owned.


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="util.md#0x1_util_from_bytes">from_bytes</a>&lt;T&gt;(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(<b>friend</b>) <b>native</b> <b>fun</b> <a href="util.md#0x1_util_from_bytes">from_bytes</a>&lt;T&gt;(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): T;
</code></pre>



</details>

<a id="0x1_util_address_from_bytes"></a>

## Function `address_from_bytes`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_util_address_from_bytes">address_from_bytes</a>(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_util_address_from_bytes">address_from_bytes</a>(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <b>address</b> {
    <a href="util.md#0x1_util_from_bytes">from_bytes</a>(bytes)
}
</code></pre>



</details>

<a id="@Specification_0"></a>

## Specification


<a id="@Specification_0_from_bytes"></a>

### Function `from_bytes`


<pre><code><b>public</b>(<b>friend</b>) <b>fun</b> <a href="util.md#0x1_util_from_bytes">from_bytes</a>&lt;T&gt;(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): T
</code></pre>





<a id="high-level-req"></a>

### High-level Requirements

<table>
<tr>
<th>No.</th><th>Requirement</th><th>Criticality</th><th>Implementation</th><th>Enforcement</th>
</tr>

<tr>
<td>1</td>
<td>The address input bytes should be exactly 32 bytes long.</td>
<td>Low</td>
<td>The address_from_bytes function should assert if the length of the input bytes is 32.</td>
<td>Verified via <a href="#high-level-req-1">address_from_bytes</a>.</td>
</tr>

</table>




<a id="module-level-spec"></a>

### Module-level Specification


<pre><code><b>pragma</b> opaque;
<b>aborts_if</b> [abstract] <b>false</b>;
<b>ensures</b> [abstract] result == <a href="util.md#0x1_util_spec_from_bytes">spec_from_bytes</a>&lt;T&gt;(bytes);
</code></pre>




<a id="0x1_util_spec_from_bytes"></a>


<pre><code><b>fun</b> <a href="util.md#0x1_util_spec_from_bytes">spec_from_bytes</a>&lt;T&gt;(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): T;
</code></pre>



<a id="@Specification_0_address_from_bytes"></a>

### Function `address_from_bytes`


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_util_address_from_bytes">address_from_bytes</a>(bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <b>address</b>
</code></pre>




<pre><code>// This enforces <a id="high-level-req-1" href="#high-level-req">high-level requirement 1</a>:
<b>aborts_if</b> [abstract] len(bytes) != 32;
</code></pre>



<a id="0x1_evm_util"></a>

# Module `0x1::evm_util`



-  [Constants](#@Constants_0)
-  [Function `new_fixed_length_vector`](#0x1_evm_util_new_fixed_length_vector)
-  [Function `vector_extend`](#0x1_evm_util_vector_extend)
-  [Function `vector_slice`](#0x1_evm_util_vector_slice)
-  [Function `bit_length`](#0x1_evm_util_bit_length)
-  [Function `vector_slice_u256`](#0x1_evm_util_vector_slice_u256)
-  [Function `create_empty_data`](#0x1_evm_util_create_empty_data)
-  [Function `to_n_bit`](#0x1_evm_util_to_n_bit)
-  [Function `to_32bit`](#0x1_evm_util_to_32bit)
-  [Function `get_valid_ethereum_address`](#0x1_evm_util_get_valid_ethereum_address)
-  [Function `get_contract_address`](#0x1_evm_util_get_contract_address)
-  [Function `to_int256`](#0x1_evm_util_to_int256)
-  [Function `to_u256`](#0x1_evm_util_to_u256)
-  [Function `data_to_u256`](#0x1_evm_util_data_to_u256)
-  [Function `u256_bytes_length`](#0x1_evm_util_u256_bytes_length)
-  [Function `adjust_length`](#0x1_evm_util_adjust_length)
-  [Function `u256_to_data`](#0x1_evm_util_u256_to_data)
-  [Function `expand_to_pos`](#0x1_evm_util_expand_to_pos)
-  [Function `read_memory`](#0x1_evm_util_read_memory)
-  [Function `write_call_output`](#0x1_evm_util_write_call_output)
-  [Function `copy_to_memory`](#0x1_evm_util_copy_to_memory)
-  [Function `mstore`](#0x1_evm_util_mstore)
-  [Function `get_message_hash`](#0x1_evm_util_get_message_hash)
-  [Function `u256_to_trimed_data`](#0x1_evm_util_u256_to_trimed_data)
-  [Function `trim`](#0x1_evm_util_trim)
-  [Function `get_word_count`](#0x1_evm_util_get_word_count)
-  [Function `get_valid_jumps`](#0x1_evm_util_get_valid_jumps)
-  [Function `print_opcode`](#0x1_evm_util_print_opcode)
-  [Function `hex_length`](#0x1_evm_util_hex_length)
-  [Function `encode_data`](#0x1_evm_util_encode_data)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_aptos_hash">0x1::aptos_hash</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/debug.md#0x1_debug">0x1::debug</a>;
<b>use</b> <a href="encode.md#0x1_rlp_encode">0x1::rlp_encode</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/string.md#0x1_string">0x1::string</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">0x1::vector</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_util_TX_FORMAT"></a>



<pre><code><b>const</b> <a href="util.md#0x1_evm_util_TX_FORMAT">TX_FORMAT</a>: u64 = 20001;
</code></pre>



<a id="0x1_evm_util_U255_MAX"></a>



<pre><code><b>const</b> <a href="util.md#0x1_evm_util_U255_MAX">U255_MAX</a>: u256 = 57896044618658097711785492504343953926634992332820282019728792003956564819967;
</code></pre>



<a id="0x1_evm_util_U256_MAX"></a>



<pre><code><b>const</b> <a href="util.md#0x1_evm_util_U256_MAX">U256_MAX</a>: u256 = 115792089237316195423570985008687907853269984665640564039457584007913129639935;
</code></pre>



<a id="0x1_evm_util_U64_MAX"></a>



<pre><code><b>const</b> <a href="util.md#0x1_evm_util_U64_MAX">U64_MAX</a>: u256 = 18446744073709551615;
</code></pre>



<a id="0x1_evm_util_ZERO_EVM_ADDR"></a>



<pre><code><b>const</b> <a href="util.md#0x1_evm_util_ZERO_EVM_ADDR">ZERO_EVM_ADDR</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [];
</code></pre>



<a id="0x1_evm_util_new_fixed_length_vector"></a>

## Function `new_fixed_length_vector`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_new_fixed_length_vector">new_fixed_length_vector</a>(size: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="util.md#0x1_evm_util_new_fixed_length_vector">new_fixed_length_vector</a>(size: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_util_vector_extend"></a>

## Function `vector_extend`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_extend">vector_extend</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, b: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_extend">vector_extend</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, b: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_util_vector_slice"></a>

## Function `vector_slice`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64, size: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64, size: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;;
</code></pre>



</details>

<a id="0x1_evm_util_bit_length"></a>

## Function `bit_length`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_bit_length">bit_length</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="util.md#0x1_evm_util_bit_length">bit_length</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256;
</code></pre>



</details>

<a id="0x1_evm_util_vector_slice_u256"></a>

## Function `vector_slice_u256`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_slice_u256">vector_slice_u256</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u256, size: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_vector_slice_u256">vector_slice_u256</a>(a: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u256, size: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>if</b>(pos &gt; <a href="util.md#0x1_evm_util_U64_MAX">U64_MAX</a>) {
        <b>return</b> <a href="util.md#0x1_evm_util_create_empty_data">create_empty_data</a>((size <b>as</b> u64))
    };

    <a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(a, (pos <b>as</b> u64), (size <b>as</b> u64))
}
</code></pre>



</details>

<a id="0x1_evm_util_create_empty_data"></a>

## Function `create_empty_data`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_create_empty_data">create_empty_data</a>(len: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_create_empty_data">create_empty_data</a>(len: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> bytes = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> i = 0;
    <b>while</b>(i &lt; len) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> bytes, 0);
        i = i + 1;
    };
    bytes
}
</code></pre>



</details>

<a id="0x1_evm_util_to_n_bit"></a>

## Function `to_n_bit`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_n_bit">to_n_bit</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, n: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_n_bit">to_n_bit</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, n: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> bytes = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data);
    // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&len);
    <b>while</b>(len &lt; n) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> bytes, 0);
        len = len + 1
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> bytes, data);
    bytes
}
</code></pre>



</details>

<a id="0x1_evm_util_to_32bit"></a>

## Function `to_32bit`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_32bit">to_32bit</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_32bit">to_32bit</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> bytes = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data);
    // <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&len);
    <b>while</b>(len &lt; 32) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> bytes, 0);
        len = len + 1
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> bytes, data);
    bytes
}
</code></pre>



</details>

<a id="0x1_evm_util_get_valid_ethereum_address"></a>

## Function `get_valid_ethereum_address`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_valid_ethereum_address">get_valid_ethereum_address</a>(num: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_valid_ethereum_address">get_valid_ethereum_address</a>(num: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <a href="util.md#0x1_evm_util_to_32bit">to_32bit</a>(<a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(<a href="util.md#0x1_evm_util_u256_to_data">u256_to_data</a>(num), 12, 20))
}
</code></pre>



</details>

<a id="0x1_evm_util_get_contract_address"></a>

## Function `get_contract_address`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_contract_address">get_contract_address</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_contract_address">get_contract_address</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, nonce: u64): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> nonce_bytes = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> l = 0;
    <b>while</b>(nonce &gt; 0) {
        l = l + 1;
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> nonce_bytes, ((nonce % 0x100) <b>as</b> u8));
        nonce = nonce / 0x100;
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_reverse">vector::reverse</a>(&<b>mut</b> nonce_bytes);
    <b>let</b> salt = encode_bytes_list(<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>[<a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(addr, 12, 20), nonce_bytes]);
    <a href="util.md#0x1_evm_util_to_32bit">to_32bit</a>(<a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(keccak256(salt), 12, 20))
}
</code></pre>



</details>

<a id="0x1_evm_util_to_int256"></a>

## Function `to_int256`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_int256">to_int256</a>(num: u256): (bool, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_int256">to_int256</a>(num: u256): (bool, u256) {
    <b>let</b> neg = <b>false</b>;
    <b>if</b>(num &gt; <a href="util.md#0x1_evm_util_U255_MAX">U255_MAX</a>) {
        neg = <b>true</b>;
        num = <a href="util.md#0x1_evm_util_U256_MAX">U256_MAX</a> - num + 1;
    };
    (neg, num)
}
</code></pre>



</details>

<a id="0x1_evm_util_to_u256"></a>

## Function `to_u256`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_u256">to_u256</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_to_u256">to_u256</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> res = 0;
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data);
    <b>while</b> (i &lt; len) {
        <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&data, i);
        res = (res &lt;&lt; 8) + (value <b>as</b> u256);
        i = i + 1;
    };
    res
}
</code></pre>



</details>

<a id="0x1_evm_util_data_to_u256"></a>

## Function `data_to_u256`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_data_to_u256">data_to_u256</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, p: u256, size: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_data_to_u256">data_to_u256</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, p: u256, size: u256): u256 {
    <b>let</b> res = 0;
    <b>let</b> i = 0;
    <b>let</b> len = (<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data) <b>as</b> u256);
    <b>assert</b>!(size &lt;= 32, 1);
    <b>while</b> (i &lt; size) {
        <b>if</b>(p + i &lt; len) {
            <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&data, ((p + i) <b>as</b> u64));
            res = (res &lt;&lt; 8) + (value <b>as</b> u256);
        } <b>else</b> {
            res = res &lt;&lt; 8
        };

        i = i + 1;
    };

    res
}
</code></pre>



</details>

<a id="0x1_evm_util_u256_bytes_length"></a>

## Function `u256_bytes_length`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_bytes_length">u256_bytes_length</a>(num: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_bytes_length">u256_bytes_length</a>(num: u256): u256 {
    <b>let</b> i = 0;
    <b>while</b>(num &gt; 0) {
        i = i + 1;
        num = num &gt;&gt; 8;
    };

    i
}
</code></pre>



</details>

<a id="0x1_evm_util_adjust_length"></a>

## Function `adjust_length`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_adjust_length">adjust_length</a>(bytes: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_adjust_length">adjust_length</a>(bytes: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(bytes);
    <b>let</b> i = 0;
    <b>while</b>(len &gt; 0 && *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(bytes, i) == 0) {
        len = len - 1;
        i = i + 1;
    };
    (len <b>as</b> u256)
}
</code></pre>



</details>

<a id="0x1_evm_util_u256_to_data"></a>

## Function `u256_to_data`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_to_data">u256_to_data</a>(num256: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_to_data">u256_to_data</a>(num256: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> res = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>let</b> i = 32;
    <b>while</b>(i &gt; 0) {
        i = i - 1;
        <b>let</b> shifted_value = num256 &gt;&gt; (i * 8);
        <b>let</b> byte = ((shifted_value & 0xff) <b>as</b> u8);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> res, byte);
    };
    res
}
</code></pre>



</details>

<a id="0x1_evm_util_expand_to_pos"></a>

## Function `expand_to_pos`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_expand_to_pos">expand_to_pos</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_expand_to_pos">expand_to_pos</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64) {
    <b>let</b> len_m = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(memory);
    <b>let</b> pos = pos;
    <b>if</b>(pos % 32 != 0) {
        pos = pos / 32 * 32 + 32;
    };

    <b>if</b>(pos &gt; len_m) {
        <b>let</b> size = pos - len_m;
        <b>let</b> new_array = <a href="util.md#0x1_evm_util_new_fixed_length_vector">new_fixed_length_vector</a>(size);
        *memory = <a href="util.md#0x1_evm_util_vector_extend">vector_extend</a>(new_array, *memory)
    };
}
</code></pre>



</details>

<a id="0x1_evm_util_read_memory"></a>

## Function `read_memory`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_read_memory">read_memory</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, in_offset: u256, in_len: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_read_memory">read_memory</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, in_offset: u256, in_len: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>if</b>(in_len &gt; 0) {
        <a href="util.md#0x1_evm_util_expand_to_pos">expand_to_pos</a>(memory, ((in_offset + in_len) <b>as</b> u64));
    };
    <a href="util.md#0x1_evm_util_vector_slice_u256">vector_slice_u256</a>(*memory, in_offset, in_len)
}
</code></pre>



</details>

<a id="0x1_evm_util_write_call_output"></a>

## Function `write_call_output`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_write_call_output">write_call_output</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, out_offset: u256, out_len: u256, ret_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_write_call_output">write_call_output</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, out_offset: u256, out_len: u256, ret_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>let</b> data_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&ret_data);
    <b>let</b> out_len = (out_len <b>as</b> u64);
    <b>if</b>(data_len &gt; 0) {
        <b>if</b>(data_len &lt; out_len) {
            out_len = data_len;
        };
        <b>let</b> data = <a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(ret_data, 0, out_len);
        <a href="util.md#0x1_evm_util_copy_to_memory">copy_to_memory</a>(memory, out_offset, 0, (out_len <b>as</b> u256), data);
    }
}
</code></pre>



</details>

<a id="0x1_evm_util_copy_to_memory"></a>

## Function `copy_to_memory`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_copy_to_memory">copy_to_memory</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, m_pos: u256, d_pos: u256, len: u256, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_copy_to_memory">copy_to_memory</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, m_pos: u256, d_pos: u256, len: u256, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>if</b>(len &gt; 0) {
        <a href="util.md#0x1_evm_util_expand_to_pos">expand_to_pos</a>(memory, ((m_pos + len) <b>as</b> u64));
        <b>let</b> i = 0;
        <b>let</b> d_len =( <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data) <b>as</b> u256);

        <b>while</b> (i &lt; len) {
            <b>let</b> bytes = <b>if</b>(d_pos &gt; <a href="util.md#0x1_evm_util_U64_MAX">U64_MAX</a> || d_pos + i &gt;= d_len) 0 <b>else</b> *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&data, ((d_pos + i) <b>as</b> u64));
            *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(memory, ((m_pos + i) <b>as</b> u64)) = bytes;
            i = i + 1;
        };
    }
}
</code></pre>



</details>

<a id="0x1_evm_util_mstore"></a>

## Function `mstore`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_mstore">mstore</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_mstore">mstore</a>(memory: &<b>mut</b> <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, pos: u64, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>let</b> len_d = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data);
    <b>if</b>(len_d &gt; 0) {
        <a href="util.md#0x1_evm_util_expand_to_pos">expand_to_pos</a>(memory, pos + len_d);
        <b>let</b> i = 0;
        <b>while</b> (i &lt; len_d) {
            *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow_mut">vector::borrow_mut</a>(memory, pos + i) = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&data, i);
            i = i + 1
        };
    };
}
</code></pre>



</details>

<a id="0x1_evm_util_get_message_hash"></a>

## Function `get_message_hash`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_message_hash">get_message_hash</a>(input: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_message_hash">get_message_hash</a>(input: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&input);
    <b>let</b> content = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>while</b>(i &lt; len) {
        <b>let</b> item = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&input, i);
        <b>let</b> item_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(item);
        <b>let</b> encoded = <b>if</b>(item_len == 1 && *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(item, 0) &lt; 0x80) *item <b>else</b> <a href="util.md#0x1_evm_util_encode_data">encode_data</a>(item, 0x80);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> content, encoded);
        i = i + 1;
    };

    <a href="util.md#0x1_evm_util_encode_data">encode_data</a>(&content, 0xc0)
}
</code></pre>



</details>

<a id="0x1_evm_util_u256_to_trimed_data"></a>

## Function `u256_to_trimed_data`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_to_trimed_data">u256_to_trimed_data</a>(num: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_u256_to_trimed_data">u256_to_trimed_data</a>(num: u256): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <a href="util.md#0x1_evm_util_trim">trim</a>(<a href="util.md#0x1_evm_util_u256_to_data">u256_to_data</a>(num))
}
</code></pre>



</details>

<a id="0x1_evm_util_trim"></a>

## Function `trim`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_trim">trim</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_trim">trim</a>(data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&data);
    <b>while</b> (i &lt; len) {
        <b>let</b> ith = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&data, i);
        <b>if</b>(ith != 0) {
            <b>break</b>
        };
        i = i + 1
    };
    <a href="util.md#0x1_evm_util_vector_slice">vector_slice</a>(data, i, len - i)
}
</code></pre>



</details>

<a id="0x1_evm_util_get_word_count"></a>

## Function `get_word_count`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_word_count">get_word_count</a>(bytes: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_word_count">get_word_count</a>(bytes: u256): u256 {
    // To prevent overflow, this method is used <b>to</b> calculate the number of bytes
    <b>let</b> word_count = bytes / 32;
    <b>if</b>(bytes % 32 != 0) {
        word_count = word_count + 1;
    };
    word_count
}
</code></pre>



</details>

<a id="0x1_evm_util_get_valid_jumps"></a>

## Function `get_valid_jumps`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_valid_jumps">get_valid_jumps</a>(bytecode: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_get_valid_jumps">get_valid_jumps</a>(bytecode: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;bool&gt; {
    <b>let</b> i = 0;
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(bytecode);
    <b>let</b> valid_jumps = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;bool&gt;();
    <b>while</b>(i &lt; len) {
        <b>let</b> opcode = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(bytecode, i);
        <b>if</b>(opcode == 0x5b) {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> valid_jumps, <b>true</b>)
        } <b>else</b> <b>if</b>(opcode &gt;= 0x60 && opcode &lt;= 0x7f) {
            <b>let</b> size = opcode - 0x60 + 1;
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> valid_jumps, <b>false</b>);
            <b>while</b>(size &gt; 0) {
                <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> valid_jumps, <b>false</b>);
                i = i + 1;
                size = size - 1;
            }
        } <b>else</b> {
            <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> valid_jumps, <b>false</b>);
        };
        i = i + 1;
    };

    valid_jumps
}
</code></pre>



</details>

<a id="0x1_evm_util_print_opcode"></a>

## Function `print_opcode`



<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_print_opcode">print_opcode</a>(opcode: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="util.md#0x1_evm_util_print_opcode">print_opcode</a>(opcode: u8) {
    <b>if</b>(opcode == 0x00) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"STOP"))
    } <b>else</b> <b>if</b>(opcode == 0x01) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"ADD"));
    } <b>else</b> <b>if</b>(opcode == 0x02) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MUL"));
    } <b>else</b> <b>if</b>(opcode == 0x03) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SUB"));
    } <b>else</b> <b>if</b>(opcode == 0x04) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DIV"));
    } <b>else</b> <b>if</b>(opcode == 0x05) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SDIV"));
    } <b>else</b> <b>if</b>(opcode == 0x06) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MOD"));
    } <b>else</b> <b>if</b>(opcode == 0x07) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SMOD"));
    } <b>else</b> <b>if</b>(opcode == 0x08) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"ADDMOD"));
    } <b>else</b> <b>if</b>(opcode == 0x09) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MULMOD"));
    } <b>else</b> <b>if</b>(opcode == 0x0a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"EXP"));
    } <b>else</b> <b>if</b>(opcode == 0x0b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SIGNEXTEND"));
    } <b>else</b> <b>if</b>(opcode == 0x10) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LT"));
    } <b>else</b> <b>if</b>(opcode == 0x11) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"GT"));
    } <b>else</b> <b>if</b>(opcode == 0x12) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SLT"));
    } <b>else</b> <b>if</b>(opcode == 0x13) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SGT"));
    } <b>else</b> <b>if</b>(opcode == 0x14) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"EQ"));
    } <b>else</b> <b>if</b>(opcode == 0x15) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"ISZERO"));
    } <b>else</b> <b>if</b>(opcode == 0x16) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"AND"));
    } <b>else</b> <b>if</b>(opcode == 0x17) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"OR"));
    } <b>else</b> <b>if</b>(opcode == 0x18) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"XOR"));
    } <b>else</b> <b>if</b>(opcode == 0x19) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"NOT"));
    } <b>else</b> <b>if</b>(opcode == 0x1a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"BYTE"));
    } <b>else</b> <b>if</b>(opcode == 0x1b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SHL"));
    } <b>else</b> <b>if</b>(opcode == 0x1c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SHR"));
    } <b>else</b> <b>if</b>(opcode == 0x1d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SAR"));
    } <b>else</b> <b>if</b>(opcode == 0x20) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SHA3"));
    } <b>else</b> <b>if</b>(opcode == 0x30) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"ADDRESS"));
    } <b>else</b> <b>if</b>(opcode == 0x31) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"BALANCE"));
    } <b>else</b> <b>if</b>(opcode == 0x32) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"ORIGIN"));
    } <b>else</b> <b>if</b>(opcode == 0x33) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLER"));
    } <b>else</b> <b>if</b>(opcode == 0x34) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLVALUE"));
    } <b>else</b> <b>if</b>(opcode == 0x35) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLDATALOAD"));
    } <b>else</b> <b>if</b>(opcode == 0x36) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLDATASIZE"));
    } <b>else</b> <b>if</b>(opcode == 0x37) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLDATACOPY"));
    } <b>else</b> <b>if</b>(opcode == 0x38) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CODESIZE"));
    } <b>else</b> <b>if</b>(opcode == 0x39) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CODECOPY"));
    } <b>else</b> <b>if</b>(opcode == 0x3a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"GASPRICE"));
    } <b>else</b> <b>if</b>(opcode == 0x3b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"EXTCODESIZE"));
    } <b>else</b> <b>if</b>(opcode == 0x3c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"EXTCODECOPY"));
    } <b>else</b> <b>if</b>(opcode == 0x3d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"RETURNDATASIZE"));
    } <b>else</b> <b>if</b>(opcode == 0x3e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"RETURNDATACOPY"));
    } <b>else</b> <b>if</b>(opcode == 0x3f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"EXTCODEHASH"));
    } <b>else</b> <b>if</b>(opcode == 0x40) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"BLOCKHASH"));
    } <b>else</b> <b>if</b>(opcode == 0x41) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"COINBASE"));
    } <b>else</b> <b>if</b>(opcode == 0x42) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"TIMESTAMP"));
    } <b>else</b> <b>if</b>(opcode == 0x43) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"NUMBER"));
    } <b>else</b> <b>if</b>(opcode == 0x44) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DIFFICULTY"));
    } <b>else</b> <b>if</b>(opcode == 0x45) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"GASLIMIT"));
    } <b>else</b> <b>if</b>(opcode == 0x46) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"BASEFEE"));
    } <b>else</b> <b>if</b>(opcode == 0x47) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SELFBALANCE"));
    } <b>else</b> <b>if</b>(opcode == 0x48) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PREVRANDAO"));
    } <b>else</b> <b>if</b>(opcode == 0x50) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"POP"));
    } <b>else</b> <b>if</b>(opcode == 0x51) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MLOAD"));
    } <b>else</b> <b>if</b>(opcode == 0x52) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MSTORE"));
    } <b>else</b> <b>if</b>(opcode == 0x53) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MSTORE8"));
    } <b>else</b> <b>if</b>(opcode == 0x54) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SLOAD"));
    } <b>else</b> <b>if</b>(opcode == 0x55) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SSTORE"));
    } <b>else</b> <b>if</b>(opcode == 0x56) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"JUMP"));
    } <b>else</b> <b>if</b>(opcode == 0x57) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"JUMPI"));
    } <b>else</b> <b>if</b>(opcode == 0x58) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PC"));
    } <b>else</b> <b>if</b>(opcode == 0x59) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MSIZE"));
    } <b>else</b> <b>if</b>(opcode == 0x5a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"GAS"));
    } <b>else</b> <b>if</b>(opcode == 0x5b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"JUMPDEST"));
    } <b>else</b> <b>if</b>(opcode == 0x5c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"TLOAD"));
    } <b>else</b> <b>if</b>(opcode == 0x5d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"TSTORE"));
    }  <b>else</b> <b>if</b>(opcode == 0x5e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"MCOPY"));
    } <b>else</b> <b>if</b>(opcode == 0x5f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH0"));
    } <b>else</b> <b>if</b>(opcode == 0x60) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH1"));
    } <b>else</b> <b>if</b>(opcode == 0x61) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH2"));
    } <b>else</b> <b>if</b>(opcode == 0x62) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH3"));
    } <b>else</b> <b>if</b>(opcode == 0x63) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH4"));
    } <b>else</b> <b>if</b>(opcode == 0x64) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH5"));
    } <b>else</b> <b>if</b>(opcode == 0x65) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH6"));
    } <b>else</b> <b>if</b>(opcode == 0x66) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH7"));
    } <b>else</b> <b>if</b>(opcode == 0x67) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH8"));
    } <b>else</b> <b>if</b>(opcode == 0x68) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH9"));
    } <b>else</b> <b>if</b>(opcode == 0x69) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH10"));
    } <b>else</b> <b>if</b>(opcode == 0x6a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH11"));
    } <b>else</b> <b>if</b>(opcode == 0x6b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH12"));
    } <b>else</b> <b>if</b>(opcode == 0x6c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH13"));
    } <b>else</b> <b>if</b>(opcode == 0x6d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH14"));
    } <b>else</b> <b>if</b>(opcode == 0x6e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH15"));
    } <b>else</b> <b>if</b>(opcode == 0x6f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH16"));
    } <b>else</b> <b>if</b>(opcode == 0x70) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH17"));
    } <b>else</b> <b>if</b>(opcode == 0x71) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH18"));
    } <b>else</b> <b>if</b>(opcode == 0x72) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH19"));
    } <b>else</b> <b>if</b>(opcode == 0x73) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH20"));
    } <b>else</b> <b>if</b>(opcode == 0x74) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH21"));
    } <b>else</b> <b>if</b>(opcode == 0x75) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH22"));
    } <b>else</b> <b>if</b>(opcode == 0x76) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH23"));
    } <b>else</b> <b>if</b>(opcode == 0x77) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH24"));
    } <b>else</b> <b>if</b>(opcode == 0x78) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH25"));
    } <b>else</b> <b>if</b>(opcode == 0x79) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH26"));
    } <b>else</b> <b>if</b>(opcode == 0x7a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH27"));
    } <b>else</b> <b>if</b>(opcode == 0x7b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH28"));
    } <b>else</b> <b>if</b> (opcode == 0x7c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH29"));
    } <b>else</b> <b>if</b> (opcode == 0x7d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH30"));
    } <b>else</b> <b>if</b> (opcode == 0x7e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH31"));
    } <b>else</b> <b>if</b> (opcode == 0x7f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"PUSH32"));
    } <b>else</b> <b>if</b> (opcode == 0x80) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP1"));
    } <b>else</b> <b>if</b> (opcode == 0x81) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP2"));
    } <b>else</b> <b>if</b> (opcode == 0x82) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP3"));
    } <b>else</b> <b>if</b> (opcode == 0x83) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP4"));
    } <b>else</b> <b>if</b> (opcode == 0x84) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP5"));
    } <b>else</b> <b>if</b> (opcode == 0x85) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP6"));
    } <b>else</b> <b>if</b> (opcode == 0x86) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP7"));
    } <b>else</b> <b>if</b> (opcode == 0x87) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP8"));
    } <b>else</b> <b>if</b> (opcode == 0x88) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP9"));
    } <b>else</b> <b>if</b> (opcode == 0x89) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP10"));
    } <b>else</b> <b>if</b> (opcode == 0x8a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP11"));
    } <b>else</b> <b>if</b> (opcode == 0x8b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP12"));
    } <b>else</b> <b>if</b> (opcode == 0x8c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP13"));
    } <b>else</b> <b>if</b> (opcode == 0x8d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP14"));
    } <b>else</b> <b>if</b> (opcode == 0x8e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP15"));
    } <b>else</b> <b>if</b> (opcode == 0x8f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DUP16"));
    } <b>else</b> <b>if</b>(opcode == 0x90) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP1"));
    } <b>else</b> <b>if</b>(opcode == 0x91) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP2"));
    } <b>else</b> <b>if</b>(opcode == 0x92) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP3"));
    } <b>else</b> <b>if</b>(opcode == 0x93) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP4"));
    } <b>else</b> <b>if</b>(opcode == 0x94) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP5"));
    } <b>else</b> <b>if</b>(opcode == 0x95) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP6"));
    } <b>else</b> <b>if</b>(opcode == 0x96) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP7"));
    } <b>else</b> <b>if</b>(opcode == 0x97) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP8"));
    } <b>else</b> <b>if</b>(opcode == 0x98) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP9"));
    } <b>else</b> <b>if</b>(opcode == 0x99) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP10"));
    } <b>else</b> <b>if</b>(opcode == 0x9a) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP11"));
    } <b>else</b> <b>if</b>(opcode == 0x9b) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP12"));
    } <b>else</b> <b>if</b>(opcode == 0x9c) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP13"));
    } <b>else</b> <b>if</b>(opcode == 0x9d) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP14"));
    } <b>else</b> <b>if</b>(opcode == 0x9e) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP15"));
    } <b>else</b> <b>if</b>(opcode == 0x9f) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SWAP16"));
    } <b>else</b> <b>if</b>(opcode == 0xa0) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LOG0"));
    } <b>else</b> <b>if</b>(opcode == 0xa1) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LOG1"));
    } <b>else</b> <b>if</b>(opcode == 0xa2) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LOG2"));
    } <b>else</b> <b>if</b>(opcode == 0xa3) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LOG3"));
    } <b>else</b> <b>if</b>(opcode == 0xa4) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"LOG4"));
    } <b>else</b> <b>if</b>(opcode &gt;= 0xa5 && opcode &lt;= 0xaf) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"Reserved for future <b>use</b>"));
    } <b>else</b> <b>if</b>(opcode &gt;= 0xb0 && opcode &lt;= 0xe0) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"More Reserved Opcodes"));
    } <b>else</b> <b>if</b>(opcode == 0xf0) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CREATE"));
    } <b>else</b> <b>if</b>(opcode == 0xf1) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALL"));
    } <b>else</b> <b>if</b>(opcode == 0xf2) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CALLCODE"));
    } <b>else</b> <b>if</b>(opcode == 0xf3) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"RETURN"));
    } <b>else</b> <b>if</b>(opcode == 0xf4) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"DELEGATECALL"));
    } <b>else</b> <b>if</b>(opcode == 0xf5) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"CREATE2"));
    } <b>else</b> <b>if</b>(opcode == 0xfa) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"STATICCALL"));
    } <b>else</b> <b>if</b>(opcode == 0xfd) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"REVERT"));
    } <b>else</b> <b>if</b>(opcode == 0xfe) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"INVALID"));
    } <b>else</b> <b>if</b>(opcode == 0xff) {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"SELFDESTRUCT"));
    } <b>else</b> {
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&utf8(b"Unknown Opcode"));
    }
}
</code></pre>



</details>

<a id="0x1_evm_util_hex_length"></a>

## Function `hex_length`



<pre><code><b>fun</b> <a href="util.md#0x1_evm_util_hex_length">hex_length</a>(len: u64): (u8, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="util.md#0x1_evm_util_hex_length">hex_length</a>(len: u64): (u8, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <b>let</b> res = 0;
    <b>let</b> bytes = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>while</b>(len &gt; 0) {
        res = res + 1;
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> bytes, ((len % 256) <b>as</b> u8));
        len = len / 256;
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_reverse">vector::reverse</a>(&<b>mut</b> bytes);
    (res, bytes)
}
</code></pre>



</details>

<a id="0x1_evm_util_encode_data"></a>

## Function `encode_data`



<pre><code><b>fun</b> <a href="util.md#0x1_evm_util_encode_data">encode_data</a>(data: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, offset: u8): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="util.md#0x1_evm_util_encode_data">encode_data</a>(data: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, offset: u8): <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; {
    <b>let</b> len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(data);
    <b>let</b> res = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_empty">vector::empty</a>&lt;u8&gt;();
    <b>if</b>(len &lt; 56) {
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> res, (len <b>as</b> u8) + offset);
    } <b>else</b> {
        <b>let</b>(hex_len, len_bytes) = <a href="util.md#0x1_evm_util_hex_length">hex_length</a>(len);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_push_back">vector::push_back</a>(&<b>mut</b> res, hex_len + offset + 55);
        <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> res, len_bytes);
    };
    <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_append">vector::append</a>(&<b>mut</b> res, *data);
    res
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
