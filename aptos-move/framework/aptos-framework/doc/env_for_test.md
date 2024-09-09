
<a id="0x1_env_for_test"></a>

# Module `0x1::env_for_test`



-  [Struct `Env`](#0x1_env_for_test_Env)
-  [Function `get_base_fee_per_gas`](#0x1_env_for_test_get_base_fee_per_gas)
-  [Function `parse_env`](#0x1_env_for_test_parse_env)


<pre><code><b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
</code></pre>



<a id="0x1_env_for_test_Env"></a>

## Struct `Env`



<pre><code><b>struct</b> <a href="env_for_test.md#0x1_env_for_test_Env">Env</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>block_number: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_coinbase: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>block_timestamp: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_difficulty: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_random: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
<dt>
<code>block_gas_limit: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_base_fee_per_gas: u256</code>
</dt>
<dd>

</dd>
<dt>
<code>block_excess_blob_gas: u256</code>
</dt>
<dd>

</dd>
<dt>
<code><a href="chain_id.md#0x1_chain_id">chain_id</a>: u256</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="0x1_env_for_test_get_base_fee_per_gas"></a>

## Function `get_base_fee_per_gas`



<pre><code><b>public</b> <b>fun</b> <a href="env_for_test.md#0x1_env_for_test_get_base_fee_per_gas">get_base_fee_per_gas</a>(env: &<a href="env_for_test.md#0x1_env_for_test_Env">env_for_test::Env</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="env_for_test.md#0x1_env_for_test_get_base_fee_per_gas">get_base_fee_per_gas</a>(env: &<a href="env_for_test.md#0x1_env_for_test_Env">Env</a>): u256 {
    env.block_base_fee_per_gas
}
</code></pre>



</details>

<a id="0x1_env_for_test_parse_env"></a>

## Function `parse_env`



<pre><code><b>public</b> <b>fun</b> <a href="env_for_test.md#0x1_env_for_test_parse_env">parse_env</a>(env: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): <a href="env_for_test.md#0x1_env_for_test_Env">env_for_test::Env</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="env_for_test.md#0x1_env_for_test_parse_env">parse_env</a>(env: &<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;): <a href="env_for_test.md#0x1_env_for_test_Env">Env</a> {
    <b>let</b> block_base_fee_per_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 0));
    <b>let</b> block_coinbase = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 1);
    <b>let</b> block_difficulty = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 2));
    <b>let</b> block_excess_blob_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 3));
    <b>let</b> block_gas_limit = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 4));
    <b>let</b> block_number = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 5));
    <b>let</b> block_random = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 6);
    <b>let</b> block_timestamp = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(env, 7));
    <a href="env_for_test.md#0x1_env_for_test_Env">Env</a> {
        block_base_fee_per_gas,
        block_coinbase,
        block_difficulty,
        block_excess_blob_gas,
        block_gas_limit,
        block_number,
        block_random,
        block_timestamp,
        <a href="chain_id.md#0x1_chain_id">chain_id</a>: 1
    }
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
