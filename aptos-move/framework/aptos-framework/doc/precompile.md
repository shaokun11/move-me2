
<a id="0x1_precompile"></a>

# Module `0x1::precompile`



-  [Constants](#@Constants_0)
-  [Function `ecrecover`](#0x1_precompile_ecrecover)
-  [Function `run_precompile`](#0x1_precompile_run_precompile)
-  [Function `calc_mod_exp_gas`](#0x1_precompile_calc_mod_exp_gas)
-  [Function `calculate_iteration_count`](#0x1_precompile_calculate_iteration_count)
-  [Function `calculate_multiplication_complexity`](#0x1_precompile_calculate_multiplication_complexity)
-  [Function `is_precompile_address`](#0x1_precompile_is_precompile_address)


<pre><code><b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_aptos_hash">0x1::aptos_hash</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/debug.md#0x1_debug">0x1::debug</a>;
<b>use</b> <a href="arithmetic.md#0x1_evm_arithmetic">0x1::evm_arithmetic</a>;
<b>use</b> <a href="util.md#0x1_evm_util">0x1::evm_util</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/hash.md#0x1_hash">0x1::hash</a>;
<b>use</b> <a href="../../aptos-stdlib/../move-stdlib/doc/option.md#0x1_option">0x1::option</a>;
<b>use</b> <a href="../../aptos-stdlib/doc/secp256k1.md#0x1_secp256k1">0x1::secp256k1</a>;
</code></pre>



<a id="@Constants_0"></a>

## Constants


<a id="0x1_precompile_BLAKE2F"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_BLAKE2F">BLAKE2F</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9];
</code></pre>



<a id="0x1_precompile_CALL_DATA_LENGTH"></a>

invalid precomile calldata length


<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_CALL_DATA_LENGTH">CALL_DATA_LENGTH</a>: u64 = 50002;
</code></pre>



<a id="0x1_precompile_ECADD"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_ECADD">ECADD</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6];
</code></pre>



<a id="0x1_precompile_ECMUL"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_ECMUL">ECMUL</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7];
</code></pre>



<a id="0x1_precompile_ECPAIRING"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_ECPAIRING">ECPAIRING</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8];
</code></pre>



<a id="0x1_precompile_EcAddCost"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_EcAddCost">EcAddCost</a>: u256 = 150;
</code></pre>



<a id="0x1_precompile_EcMulCost"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_EcMulCost">EcMulCost</a>: u256 = 6000;
</code></pre>



<a id="0x1_precompile_Ecrecover"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_Ecrecover">Ecrecover</a>: u256 = 3000;
</code></pre>



<a id="0x1_precompile_IDENTITY"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_IDENTITY">IDENTITY</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4];
</code></pre>



<a id="0x1_precompile_IdentityWord"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_IdentityWord">IdentityWord</a>: u256 = 3;
</code></pre>



<a id="0x1_precompile_MAX_SIZE"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_MAX_SIZE">MAX_SIZE</a>: u256 = 2147483647;
</code></pre>



<a id="0x1_precompile_MODEXP"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_MODEXP">MODEXP</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5];
</code></pre>



<a id="0x1_precompile_MOD_PARAMS_SISE"></a>

mod exp len params invalid


<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_MOD_PARAMS_SISE">MOD_PARAMS_SISE</a>: u64 = 50003;
</code></pre>



<a id="0x1_precompile_ModexpGquaddivisor"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_ModexpGquaddivisor">ModexpGquaddivisor</a>: u256 = 3;
</code></pre>



<a id="0x1_precompile_RCRECOVER"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_RCRECOVER">RCRECOVER</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1];
</code></pre>



<a id="0x1_precompile_RIPEMD"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_RIPEMD">RIPEMD</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3];
</code></pre>



<a id="0x1_precompile_Ripemd160Word"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_Ripemd160Word">Ripemd160Word</a>: u256 = 120;
</code></pre>



<a id="0x1_precompile_SHA256"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_SHA256">SHA256</a>: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt; = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2];
</code></pre>



<a id="0x1_precompile_Sha256Word"></a>



<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_Sha256Word">Sha256Word</a>: u256 = 12;
</code></pre>



<a id="0x1_precompile_UNSUPPORT"></a>

unsupport precomile address


<pre><code><b>const</b> <a href="precompile.md#0x1_precompile_UNSUPPORT">UNSUPPORT</a>: u64 = 50001;
</code></pre>



<a id="0x1_precompile_ecrecover"></a>

## Function `ecrecover`



<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_ecrecover">ecrecover</a>(calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="chain_id.md#0x1_chain_id">chain_id</a>: u64, gas_limit: u256): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_ecrecover">ecrecover</a>(calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="chain_id.md#0x1_chain_id">chain_id</a>: u64, gas_limit: u256): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256) {
    <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata) != 128) {
        <b>return</b> (<b>false</b>, to_32bit(x""), <a href="precompile.md#0x1_precompile_Ecrecover">Ecrecover</a>)
    } <b>else</b> {
        <b>let</b> message_hash = vector_slice(calldata, 0, 32);
        <b>let</b> v = (to_u256(vector_slice(calldata, 32, 32)) <b>as</b> u64);
        <b>let</b> signature = ecdsa_signature_from_bytes(vector_slice(calldata, 64, 64));

        <b>let</b> recovery_id = <b>if</b>(v &gt; 28) ((v - (<a href="chain_id.md#0x1_chain_id">chain_id</a> * 2) - 35) <b>as</b> u8) <b>else</b> ((v - 27) <b>as</b> u8);
        <b>let</b> pk_recover = ecdsa_recover(message_hash, recovery_id, &signature);
        <b>let</b> pk = keccak256(ecdsa_raw_public_key_to_bytes(borrow(&pk_recover)));
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&vector_slice(pk, 12, 20));
        <b>if</b>(<a href="precompile.md#0x1_precompile_Ecrecover">Ecrecover</a> &gt; gas_limit) {
            (<b>false</b>, to_32bit(x""), gas_limit)
        } <b>else</b> {
            (<b>true</b>, to_32bit(vector_slice(pk, 12, 20)), <a href="precompile.md#0x1_precompile_Ecrecover">Ecrecover</a>)
        }
    }
}
</code></pre>



</details>

<a id="0x1_precompile_run_precompile"></a>

## Function `run_precompile`



<pre><code><b>public</b> <b>fun</b> <a href="precompile.md#0x1_precompile_run_precompile">run_precompile</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="chain_id.md#0x1_chain_id">chain_id</a>: u64, gas_limit: u256): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="precompile.md#0x1_precompile_run_precompile">run_precompile</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, calldata: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, <a href="chain_id.md#0x1_chain_id">chain_id</a>: u64, gas_limit: u256): (bool, <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, u256)  {
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&addr);
    <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&calldata);
    <b>if</b>(addr == <a href="precompile.md#0x1_precompile_RCRECOVER">RCRECOVER</a>) {
        <a href="precompile.md#0x1_precompile_ecrecover">ecrecover</a>(calldata, <a href="chain_id.md#0x1_chain_id">chain_id</a>, gas_limit)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_SHA256">SHA256</a>) {
        <b>let</b> word_count = get_word_count((<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata) <b>as</b> u256));
        (<b>true</b>, sha2_256(calldata), <a href="precompile.md#0x1_precompile_Sha256Word">Sha256Word</a> * word_count + 60)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_RIPEMD">RIPEMD</a>) {
        <b>let</b> word_count = get_word_count((<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata) <b>as</b> u256));
        (<b>true</b>, to_32bit(ripemd160(calldata)), 600 + <a href="precompile.md#0x1_precompile_Ripemd160Word">Ripemd160Word</a> * word_count)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_IDENTITY">IDENTITY</a>) {
        <b>let</b> word_count = get_word_count((<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata) <b>as</b> u256));
        (<b>true</b>, calldata, 15 + <a href="precompile.md#0x1_precompile_IdentityWord">IdentityWord</a> * word_count)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_MODEXP">MODEXP</a>) {
        <b>let</b> base_len = to_u256(vector_slice(calldata, 0, 32));
        <b>let</b> exp_len = to_u256(vector_slice(calldata, 32, 32));
        <b>let</b> mod_len = to_u256(vector_slice(calldata, 64, 32));

        <b>if</b>(base_len == 0 && mod_len == 0) {
            <b>return</b> (<b>true</b>, x"", 200)
        };

        <b>if</b>(base_len &gt; <a href="precompile.md#0x1_precompile_MAX_SIZE">MAX_SIZE</a> || mod_len &gt; <a href="precompile.md#0x1_precompile_MAX_SIZE">MAX_SIZE</a> || exp_len &gt; <a href="precompile.md#0x1_precompile_MAX_SIZE">MAX_SIZE</a> || (base_len + mod_len + exp_len + 96) &gt; <a href="precompile.md#0x1_precompile_MAX_SIZE">MAX_SIZE</a>) {
            <b>return</b> (<b>false</b>, x"", gas_limit)
        };
        <b>let</b> pos = 96;
        <b>let</b> base_bytes = vector_slice_u256(calldata, pos, base_len);
        pos = pos + base_len;
        <b>let</b> exp_bytes = vector_slice_u256(calldata, pos, exp_len);
        pos = pos + exp_len;
        <b>let</b> mod_bytes = vector_slice_u256(calldata, pos, mod_len);
        <b>let</b> gas = <a href="precompile.md#0x1_precompile_calc_mod_exp_gas">calc_mod_exp_gas</a>(base_len, exp_len, exp_bytes, mod_len);

        <b>let</b> result = mod_exp(base_bytes, exp_bytes, mod_bytes);
        result = <b>if</b>(mod_len == 0) x"" <b>else</b> to_n_bit(result, (mod_len <b>as</b> u64));
        (<b>true</b>, result, gas)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_ECADD">ECADD</a>) {
        <b>let</b> (success, result) = bn128_add(calldata);
        <b>if</b>(success) (success, result, <a href="precompile.md#0x1_precompile_EcAddCost">EcAddCost</a>) <b>else</b> (success, result, gas_limit)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_ECMUL">ECMUL</a>) {
        <b>let</b> (success, result) = bn128_mul(calldata);
        <b>if</b>(success) (success, result, <a href="precompile.md#0x1_precompile_EcMulCost">EcMulCost</a>) <b>else</b> (success, result, gas_limit)
    } <b>else</b> <b>if</b>(addr == <a href="precompile.md#0x1_precompile_BLAKE2F">BLAKE2F</a>) {
        <b>if</b>(<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata) != 213) {
            <b>return</b> (<b>false</b>, x"", gas_limit)
        };
        <b>let</b> (success, gas_cost, result) = blake_2f(calldata);
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&<a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector_length">vector::length</a>(&calldata));
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&result);
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&success);
        <a href="../../aptos-stdlib/doc/debug.md#0x1_debug_print">debug::print</a>(&gas_cost);
        <b>if</b>(!success) {
            <b>return</b> (<b>false</b>, x"", gas_limit)
        } <b>else</b> {
            <b>return</b> (<b>true</b>, result, (gas_cost <b>as</b> u256))
        }
    } <b>else</b> {
        (<b>false</b>, x"", gas_limit)
    }
}
</code></pre>



