
<a id="0x1_evm_for_test_v2"></a>

# Module `0x1::evm_for_test_v2`



-  [Struct `ExecResultEvent`](#0x1_evm_for_test_v2_ExecResultEvent)
-  [Constants](#@Constants_0)
-  [Function `pre_init`](#0x1_evm_for_test_v2_pre_init)
-  [Function `emit_event`](#0x1_evm_for_test_v2_emit_event)
-  [Function `run_test`](#0x1_evm_for_test_v2_run_test)


<pre><code><b>use</b> <a href="../../aptos-stdlib/doc/debug.md#0x1_debug">0x1::debug</a>;
<b>use</b> <a href="env_for_test.md#0x1_env_for_test">0x1::env_for_test</a>;
<b>use</b> <a href="event.md#0x1_event">0x1::event</a>;
<b>use</b> <a href="evm_context_v2.md#0x1_evm_context_v2">0x1::evm_context_v2</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
</code></pre>



<a id="0x1_evm_for_test_v2_ExecResultEvent"></a>

## Struct `ExecResultEvent`



<pre><code>#[<a href="event.md#0x1_event">event</a>]
<b>struct</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_ExecResultEvent">ExecResultEvent</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;</code>
</dt>
<dd>

</dd>
</dl>


</details>

<a id="@Constants_0"></a>

## Constants


<a id="0x1_evm_for_test_v2_TX_TYPE_1559"></a>



<pre><code><b>const</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_TX_TYPE_1559">TX_TYPE_1559</a>: u8 = 2;
</code></pre>



<a id="0x1_evm_for_test_v2_TX_TYPE_NORMAL"></a>



<pre><code><b>const</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_TX_TYPE_NORMAL">TX_TYPE_NORMAL</a>: u8 = 1;
</code></pre>



<a id="0x1_evm_for_test_v2_pre_init"></a>

## Function `pre_init`



<pre><code><b>public</b> <b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;): (u64, u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_pre_init">pre_init</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                    codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                    nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                    balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                    storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                    storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;,
                    access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
                    access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;): (u64, u64) {

    <b>let</b> pre_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&addresses);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&codes), 3);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&storage_keys), 3);
    <b>assert</b>!(pre_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&storage_values), 3);
    <b>let</b> i = 0;
    <b>while</b>(i &lt; pre_len) {
        <b>let</b> key_datas = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&storage_keys, i);
        <b>let</b> value_datas = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&storage_values, i);
        <b>let</b> data_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&key_datas);
        <b>assert</b>!(data_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&value_datas), 4);
        <b>let</b> <b>address</b> = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&addresses, i);

        <b>let</b> j = 0;
        <b>while</b> (j &lt; data_len) {
            <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&key_datas, j);
            <b>let</b> value = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&value_datas, j);
            <a href="evm_context_v2.md#0x1_evm_context_v2_set_storage">evm_context_v2::set_storage</a>(<b>address</b>, to_u256(key), to_u256(value));
            j = j + 1;
        };
        <a href="evm_context_v2.md#0x1_evm_context_v2_set_account">evm_context_v2::set_account</a>(<b>address</b>, to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&balances, i)), *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&codes, i), to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&nonces, i)));
        i = i + 1;
    };

    i = 0;
    <b>let</b> access_slot_count = 0;
    <b>let</b> access_list_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_addresses);
    <b>assert</b>!(access_list_len == <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_keys), 3);
    <b>while</b> (i &lt; access_list_len) {
        <b>let</b> access_data = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_keys, i);
        <b>let</b> contract = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_addresses, i);
        <b>let</b> j = 0;
        <b>let</b> data_len = <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&access_data);
        <b>while</b> (j &lt; data_len) {
            <b>let</b> key = *<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&access_data, j);
            <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_slot">evm_context_v2::add_always_warm_slot</a>(contract, to_u256(key));
            j = j + 1;
            access_slot_count = access_slot_count + 1;
        };

        <a href="evm_context_v2.md#0x1_evm_context_v2_add_always_warm_address">evm_context_v2::add_always_warm_address</a>(contract);

        i = i + 1;
    };

    (access_list_len, access_slot_count)
}
</code></pre>



</details>

<a id="0x1_evm_for_test_v2_emit_event"></a>

## Function `emit_event`



<pre><code><b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_emit_event">emit_event</a>(state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_emit_event">emit_event</a>(state_root: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;) {
    <a href="event.md#0x1_event_emit">event::emit</a>(<a href="evm_for_test_v2.md#0x1_evm_for_test_v2_ExecResultEvent">ExecResultEvent</a> {
        state_root
    });

}
</code></pre>



</details>

<a id="0x1_evm_for_test_v2_run_test"></a>

## Function `run_test`



<pre><code><b>public</b> entry <b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_run_test">run_test</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, codes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, nonces: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, balances: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, storage_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, storage_values: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, access_addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, access_keys: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;&gt;, from: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <b>to</b>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_limit_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, gas_price_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, value_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, env_data: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;, tx_type: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> entry <b>fun</b> <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_run_test">run_test</a>(addresses: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;&gt;,
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
                          tx_type: u8) {
    <b>let</b> (address_list_address_len, access_list_slot_len) = <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_pre_init">pre_init</a>(addresses, codes, nonces, balances, storage_keys, storage_values, access_addresses, access_keys);
    <b>let</b> gas_limit = to_u256(gas_limit_bytes);
    <b>let</b> value = to_u256(value_bytes);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&value);
    <b>let</b> gas_price;
    <b>let</b> env = parse_env(&env_data);
    <b>if</b>(tx_type == <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_TX_TYPE_NORMAL">TX_TYPE_NORMAL</a>) {
        gas_price = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 0));
        <a href="evm_context_v2.md#0x1_evm_context_v2_execute_tx">evm_context_v2::execute_tx</a>(env, from, <b>to</b>, value, data, gas_limit, gas_price, 0, 0, address_list_address_len, access_list_slot_len, tx_type);
    } <b>else</b> {
        gas_price = get_base_fee_per_gas(&env) + to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 1));
        <b>let</b> max_fee_per_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 0));
        <b>let</b> max_priority_fee_per_gas = to_u256(*<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_borrow">vector::borrow</a>(&gas_price_data, 1));
        gas_price = <b>if</b>(gas_price &gt; max_fee_per_gas) max_fee_per_gas <b>else</b> gas_price;
        <a href="evm_context_v2.md#0x1_evm_context_v2_execute_tx">evm_context_v2::execute_tx</a>(env, from, <b>to</b>, value, data, gas_limit, gas_price, max_fee_per_gas, max_priority_fee_per_gas, address_list_address_len, access_list_slot_len, tx_type);
    };

    <b>let</b> state_root = <a href="evm_context_v2.md#0x1_evm_context_v2_calculate_root">evm_context_v2::calculate_root</a>();
    // <b>let</b> exec_cost = gas_usage - base_cost;
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&state_root);
    <a href="evm_for_test_v2.md#0x1_evm_for_test_v2_emit_event">emit_event</a>(state_root);
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