</details>

<a id="0x1_precompile_calc_mod_exp_gas"></a>

## Function `calc_mod_exp_gas`



<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calc_mod_exp_gas">calc_mod_exp_gas</a>(base_len: u256, exp_len: u256, exp_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, mod_len: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calc_mod_exp_gas">calc_mod_exp_gas</a>(base_len: u256, exp_len: u256, exp_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;, mod_len: u256): u256 {
    <b>let</b> multiplication_complexity = <a href="precompile.md#0x1_precompile_calculate_multiplication_complexity">calculate_multiplication_complexity</a>(base_len, mod_len);
    <b>let</b> iteration_count = <a href="precompile.md#0x1_precompile_calculate_iteration_count">calculate_iteration_count</a>(exp_len, exp_bytes);
    <b>let</b> gas = multiplication_complexity * iteration_count / <a href="precompile.md#0x1_precompile_ModexpGquaddivisor">ModexpGquaddivisor</a>;
    <b>if</b>(gas &lt; 200) {
        gas = 200;
    };

    gas
}
</code></pre>



</details>

<a id="0x1_precompile_calculate_iteration_count"></a>

## Function `calculate_iteration_count`



<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calculate_iteration_count">calculate_iteration_count</a>(exponent_length: u256, exponent_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calculate_iteration_count">calculate_iteration_count</a>(exponent_length: u256, exponent_bytes: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): u256 {
    <b>let</b> bit_length = bit_length(exponent_bytes);
    <b>let</b> iteration_count = 0;
    <b>if</b>(exponent_length &lt;= 32 && bit_length == 0) {
        iteration_count = 0;
    } <b>else</b> <b>if</b>(exponent_length &lt;= 32) {
        iteration_count = bit_length - 1;
    } <b>else</b> <b>if</b>(exponent_length &gt; 32) {
        <b>let</b> last_32_bit = vector_slice_u256(exponent_bytes, exponent_length - 32, 32);
        iteration_count = (8 * (exponent_length - 32)) + (bit_length(last_32_bit) - 1)
    };

    <b>if</b>(iteration_count == 0) 1 <b>else</b> iteration_count
}
</code></pre>



</details>

<a id="0x1_precompile_calculate_multiplication_complexity"></a>

## Function `calculate_multiplication_complexity`



<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calculate_multiplication_complexity">calculate_multiplication_complexity</a>(base_len: u256, mod_len: u256): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="precompile.md#0x1_precompile_calculate_multiplication_complexity">calculate_multiplication_complexity</a>(base_len: u256, mod_len: u256): u256 {
    <b>let</b> max_length = <b>if</b>(base_len &gt; mod_len) base_len <b>else</b> mod_len;
    <b>let</b> words = max_length / 8;
    <b>if</b>(max_length % 8 != 0) {
        words = words + 1;
    };
    words * words
}
</code></pre>



</details>

<a id="0x1_precompile_is_precompile_address"></a>

## Function `is_precompile_address`



<pre><code>#[view]
<b>public</b> <b>fun</b> <a href="precompile.md#0x1_precompile_is_precompile_address">is_precompile_address</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="precompile.md#0x1_precompile_is_precompile_address">is_precompile_address</a>(addr: <a href="../../aptos-stdlib/../move-stdlib/doc/vector.md#0x1_vector">vector</a>&lt;u8&gt;): bool {
    <b>let</b> num = to_u256(addr);
    num &gt;= 0x01 && num &lt;= 0x0a
}
</code></pre>



</details>


[move-book]: https://aptos.dev/move/book/SUMMARY
